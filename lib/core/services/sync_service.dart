import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'isar_service.dart';
import 'supabase_service.dart';
import '../constants/app_constants.dart';
import '../constants/supabase_constants.dart';
import '../../shared/isar_collections/store_collection.dart';
import '../../shared/isar_collections/user_collection.dart';
import '../../shared/isar_collections/category_collection.dart';
import '../../shared/isar_collections/menu_item_collection.dart';
import '../../shared/isar_collections/order_collection.dart';
import '../../shared/isar_collections/sync_queue_collection.dart';

/// SyncResult represents the outcome of a synchronization operation.
class SyncResult {
  final int processed;
  final int succeeded;
  final int failed;
  final String? error;

  SyncResult({
    required this.processed,
    required this.succeeded,
    required this.failed,
    this.error,
  });

  bool get hasError => error != null;
}

/// SyncService manages the offline-first synchronization logic.
/// It queues local changes and pushes them to Supabase when online.
class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  final IsarService _isar = IsarService.instance;
  final SupabaseService _supabase = SupabaseService.instance;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Timer? _periodicTimer;
  StreamSubscription<void>? _queueSubscription;

  /// Starts a periodic sync process.
  /// Fires an initial sync immediately, then every [syncIntervalSeconds].
  void startPeriodicSync() {
    stopPeriodicSync(); // Cancel any existing timer/subscription

    // Watch for new sync queue entries to push changes immediately
    _queueSubscription = _isar.isar.syncQueueCollections.watchLazy().listen((_) async {
      if (!_isSyncing) {
        final pendingCount = await _isar.isar.syncQueueCollections
            .filter()
            .statusEqualTo('pending')
            .count();
        if (pendingCount > 0 && !_isSyncing) {
          syncAll().then((result) {
            if (result.processed > 0) {
              debugPrint(
                'SYNC [immediate]: processed=${result.processed}, '
                'succeeded=${result.succeeded}, failed=${result.failed}'
                '${result.hasError ? ", error=${result.error}" : ""}',
              );
            }
          });
        }
      }
    });

    // Fire an initial sync after a short delay to let the app finish loading
    Future.delayed(const Duration(seconds: 5), () {
      syncAll().then((result) {
        debugPrint(
          'SYNC [initial]: processed=${result.processed}, '
          'succeeded=${result.succeeded}, failed=${result.failed}'
          '${result.hasError ? ", error=${result.error}" : ""}',
        );
      });
    });

    // Set up periodic sync
    _periodicTimer = Timer.periodic(
      Duration(seconds: AppConstants.syncIntervalSeconds),
      (_) {
        syncAll().then((result) {
          if (result.processed > 0) {
            debugPrint(
              'SYNC [periodic]: processed=${result.processed}, '
              'succeeded=${result.succeeded}, failed=${result.failed}'
              '${result.hasError ? ", error=${result.error}" : ""}',
            );
          }
        });
      },
    );

    debugPrint(
      'SYNC: Periodic sync started (every ${AppConstants.syncIntervalSeconds}s)',
    );
  }

  /// Stops the periodic sync process.
  void stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _queueSubscription?.cancel();
    _queueSubscription = null;
  }

  /// Manually triggers a full synchronization.
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      return SyncResult(
          processed: 0,
          succeeded: 0,
          failed: 0,
          error: 'Sync already in progress');
    }

    _isSyncing = true;
    try {
      // Reset failed sync queue items back to pending to allow retry on manual sync
      await _isar.isar.writeTxn(() async {
        final failedItems = await _isar.isar.syncQueueCollections
            .filter()
            .statusEqualTo('failed')
            .findAll();
        for (final item in failedItems) {
          item.status = 'pending';
          item.retryCount = 0;
          await _isar.isar.syncQueueCollections.put(item);
        }
      });

      // 1. Push local changes
      final pushResult = await syncPendingQueue();

      // 2. Pull remote changes
      final activeStore = await _isar.isar.storeCollections
          .filter()
          .isDeletedEqualTo(false)
          .isActiveEqualTo(true)
          .findFirst();
      if (activeStore != null) {
        await _pullOrders(activeStore.syncId);
      }

      return pushResult;
    } finally {
      _isSyncing = false;
    }
  }

  /// Processes the pending local changes and pushes them to Supabase.
  Future<SyncResult> syncPendingQueue() async {
    int succeeded = 0;
    int failed = 0;

    try {
      final pendingItems = await _isar.isar.syncQueueCollections
          .filter()
          .statusEqualTo('pending')
          .findAll();

      if (pendingItems.isEmpty) {
        return SyncResult(processed: 0, succeeded: 0, failed: 0);
      }

      debugPrint('SYNC: Processing ${pendingItems.length} pending items...');

      for (final item in pendingItems) {
        if (item.retryCount >= AppConstants.maxSyncRetries) {
          debugPrint(
            'SYNC: Skipping ${item.tableName}/${item.recordSyncId} — '
            'max retries (${item.retryCount}) exceeded',
          );
          continue;
        }

        try {
          final payload =
              jsonDecode(item.payloadJson) as Map<String, dynamic>;

          if (item.operation == 'insert') {
            await _supabase.upsertRecord(item.tableName, payload);
          } else if (item.operation == 'update') {
            // Use a targeted UPDATE (not upsert) so partial payloads
            // (e.g. void/refund status changes) don't violate NOT NULL columns.
            final syncId = payload['sync_id'] as String? ?? item.recordSyncId;
            await _supabase.updateRecord(item.tableName, syncId, payload);
          } else if (item.operation == 'delete') {
            await _supabase.deleteRecord(item.tableName, item.recordSyncId);
          }

          // Mark as completed
          await _isar.isar.writeTxn(() async {
            item.status = 'completed';
            item.completedAt = DateTime.now();
            await _isar.isar.syncQueueCollections.put(item);
          });
          succeeded++;
          debugPrint(
            'SYNC: ✓ ${item.operation} ${item.tableName}/${item.recordSyncId}',
          );
        } catch (e) {
          failed++;
          debugPrint(
            'SYNC: ✗ ${item.operation} ${item.tableName}/${item.recordSyncId} — $e',
          );
          await _isar.isar.writeTxn(() async {
            item.status = 'failed';
            item.retryCount++;
            item.lastError = e.toString();
            item.lastAttemptAt = DateTime.now();
            // Reset to pending so it can be retried on next cycle
            if (item.retryCount < AppConstants.maxSyncRetries) {
              item.status = 'pending';
            }
            await _isar.isar.syncQueueCollections.put(item);
          });
        }
      }

      return SyncResult(
        processed: pendingItems.length,
        succeeded: succeeded,
        failed: failed,
      );
    } catch (e) {
      debugPrint('SYNC: Queue processing error — $e');
      return SyncResult(
          processed: 0, succeeded: 0, failed: 0, error: e.toString());
    }
  }

  /// Adds a new operation to the sync queue.
  Future<void> addToQueue({
    required String tableName,
    required String recordSyncId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final item = SyncQueueCollection()
      ..operationId =
          '${tableName}_${recordSyncId}_${DateTime.now().millisecondsSinceEpoch}'
      ..tableName = tableName
      ..recordSyncId = recordSyncId
      ..operation = operation
      ..payloadJson = jsonEncode(payload)
      ..status = 'pending'
      ..retryCount = 0
      ..maxRetries = AppConstants.maxSyncRetries
      ..createdAt = DateTime.now();

    await _isar.isar.writeTxn(() async {
      await _isar.isar.syncQueueCollections.put(item);
    });
  }

  /// Pulls all store, user, category, and menu item data from Supabase for a given admin email.
  /// This is used when logging into an existing admin account to sync the local database.
  Future<bool> pullStoreData(String adminEmail) async {
    try {
      // Push any unsynced local data to Supabase first before clearing Isar
      await syncPendingQueue();

      final client = _supabase.client;

      // 1. Fetch admin user record
      final userList = await client
          .from('users')
          .select()
          .eq('email', adminEmail.trim())
          .eq('role', 'admin')
          .eq('is_deleted', false);

      if (userList.isEmpty) {
        debugPrint('SYNC PULL: No admin user found for email $adminEmail');
        return false;
      }

      final adminData = userList.first;
      final storeId = adminData['store_id'] as String?;

      if (storeId == null || storeId.isEmpty) {
        debugPrint('SYNC PULL: Admin user has no store_id assigned');
        return false;
      }

      debugPrint('SYNC PULL: Fetching data for storeId: $storeId...');

      // 2. Fetch remote records in parallel
      final results = await Future.wait([
        client.from('stores').select().eq('sync_id', storeId).eq('is_deleted', false),
        client.from('users').select().eq('store_id', storeId).eq('is_deleted', false),
        client.from('categories').select().eq('store_id', storeId).eq('is_deleted', false),
        client.from('menu_items').select().eq('store_id', storeId).eq('is_deleted', false),
      ]);

      final storeRows = results[0];
      final userRows = results[1];
      final categoryRows = results[2];
      final menuItemRows = results[3];

      if (storeRows.isEmpty) {
        debugPrint('SYNC PULL: No active store found for storeId $storeId');
        return false;
      }

      final storeMap = storeRows.first;

      // 3. Save to Isar in a transaction
      await _isar.isar.writeTxn(() async {
        // Clear existing local store, users, categories, menu items, orders, and sync queue to prevent duplicate IDs or stale data
        await _isar.isar.storeCollections.clear();
        await _isar.isar.userCollections.clear();
        await _isar.isar.categoryCollections.clear();
        await _isar.isar.menuItemCollections.clear();
        await _isar.isar.orderCollections.clear();
        await _isar.isar.syncQueueCollections.clear();

        // Save store (ensure isActive = true)
        final store = StoreCollection()
          ..syncId = storeMap['sync_id'] as String
          ..name = storeMap['name'] as String
          ..logoUrl = storeMap['logo_url'] as String?
          ..ownerId = storeMap['owner_id'] as String
          ..supabaseAuthUid = storeMap['supabase_auth_uid'] as String?
          ..isActive = true // Mark as active so currentStoreProvider resolves it
          ..createdAt = DateTime.parse(storeMap['created_at'] as String)
          ..updatedAt = DateTime.parse(storeMap['updated_at'] as String)
          ..isSynced = true
          ..isDeleted = false;
        await _isar.isar.storeCollections.put(store);

        // Save users
        for (final row in userRows) {
          final user = UserCollection()
            ..syncId = row['sync_id'] as String
            ..email = row['email'] as String
            ..name = row['name'] as String
            ..pinHash = row['pin_hash'] as String?
            ..role = row['role'] as String
            ..status = row['status'] as String
            ..avatarUrl = row['avatar_url'] as String?
            ..storeId = row['store_id'] as String?
            ..createdAt = DateTime.parse(row['created_at'] as String)
            ..updatedAt = DateTime.parse(row['updated_at'] as String)
            ..isSynced = true
            ..isDeleted = false;
          await _isar.isar.userCollections.put(user);
        }

        // Save categories
        for (final row in categoryRows) {
          final cat = CategoryCollection()
            ..syncId = row['sync_id'] as String
            ..parentId = row['parent_id'] as String?
            ..name = row['name'] as String
            ..description = row['description'] as String?
            ..iconEmoji = row['icon_emoji'] as String?
            ..sortOrder = (row['sort_order'] as num?)?.toInt() ?? 0
            ..isActive = row['is_active'] as bool? ?? true
            ..storeId = row['store_id'] as String?
            ..createdAt = DateTime.parse(row['created_at'] as String)
            ..updatedAt = DateTime.parse(row['updated_at'] as String)
            ..isSynced = true
            ..isDeleted = false;
          await _isar.isar.categoryCollections.put(cat);
        }

        // Save menu items
        for (final row in menuItemRows) {
          // Parse variants from JSONB column or legacy format
          final variantsVal = row['variants_json'];
          List<String> variantsJsonList = [];
          if (variantsVal is String) {
            variantsJsonList = [variantsVal];
          } else if (variantsVal is List) {
            variantsJsonList = variantsVal.map((v) => jsonEncode(v)).toList();
          }

          // Same for variant groups if present
          final groupsVal = row['variant_groups_json'];
          List<String> groupsJsonList = [];
          if (groupsVal is List) {
            groupsJsonList = groupsVal.map((g) => g is String ? g : jsonEncode(g)).toList();
          }

          // Same for modifiers
          final modifiersVal = row['modifiers_json'];
          List<String> modifiersJsonList = [];
          if (modifiersVal is List) {
            modifiersJsonList = modifiersVal.map((m) => m is String ? m : jsonEncode(m)).toList();
          }

          final item = MenuItemCollection()
            ..syncId = row['sync_id'] as String
            ..categoryId = row['category_id'] as String
            ..name = row['name'] as String
            ..description = row['description'] as String?
            ..basePrice = (row['base_price'] as num).toDouble()
            ..imageUrl = row['image_url'] as String?
            ..isAvailable = row['is_available'] as bool? ?? true
            ..isFavorite = row['is_favorite'] as bool? ?? false
            ..sortOrder = (row['sort_order'] as num?)?.toInt() ?? 0
            ..variantsJson = variantsJsonList
            ..variantGroupsJson = groupsJsonList
            ..modifiersJson = modifiersJsonList
            ..storeId = row['store_id'] as String?
            ..createdAt = DateTime.parse(row['created_at'] as String)
            ..updatedAt = DateTime.parse(row['updated_at'] as String)
            ..isSynced = true
            ..isDeleted = false;
          await _isar.isar.menuItemCollections.put(item);
        }
      });

      debugPrint('SYNC PULL: Successfully downloaded store, '
          '${userRows.length} users, '
          '${categoryRows.length} categories, '
          '${menuItemRows.length} menu items.');

      // Also pull recent orders using the storeId already in scope
      await _pullOrders(storeId);

      return true;
    } catch (e, stack) {
      debugPrint('SYNC PULL ERROR: Failed to pull store data: $e\n$stack');
      return false;
    }
  }

  /// Pulls the most recent orders from Supabase for a given storeId.
  /// Uses LWW (Last-Write-Wins) to avoid overwriting newer local data.
  Future<void> _pullOrders(String storeId) async {
    try {
      final rows = await _supabase.client
          .from(SupabaseConstants.ordersTable)
          .select()
          .eq(SupabaseConstants.storeId, storeId)
          .eq(SupabaseConstants.isDeleted, false)
          .order('ordered_at', ascending: false)
          .limit(500);

      debugPrint('SYNC: Pulled ${rows.length} orders');

      await _isar.isar.writeTxn(() async {
        for (final row in rows) {
          final existing = await _isar.isar.orderCollections
              .filter()
              .syncIdEqualTo(row['sync_id'] as String)
              .findFirst();

          final serverUpdatedAt = DateTime.parse(row['updated_at'] as String);

          // LWW — only update if server record is newer or doesn't exist locally
          if (existing == null || serverUpdatedAt.isAfter(existing.updatedAt)) {
            final orderItemsRaw = row['order_items_json'];
            List<String> orderItemsJson = [];
            if (orderItemsRaw is List) {
              orderItemsJson = orderItemsRaw
                  .map((v) => v is String ? v : jsonEncode(v))
                  .toList();
            }

            final order = OrderCollection()
              ..syncId = row['sync_id'] as String
              ..storeId = row['store_id'] as String?
              ..orderNumber = row['order_number'] as String
              ..cashierId = row['cashier_id'] as String
              ..cashierName = row['cashier_name'] as String
              ..orderItemsJson = orderItemsJson
              ..subtotal = (row['subtotal'] as num).toDouble()
              ..discountAmount = (row['discount_amount'] as num? ?? 0).toDouble()
              ..discountReason = row['discount_reason'] as String?
              ..taxAmount = (row['tax_amount'] as num? ?? 0).toDouble()
              ..totalAmount = (row['total_amount'] as num).toDouble()
              ..amountTendered = (row['amount_tendered'] as num).toDouble()
              ..changeAmount = (row['change_amount'] as num).toDouble()
              ..paymentMethod = row['payment_method'] as String
              ..paymentReference = row['payment_reference'] as String?
              ..status = row['status'] as String
              ..voidReason = row['void_reason'] as String?
              ..refundReason = row['refund_reason'] as String?
              ..voidedById = row['voided_by_id'] as String?
              ..voidedAt = row['voided_at'] != null
                  ? DateTime.parse(row['voided_at'] as String)
                  : null
              ..orderedAt = DateTime.parse(row['ordered_at'] as String)
              ..createdAt = DateTime.parse(row['created_at'] as String)
              ..updatedAt = DateTime.parse(row['updated_at'] as String)
              ..isSynced = true
              ..isDeleted = row['is_deleted'] as bool? ?? false;

            await _isar.isar.orderCollections.put(order);
          }
        }
      });
    } catch (e) {
      debugPrint('SYNC: Pull orders failed: $e');
    }
  }

  /// Full pull of all store data from Supabase into Isar.
  /// Call this on every login to restore local data from Supabase.
  /// This is a convenience wrapper around pullStoreData for cases where
  /// the admin email is already stored locally (e.g., cashier PIN login).
  Future<void> initialPullFromSupabase() async {
    try {
      debugPrint('SYNC: Starting initial pull from Supabase...');

      // Check for a Supabase-authenticated user
      final supabaseUser = _supabase.currentUser;
      if (supabaseUser == null) {
        debugPrint('SYNC: No Supabase user — skipping initial pull');
        return;
      }

      // Fetch the store from Supabase using the authenticated user's UID
      final storeRows = await _supabase.client
          .from(SupabaseConstants.storesTable)
          .select()
          .eq(SupabaseConstants.storeAuthUid, supabaseUser.id)
          .eq(SupabaseConstants.isDeleted, false)
          .limit(1);

      if (storeRows.isEmpty) {
        debugPrint('SYNC: No store found in Supabase — skipping initial pull');
        return;
      }

      final ownerEmail = storeRows.first['owner_id'] as String?;
      if (ownerEmail == null) {
        debugPrint('SYNC: Store has no owner_id — skipping initial pull');
        return;
      }

      // Re-use the full pullStoreData pipeline (users, categories, items, orders)
      await pullStoreData(ownerEmail);

      debugPrint('SYNC: Initial pull complete.');
    } catch (e) {
      // Don't throw — app must still work offline if pull fails
      debugPrint('SYNC: Initial pull failed: $e');
    }
  }
}
