import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/seed_data.dart';
import '../../shared/isar_collections/user_collection.dart';
import '../../shared/isar_collections/category_collection.dart';
import '../../shared/isar_collections/menu_item_collection.dart';
import '../../shared/isar_collections/order_collection.dart';
import '../../shared/isar_collections/sync_queue_collection.dart';
import '../../shared/isar_collections/store_collection.dart';
import '../errors/app_exception.dart';

// TO RESET LOCAL DATA FOR TESTING:
// 1. Uninstall the app from the device/emulator
// 2. Reinstall with: flutter run
// This is safer than programmatic deletion.

/// IsarService manages the local NoSQL database.
class IsarService {
  IsarService._();

  static final IsarService instance = IsarService._();

  Isar? _isar;

  Isar get isar {
    if (_isar == null) {
      throw const DatabaseException(
        'Isar has not been initialized. Call init() first.',
      );
    }
    return _isar!;
  }

  /// Bump this number whenever the Isar schema changes (e.g. adding a new
  /// field to a collection). On next launch the stale DB will be deleted and
  /// recreated with the current schema, then re-seeded.
  static const int _schemaVersion = 2;
  static const String _schemaVersionKey = 'isar_schema_version';

  Future<void> init() async {
    if (_isar != null) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final prefs = await SharedPreferences.getInstance();

      // ── Schema version check ──────────────────────────────────────────────
      final storedVersion = prefs.getInt(_schemaVersionKey) ?? 1;
      if (storedVersion < _schemaVersion) {
        // Delete the old Isar database files so the new schema takes effect.
        await Isar.open(
          [
            UserCollectionSchema,
            CategoryCollectionSchema,
            MenuItemCollectionSchema,
            OrderCollectionSchema,
            SyncQueueCollectionSchema,
            StoreCollectionSchema,
          ],
          directory: dir.path,
          inspector: false,
        ).then((db) async {
          await db.writeTxn(() => db.clear());
          await db.close();
        });
        // Mark seeding as needed again since we cleared data.
        await prefs.setBool('db_seeded', false);
        await prefs.setInt(_schemaVersionKey, _schemaVersion);
      }

      // ── Open database ─────────────────────────────────────────────────────
      _isar = await Isar.open(
        [
          UserCollectionSchema,
          CategoryCollectionSchema,
          MenuItemCollectionSchema,
          OrderCollectionSchema,
          SyncQueueCollectionSchema,
          StoreCollectionSchema,
        ],
        directory: dir.path,
        inspector: true,
      );

      // Seed initial data on first launch only
      final isSeeded = prefs.getBool('db_seeded') ?? false;

      if (!isSeeded) {
        await SeedData.seedInitialData(_isar!);
        await prefs.setBool('db_seeded', true);
      }
    } catch (e) {
      throw DatabaseException('Failed to initialize Isar: $e');
    }
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
