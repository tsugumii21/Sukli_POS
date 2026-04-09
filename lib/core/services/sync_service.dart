import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/isar_collections/sync_queue_collection.dart';
import '../constants/app_constants.dart';
import '../constants/supabase_constants.dart';
import '../errors/app_exception.dart';
import 'isar_service.dart';
import 'supabase_service.dart';
import 'package:uuid/uuid.dart';

class SyncResult {
  final int successCount;
  final int failedCount;
  final bool wasSkipped;

  const SyncResult({
    this.successCount = 0,
    this.failedCount = 0,
    this.wasSkipped = false,
  });

  factory SyncResult.skipped() => const SyncResult(wasSkipped: true);
}

/// SyncService orchestrates the synchronization between Isar and Supabase.
class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  Timer? _syncTimer;
  bool _isSyncing = false;

  IsarService get _isar => IsarService.instance;
  SupabaseService get _supabase => SupabaseService.instance;

  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(seconds: AppConstants.syncIntervalSeconds),
      (_) => syncPendingQueue(),
    );
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Pushes pending queue items to Supabase using LWW strategy.
  Future<SyncResult> syncPendingQueue() async {
    if (_isSyncing) return SyncResult.skipped();
    _isSyncing = true;

    int success = 0;
    int failed = 0;

    try {
      final pendingItems = (await _isar.isar.syncQueueCollections
              .filter()
              .statusEqualTo('pending')
              .findAll())
          .where((item) => item.retryCount < AppConstants.maxSyncRetries)
          .toList();

      for (final item in pendingItems) {
        try {
          final payload =
              jsonDecode(item.payloadJson) as Map<String, dynamic>;

          if (item.operation == 'delete') {
            await _supabase.softDelete(item.tableName, item.recordSyncId);
          } else {
            await _supabase.upsertRecord(item.tableName, payload);
          }

          item.status = 'completed';
          item.completedAt = DateTime.now();
          success++;
        } catch (e) {
          item.retryCount++;
          item.lastError = e.toString();
          item.lastAttemptAt = DateTime.now();
          if (item.retryCount >= item.maxRetries) {
            item.status = 'failed';
          }
          failed++;
        }

        await _isar.isar
            .writeTxn(() => _isar.isar.syncQueueCollections.put(item));
      }

      return SyncResult(successCount: success, failedCount: failed);
    } catch (e) {
      throw SyncException('syncPendingQueue failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Pulls latest data from Supabase (Server wins on conflict).
  Future<void> pullFromSupabase() async {
    final prefs = await SharedPreferences.getInstance();

    final tables = [
      SupabaseConstants.usersTable,
      SupabaseConstants.categoriesTable,
      SupabaseConstants.menuItemsTable,
    ];

    for (final table in tables) {
      final lastPullKey = 'last_pull_$table';
      final lastPullStr = prefs.getString(lastPullKey) ??
          DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();
      final lastPull = DateTime.parse(lastPullStr);

      final remoteRecords =
          await _supabase.fetchUpdatedSince(table, lastPull);

      if (remoteRecords.isNotEmpty) {
        // Note: Repository-level sync logic will be wired in future parts
        final latestRecord = remoteRecords.last;
        await prefs.setString(
            lastPullKey, latestRecord[SupabaseConstants.updatedAt]);
      }
    }
  }

  /// Adds a record mutation to the sync queue.
  Future<void> enqueue({
    required String tableName,
    required String recordSyncId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final queueItem = SyncQueueCollection()
      ..operationId = const Uuid().v4()
      ..tableName = tableName
      ..recordSyncId = recordSyncId
      ..operation = operation
      ..payloadJson = jsonEncode(payload)
      ..retryCount = 0
      ..maxRetries = AppConstants.maxSyncRetries
      ..status = 'pending'
      ..createdAt = DateTime.now();

    await _isar.isar
        .writeTxn(() => _isar.isar.syncQueueCollections.put(queueItem));
  }
}
