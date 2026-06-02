import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../constants/supabase_constants.dart';
import 'pin_helper.dart';
import '../../shared/isar_collections/user_collection.dart';
import '../../shared/isar_collections/category_collection.dart';
import '../../shared/isar_collections/menu_item_collection.dart';
import '../../shared/isar_collections/store_collection.dart';
import '../../shared/isar_collections/sync_queue_collection.dart';

/// SeedData provides initial idempotent data for Sukli POS.
class SeedData {
  static const _uuid = Uuid();

  /// Creates a SyncQueueCollection entry for a given table/record.
  static SyncQueueCollection _syncEntry(
    String table,
    String syncId,
    String operation,
    Map<String, dynamic> payload,
  ) {
    return SyncQueueCollection()
      ..operationId =
          '${table}_${syncId}_${DateTime.now().millisecondsSinceEpoch}'
      ..tableName = table
      ..recordSyncId = syncId
      ..operation = operation
      ..payloadJson = jsonEncode(payload)
      ..status = 'pending'
      ..retryCount = 0
      ..maxRetries = AppConstants.maxSyncRetries
      ..createdAt = DateTime.now();
  }

  /// Migrates items that still use the old flat `variantsJson` format
  /// (list of {name, priceDelta}) into the new `variantGroupsJson` format
  /// (list of {groupName, options:[{name, priceDelta}]}).
  ///
  /// Idempotent — only processes items where variantGroupsJson is empty.
  static Future<void> migrateVariantsToGroups(Isar isar) async {
    final items = await isar.menuItemCollections
        .filter()
        .isDeletedEqualTo(false)
        .findAll();

    final toUpdate = <MenuItemCollection>[];

    for (final item in items) {
      if (item.variantsJson.isEmpty) continue;
      if (item.variantGroupsJson.isNotEmpty) continue;

      // Convert flat variants to a single "Size" group
      final options = item.variantsJson
          .map((s) {
            try {
              final m = jsonDecode(s) as Map<String, dynamic>;
              return <String, dynamic>{
                'name': m['name'] ?? '',
                'priceDelta': (m['priceDelta'] as num?)?.toDouble() ?? 0,
              };
            } catch (_) {
              return null;
            }
          })
          .whereType<Map<String, dynamic>>()
          .toList();

      if (options.isEmpty) continue;

      item.variantGroupsJson = [
        jsonEncode({'groupName': 'Size', 'options': options}),
      ];
      item.variantsJson = [];
      item.updatedAt = DateTime.now();
      toUpdate.add(item);
    }

    if (toUpdate.isNotEmpty) {
      await isar.writeTxn(() async {
        await isar.menuItemCollections.putAll(toUpdate);
      });
    }
  }

  /// Removes legacy demo accounts that should no longer exist in the app.
  /// Run this once at startup before [seedInitialData].
  static Future<void> cleanupLegacyData(Isar isar) async {
    final legacy = await isar.userCollections
        .filter()
        .emailEqualTo('admin@suklipos.com')
        .findAll();
    if (legacy.isEmpty) return;
    await isar.writeTxn(() async {
      for (final u in legacy) {
        u.isDeleted = true;
        u.updatedAt = DateTime.now();
      }
      await isar.userCollections.putAll(legacy);
    });
  }

  static Future<void> seedInitialData(Isar isar) async {
    if (AppConstants.isProduction) return; // skip in production

    final now = DateTime.now();

    // 0. Seed a default Store (required for store_id foreign keys)
    final existingStores = await isar.storeCollections.count();
    String storeSyncId;

    if (existingStores == 0) {
      storeSyncId = _uuid.v4();
      final store = StoreCollection()
        ..syncId = storeSyncId
        ..name = 'Sukli Bistro'
        ..logoUrl = null
        ..ownerId = '' // will be updated below when admin user is created
        ..supabaseAuthUid = null
        ..isActive = true
        ..createdAt = now
        ..updatedAt = now
        ..isSynced = false
        ..isDeleted = false;

      await isar.writeTxn(() async {
        await isar.storeCollections.put(store);
      });

      // Enqueue store sync
      final storeSyncEntry = _syncEntry(
        SupabaseConstants.storesTable,
        storeSyncId,
        'insert',
        {
          'sync_id': storeSyncId,
          'name': store.name,
          'logo_url': store.logoUrl,
          'owner_id': store.ownerId,
          'supabase_auth_uid': store.supabaseAuthUid,
          'is_active': store.isActive,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'is_deleted': store.isDeleted,
        },
      );
      await isar.writeTxn(() async {
        await isar.syncQueueCollections.put(storeSyncEntry);
      });

      debugPrint('SEED: Created default store: $storeSyncId');
    } else {
      // Use existing store's syncId
      final existingStore = await isar.storeCollections
          .filter()
          .isDeletedEqualTo(false)
          .findFirst();
      storeSyncId = existingStore?.syncId ?? '';
    }

    // 1. Seed Users (Cashiers)
    final existingUsers = await isar.userCollections.count();
    if (existingUsers == 0) {
      final users = [
        UserCollection()
          ..syncId = _uuid.v4()
          ..storeId = storeSyncId
          ..name = "Juan Dela Cruz"
          ..email = "juan@example.com"
          ..pinHash = PinHelper.hashPin("1234")
          ..role = "cashier"
          ..status = "active"
          ..createdAt = now
          ..updatedAt = now
          ..isSynced = false
          ..isDeleted = false,
        UserCollection()
          ..syncId = _uuid.v4()
          ..storeId = storeSyncId
          ..name = "Maria Santos"
          ..email = "maria@example.com"
          ..pinHash = PinHelper.hashPin("5678")
          ..role = "cashier"
          ..status = "active"
          ..createdAt = now
          ..updatedAt = now
          ..isSynced = false
          ..isDeleted = false,
        UserCollection()
          ..syncId = _uuid.v4()
          ..storeId = storeSyncId
          ..name = "Pedro Reyes"
          ..email = "pedro@example.com"
          ..pinHash = PinHelper.hashPin("0000")
          ..role = "cashier"
          ..status = "inactive"
          ..createdAt = now
          ..updatedAt = now
          ..isSynced = false
          ..isDeleted = false,
      ];

      await isar.writeTxn(() async {
        await isar.userCollections.putAll(users);
      });

      // Enqueue user sync entries
      for (final u in users) {
        final entry = _syncEntry(
          SupabaseConstants.usersTable,
          u.syncId,
          'insert',
          {
            'sync_id': u.syncId,
            'store_id': u.storeId,
            'name': u.name,
            'email': u.email,
            'pin_hash': u.pinHash,
            'role': u.role,
            'status': u.status,
            'created_at': u.createdAt.toIso8601String(),
            'updated_at': u.updatedAt.toIso8601String(),
            'is_deleted': u.isDeleted,
          },
        );
        await isar.writeTxn(() async {
          await isar.syncQueueCollections.put(entry);
        });
      }

      debugPrint('SEED: Created ${users.length} users');
    }

    // 2. Seed Categories
    final existingCats = await isar.categoryCollections.count();
    if (existingCats == 0) {
      final categories = [
        ('Beverages', '☕', 1),
        ('Food', '🍽️', 2),
        ('Snacks', '🍿', 3),
        ('Desserts', '🍰', 4),
      ]
          .map((data) => CategoryCollection()
            ..syncId = _uuid.v4()
            ..storeId = storeSyncId
            ..name = data.$1
            ..iconEmoji = data.$2
            ..sortOrder = data.$3
            ..isActive = true
            ..createdAt = now
            ..updatedAt = now
            ..isSynced = false
            ..isDeleted = false)
          .toList();

      await isar.writeTxn(() async {
        await isar.categoryCollections.putAll(categories);
      });

      // Enqueue category sync entries
      for (final c in categories) {
        final entry = _syncEntry(
          SupabaseConstants.categoriesTable,
          c.syncId,
          'insert',
          {
            'sync_id': c.syncId,
            'store_id': c.storeId,
            'name': c.name,
            'description': c.description,
            'icon_emoji': c.iconEmoji,
            'sort_order': c.sortOrder,
            'is_active': c.isActive,
            'created_at': c.createdAt.toIso8601String(),
            'updated_at': c.updatedAt.toIso8601String(),
            'is_deleted': c.isDeleted,
          },
        );
        await isar.writeTxn(() async {
          await isar.syncQueueCollections.put(entry);
        });
      }

      debugPrint('SEED: Created ${categories.length} categories');

      // 3. Seed Menu Items (Linked to Category syncId)
      final beveragesId = categories[0].syncId;
      final foodId = categories[1].syncId;
      final dessertsId = categories[3].syncId;

      final menuItems = [
        MenuItemCollection()
          ..syncId = _uuid.v4()
          ..storeId = storeSyncId
          ..categoryId = beveragesId
          ..name = "Iced Coffee"
          ..basePrice = 65
          ..isAvailable = true
          ..isFavorite = true
          ..sortOrder = 1
          ..variantsJson = [
            jsonEncode({"name": "Small", "priceDelta": 0}),
            jsonEncode({"name": "Medium", "priceDelta": 10}),
            jsonEncode({"name": "Large", "priceDelta": 20}),
          ]
          ..createdAt = now
          ..updatedAt = now
          ..isSynced = false
          ..isDeleted = false,
        MenuItemCollection()
          ..syncId = _uuid.v4()
          ..storeId = storeSyncId
          ..categoryId = foodId
          ..name = "Pork Adobo Rice"
          ..basePrice = 120
          ..isAvailable = true
          ..isFavorite = true
          ..sortOrder = 1
          ..createdAt = now
          ..updatedAt = now
          ..isSynced = false
          ..isDeleted = false,
        MenuItemCollection()
          ..syncId = _uuid.v4()
          ..storeId = storeSyncId
          ..categoryId = dessertsId
          ..name = "Leche Flan"
          ..basePrice = 55
          ..isAvailable = true
          ..isFavorite = false
          ..sortOrder = 1
          ..createdAt = now
          ..updatedAt = now
          ..isSynced = false
          ..isDeleted = false,
        MenuItemCollection()
          ..syncId = _uuid.v4()
          ..storeId = storeSyncId
          ..categoryId = foodId
          ..name = "Chicken Fillet Meal"
          ..description = "Crispy chicken fillet served with rice and gravy"
          ..basePrice = 85
          ..isAvailable = true
          ..isFavorite = true
          ..sortOrder = 2
          ..variantsJson = [
            jsonEncode({"name": "Regular", "priceDelta": 0}),
            jsonEncode({"name": "Large", "priceDelta": 20}),
          ]
          ..modifiersJson = [
            jsonEncode({
              "groupName": "Add-ons",
              "name": "Extra Rice",
              "priceDelta": 20
            }),
            jsonEncode(
                {"groupName": "Add-ons", "name": "Drinks", "priceDelta": 35}),
          ]
          ..createdAt = now
          ..updatedAt = now
          ..isSynced = false
          ..isDeleted = false,
      ];

      await isar.writeTxn(() async {
        await isar.menuItemCollections.putAll(menuItems);
      });

      // Enqueue menu item sync entries
      for (final m in menuItems) {
        final entry = _syncEntry(
          SupabaseConstants.menuItemsTable,
          m.syncId,
          'insert',
          {
            'sync_id': m.syncId,
            'store_id': m.storeId,
            'category_id': m.categoryId,
            'name': m.name,
            'description': m.description,
            'base_price': m.basePrice,
            'image_url': m.imageUrl,
            'is_available': m.isAvailable,
            'sort_order': m.sortOrder,
            'variants_json': m.variantsJson.map((s) => jsonDecode(s)).toList(),
            'modifiers_json':
                m.modifiersJson.map((s) => jsonDecode(s)).toList(),
            'created_at': m.createdAt.toIso8601String(),
            'updated_at': m.updatedAt.toIso8601String(),
            'is_deleted': m.isDeleted,
          },
        );
        await isar.writeTxn(() async {
          await isar.syncQueueCollections.put(entry);
        });
      }

      debugPrint('SEED: Created ${menuItems.length} menu items');
    }
  }
}
