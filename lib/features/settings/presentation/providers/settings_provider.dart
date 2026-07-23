import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar_community/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../shared/providers/isar_provider.dart';
import '../../../../shared/providers/store_provider.dart';
import '../../../../shared/isar_collections/store_collection.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../../../../shared/isar_collections/category_collection.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../../../../shared/isar_collections/order_collection.dart';

/// State object holding all configuration and settings fields.
class SettingsState {
  const SettingsState({
    this.storeName = 'Sukli Bistro',
    this.logoUrl,
    this.storeTagline = 'Fresh & Local',
    this.receiptHeader = 'Sukli Bistro',
    this.receiptFooter = 'Thank you for dining with us! 😊',
    this.showCashierName = true,
    this.showOrderNumber = true,
    this.storeAddress = '',
    this.storeContact = '',
    this.printLogo = false,
    this.showDateTime = true,
    this.paperSize = '58mm',
    this.autoCut = true,
    this.autoSync = true,
    this.syncInterval = 30,
    this.isSyncing = false,
    this.syncMessage,
    this.adminName = '',
    this.adminEmail = '',
  });

  final String storeName;
  final String? logoUrl;
  final String storeTagline;
  final String receiptHeader;
  final String receiptFooter;
  final bool showCashierName;
  final bool showOrderNumber;
  final String storeAddress;
  final String storeContact;
  final bool printLogo;
  final bool showDateTime;
  final String paperSize;
  final bool autoCut;
  final bool autoSync;
  final int syncInterval;
  final bool isSyncing;
  final String? syncMessage;
  final String adminName;
  final String adminEmail;

  SettingsState copyWith({
    String? storeName,
    String? logoUrl,
    String? storeTagline,
    String? receiptHeader,
    String? receiptFooter,
    bool? showCashierName,
    bool? showOrderNumber,
    String? storeAddress,
    String? storeContact,
    bool? printLogo,
    bool? showDateTime,
    String? paperSize,
    bool? autoCut,
    bool? autoSync,
    int? syncInterval,
    bool? isSyncing,
    String? syncMessage,
    String? adminName,
    String? adminEmail,
  }) {
    return SettingsState(
      storeName: storeName ?? this.storeName,
      logoUrl: logoUrl ?? this.logoUrl,
      storeTagline: storeTagline ?? this.storeTagline,
      receiptHeader: receiptHeader ?? this.receiptHeader,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      showCashierName: showCashierName ?? this.showCashierName,
      showOrderNumber: showOrderNumber ?? this.showOrderNumber,
      storeAddress: storeAddress ?? this.storeAddress,
      storeContact: storeContact ?? this.storeContact,
      printLogo: printLogo ?? this.printLogo,
      showDateTime: showDateTime ?? this.showDateTime,
      paperSize: paperSize ?? this.paperSize,
      autoCut: autoCut ?? this.autoCut,
      autoSync: autoSync ?? this.autoSync,
      syncInterval: syncInterval ?? this.syncInterval,
      isSyncing: isSyncing ?? this.isSyncing,
      syncMessage: syncMessage ?? this.syncMessage,
      adminName: adminName ?? this.adminName,
      adminEmail: adminEmail ?? this.adminEmail,
    );
  }
}

/// SettingsNotifier loads, saves, and updates configurations in Isar and SharedPreferences.
class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return const SettingsState();
  }

  /// Initial load of all settings from local sources.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isar = ref.read(isarProvider);

    // 1. Load active Store configurations from Isar
    final store = await isar.storeCollections
        .filter()
        .isDeletedEqualTo(false)
        .isActiveEqualTo(true)
        .findFirst();

    final storeName = store?.name ?? 'Sukli Bistro';
    final logoUrl = store?.logoUrl;

    // 2. Load templates & display options from SharedPreferences
    final storeTagline = prefs.getString('store_tagline') ?? 'Fresh & Local';
    final receiptHeader = prefs.getString('receipt_header') ?? storeName;
    final receiptFooter = prefs.getString('receipt_footer') ?? 'Thank you for dining with us! 😊';
    final showCashierName = prefs.getBool('receipt_show_cashier') ?? true;
    final showOrderNumber = prefs.getBool('receipt_show_order_num') ?? true;
    final storeAddress = prefs.getString('store_address') ?? '';
    final storeContact = prefs.getString('store_contact') ?? '';
    final printLogo = prefs.getBool('receipt_print_logo') ?? false;
    final showDateTime = prefs.getBool('receipt_show_date_time') ?? true;
    final paperSize = prefs.getString('receipt_paper_size') ?? '58mm';
    final autoCut = prefs.getBool('receipt_auto_cut') ?? true;
    final autoSync = prefs.getBool('auto_sync') ?? true;
    final syncInterval = prefs.getInt('sync_interval') ?? 30;

    // 3. Load Admin profile from Supabase and Isar
    final supabaseUser = SupabaseService.instance.currentUser;
    String adminName = '';
    String adminEmail = '';
    if (supabaseUser != null) {
      adminEmail = supabaseUser.email ?? '';
      final localAdmin = await isar.userCollections
          .filter()
          .roleEqualTo('admin')
          .emailEqualTo(adminEmail)
          .findFirst();
      adminName = localAdmin?.name ?? supabaseUser.userMetadata?['name'] ?? 'Admin';
    }

    state = SettingsState(
      storeName: storeName,
      logoUrl: logoUrl,
      storeTagline: storeTagline,
      receiptHeader: receiptHeader,
      receiptFooter: receiptFooter,
      showCashierName: showCashierName,
      showOrderNumber: showOrderNumber,
      storeAddress: storeAddress,
      storeContact: storeContact,
      printLogo: printLogo,
      showDateTime: showDateTime,
      paperSize: paperSize,
      autoCut: autoCut,
      autoSync: autoSync,
      syncInterval: syncInterval,
      adminName: adminName,
      adminEmail: adminEmail,
    );
  }

  /// Update general SharedPreferences settings.
  Future<void> saveSettings({
    String? storeTagline,
    String? receiptHeader,
    String? receiptFooter,
    bool? showCashierName,
    bool? showOrderNumber,
    String? storeAddress,
    String? storeContact,
    bool? printLogo,
    bool? showDateTime,
    String? paperSize,
    bool? autoCut,
    bool? autoSync,
    int? syncInterval,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (storeTagline != null) await prefs.setString('store_tagline', storeTagline);
    if (receiptHeader != null) await prefs.setString('receipt_header', receiptHeader);
    if (receiptFooter != null) await prefs.setString('receipt_footer', receiptFooter);
    if (showCashierName != null) await prefs.setBool('receipt_show_cashier', showCashierName);
    if (showOrderNumber != null) await prefs.setBool('receipt_show_order_num', showOrderNumber);
    if (storeAddress != null) await prefs.setString('store_address', storeAddress);
    if (storeContact != null) await prefs.setString('store_contact', storeContact);
    if (printLogo != null) await prefs.setBool('receipt_print_logo', printLogo);
    if (showDateTime != null) await prefs.setBool('receipt_show_date_time', showDateTime);
    if (paperSize != null) await prefs.setString('receipt_paper_size', paperSize);
    if (autoCut != null) await prefs.setBool('receipt_auto_cut', autoCut);
    if (autoSync != null) await prefs.setBool('auto_sync', autoSync);
    if (syncInterval != null) await prefs.setInt('sync_interval', syncInterval);

    state = state.copyWith(
      storeTagline: storeTagline ?? state.storeTagline,
      receiptHeader: receiptHeader ?? state.receiptHeader,
      receiptFooter: receiptFooter ?? state.receiptFooter,
      showCashierName: showCashierName ?? state.showCashierName,
      showOrderNumber: showOrderNumber ?? state.showOrderNumber,
      storeAddress: storeAddress ?? state.storeAddress,
      storeContact: storeContact ?? state.storeContact,
      printLogo: printLogo ?? state.printLogo,
      showDateTime: showDateTime ?? state.showDateTime,
      paperSize: paperSize ?? state.paperSize,
      autoCut: autoCut ?? state.autoCut,
      autoSync: autoSync ?? state.autoSync,
      syncInterval: syncInterval ?? state.syncInterval,
    );
  }

  /// Updates the store name in Isar and syncs it to Supabase.
  Future<void> updateStoreName(String newName) async {
    final isar = ref.read(isarProvider);
    final store = await isar.storeCollections
        .filter()
        .isDeletedEqualTo(false)
        .isActiveEqualTo(true)
        .findFirst();

    if (store != null) {
      final now = DateTime.now();
      await isar.writeTxn(() async {
        store.name = newName;
        store.updatedAt = now;
        store.isSynced = false;
        await isar.storeCollections.put(store);
      });

      // Register sync entry
      await SyncService.instance.addToQueue(
        tableName: SupabaseConstants.storesTable,
        recordSyncId: store.syncId,
        operation: 'update',
        payload: {
          'sync_id': store.syncId,
          'name': store.name,
          'logo_url': store.logoUrl,
          'owner_id': store.ownerId,
          'supabase_auth_uid': store.supabaseAuthUid,
          'is_active': store.isActive,
          'updated_at': now.toIso8601String(),
          'is_deleted': store.isDeleted,
        },
      );

      ref.invalidate(currentStoreProvider);
      state = state.copyWith(storeName: newName);
    }
  }

  /// Updates store logo public url in Isar and syncs it.
  Future<void> updateStoreLogo(String? logoUrl) async {
    final isar = ref.read(isarProvider);
    final store = await isar.storeCollections
        .filter()
        .isDeletedEqualTo(false)
        .isActiveEqualTo(true)
        .findFirst();

    if (store != null) {
      final now = DateTime.now();
      await isar.writeTxn(() async {
        store.logoUrl = logoUrl;
        store.updatedAt = now;
        store.isSynced = false;
        await isar.storeCollections.put(store);
      });

      // Register sync entry
      await SyncService.instance.addToQueue(
        tableName: SupabaseConstants.storesTable,
        recordSyncId: store.syncId,
        operation: 'update',
        payload: {
          'sync_id': store.syncId,
          'name': store.name,
          'logo_url': logoUrl,
          'owner_id': store.ownerId,
          'supabase_auth_uid': store.supabaseAuthUid,
          'is_active': store.isActive,
          'updated_at': now.toIso8601String(),
          'is_deleted': store.isDeleted,
        },
      );

      ref.invalidate(currentStoreProvider);
      state = state.copyWith(logoUrl: logoUrl);
    }
  }

  /// Updates Admin credentials (metadata, local records).
  Future<void> updateAdminProfile(String name, String email) async {
    final isar = ref.read(isarProvider);
    final supabaseUser = SupabaseService.instance.currentUser;
    if (supabaseUser == null) return;

    final auth = SupabaseService.instance.auth;

    // Update Supabase Auth metadata
    await auth.updateUser(
      UserAttributes(data: {'name': name}),
    );

    // Update email if modified
    if (email.trim() != supabaseUser.email) {
      await auth.updateUser(UserAttributes(email: email.trim()));
    }

    // Update local Isar
    final localAdmin = await isar.userCollections
        .filter()
        .roleEqualTo('admin')
        .emailEqualTo(supabaseUser.email ?? '')
        .findFirst();

    if (localAdmin != null) {
      final now = DateTime.now();
      await isar.writeTxn(() async {
        localAdmin.name = name;
        localAdmin.email = email;
        localAdmin.updatedAt = now;
        localAdmin.isSynced = false;
        await isar.userCollections.put(localAdmin);
      });

      await SyncService.instance.addToQueue(
        tableName: SupabaseConstants.usersTable,
        recordSyncId: localAdmin.syncId,
        operation: 'update',
        payload: {
          'sync_id': localAdmin.syncId,
          'store_id': localAdmin.storeId,
          'name': name,
          'email': email,
          'pin_hash': localAdmin.pinHash,
          'role': 'admin',
          'status': 'active',
          'updated_at': now.toIso8601String(),
          'is_deleted': localAdmin.isDeleted,
        },
      );
    }

    state = state.copyWith(adminName: name, adminEmail: email);
  }

  /// Updates the admin authentication password.
  Future<void> changeAdminPassword(String newPassword) async {
    final auth = SupabaseService.instance.auth;
    await auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Triggers full manual synchronization.
  Future<void> syncNow() async {
    if (state.isSyncing) return;
    state = state.copyWith(isSyncing: true, syncMessage: 'Syncing in progress...');

    try {
      final result = await SyncService.instance.syncAll();
      if (result.hasError) {
        state = state.copyWith(
          isSyncing: false,
          syncMessage: 'Sync failed: ${result.error}',
        );
      } else {
        state = state.copyWith(
          isSyncing: false,
          syncMessage: 'Sync completed. (Succeeded: ${result.succeeded}, Failed: ${result.failed})',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        syncMessage: 'Sync error occurred: $e',
      );
    }
  }

  /// Exports all Isar collections to JSON string.
  Future<String> exportBackupData() async {
    final isar = ref.read(isarProvider);

    final stores = await isar.storeCollections.where().findAll();
    final users = await isar.userCollections.where().findAll();
    final categories = await isar.categoryCollections.where().findAll();
    final menuItems = await isar.menuItemCollections.where().findAll();
    final orders = await isar.orderCollections.where().findAll();

    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'Sukli POS',
      'stores': stores.map((s) => {
        'syncId': s.syncId,
        'name': s.name,
        'logoUrl': s.logoUrl,
        'ownerId': s.ownerId,
        'supabaseAuthUid': s.supabaseAuthUid,
        'isActive': s.isActive,
        'createdAt': s.createdAt.toIso8601String(),
        'updatedAt': s.updatedAt.toIso8601String(),
        'isSynced': s.isSynced,
        'isDeleted': s.isDeleted,
      }).toList(),
      'users': users.map((u) => {
        'syncId': u.syncId,
        'email': u.email,
        'name': u.name,
        'pinHash': u.pinHash,
        'role': u.role,
        'status': u.status,
        'avatarUrl': u.avatarUrl,
        'storeId': u.storeId,
        'createdAt': u.createdAt.toIso8601String(),
        'updatedAt': u.updatedAt.toIso8601String(),
        'isSynced': u.isSynced,
        'isDeleted': u.isDeleted,
      }).toList(),
      'categories': categories.map((c) => {
        'syncId': c.syncId,
        'parentId': c.parentId,
        'name': c.name,
        'description': c.description,
        'iconEmoji': c.iconEmoji,
        'sortOrder': c.sortOrder,
        'isActive': c.isActive,
        'storeId': c.storeId,
        'createdAt': c.createdAt.toIso8601String(),
        'updatedAt': c.updatedAt.toIso8601String(),
        'isSynced': c.isSynced,
        'isDeleted': c.isDeleted,
      }).toList(),
      'menuItems': menuItems.map((m) => {
        'syncId': m.syncId,
        'categoryId': m.categoryId,
        'name': m.name,
        'description': m.description,
        'basePrice': m.basePrice,
        'imageUrl': m.imageUrl,
        'isAvailable': m.isAvailable,
        'isFavorite': m.isFavorite,
        'sortOrder': m.sortOrder,
        'variantsJson': m.variantsJson,
        'variantGroupsJson': m.variantGroupsJson,
        'modifiersJson': m.modifiersJson,
        'storeId': m.storeId,
        'createdAt': m.createdAt.toIso8601String(),
        'updatedAt': m.updatedAt.toIso8601String(),
        'isSynced': m.isSynced,
        'isDeleted': m.isDeleted,
      }).toList(),
      'orders': orders.map((o) => {
        'syncId': o.syncId,
        'orderNumber': o.orderNumber,
        'cashierId': o.cashierId,
        'cashierName': o.cashierName,
        'orderItemsJson': o.orderItemsJson,
        'subtotal': o.subtotal,
        'discountAmount': o.discountAmount,
        'discountReason': o.discountReason,
        'taxAmount': o.taxAmount,
        'totalAmount': o.totalAmount,
        'amountTendered': o.amountTendered,
        'changeAmount': o.changeAmount,
        'paymentMethod': o.paymentMethod,
        'paymentReference': o.paymentReference,
        'status': o.status,
        'voidReason': o.voidReason,
        'refundReason': o.refundReason,
        'voidedById': o.voidedById,
        'voidedAt': o.voidedAt?.toIso8601String(),
        'voidedByName': o.voidedByName,
        'isPartialRefund': o.isPartialRefund,
        'refundAmount': o.refundAmount,
        'refundedAt': o.refundedAt?.toIso8601String(),
        'refundedById': o.refundedById,
        'refundedByName': o.refundedByName,
        'orderedAt': o.orderedAt.toIso8601String(),
        'storeId': o.storeId,
        'createdAt': o.createdAt.toIso8601String(),
        'updatedAt': o.updatedAt.toIso8601String(),
        'isSynced': o.isSynced,
        'isDeleted': o.isDeleted,
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Restores Isar collections from backed up JSON string.
  Future<void> restoreBackupData(String jsonString) async {
    final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;
    if (data['app'] != 'Sukli POS') {
      throw const FormatException('Invalid backup file formatting: app signature missing');
    }

    final isar = ref.read(isarProvider);

    await isar.writeTxn(() async {
      // 1. Wipe collections
      await isar.storeCollections.clear();
      await isar.userCollections.clear();
      await isar.categoryCollections.clear();
      await isar.menuItemCollections.clear();
      await isar.orderCollections.clear();

      // 2. Repopulate Stores
      final storesList = data['stores'] as List;
      for (final item in storesList) {
        final Map<String, dynamic> json = item as Map<String, dynamic>;
        final s = StoreCollection()
          ..syncId = json['syncId'] as String
          ..name = json['name'] as String
          ..logoUrl = json['logoUrl'] as String?
          ..ownerId = json['ownerId'] as String
          ..supabaseAuthUid = json['supabaseAuthUid'] as String?
          ..isActive = json['isActive'] as bool
          ..createdAt = DateTime.parse(json['createdAt'] as String).toLocal()
          ..updatedAt = DateTime.parse(json['updatedAt'] as String).toLocal()
          ..isSynced = json['isSynced'] as bool
          ..isDeleted = json['isDeleted'] as bool;
        await isar.storeCollections.put(s);
      }

      // 3. Repopulate Users
      final usersList = data['users'] as List;
      for (final item in usersList) {
        final Map<String, dynamic> json = item as Map<String, dynamic>;
        final u = UserCollection()
          ..syncId = json['syncId'] as String
          ..email = json['email'] as String
          ..name = json['name'] as String
          ..pinHash = json['pinHash'] as String?
          ..role = json['role'] as String
          ..status = json['status'] as String
          ..avatarUrl = json['avatarUrl'] as String?
          ..storeId = json['storeId'] as String?
          ..createdAt = DateTime.parse(json['createdAt'] as String).toLocal()
          ..updatedAt = DateTime.parse(json['updatedAt'] as String).toLocal()
          ..isSynced = json['isSynced'] as bool
          ..isDeleted = json['isDeleted'] as bool;
        await isar.userCollections.put(u);
      }

      // 4. Repopulate Categories
      final catsList = data['categories'] as List;
      for (final item in catsList) {
        final Map<String, dynamic> json = item as Map<String, dynamic>;
        final c = CategoryCollection()
          ..syncId = json['syncId'] as String
          ..parentId = json['parentId'] as String?
          ..name = json['name'] as String
          ..description = json['description'] as String?
          ..iconEmoji = json['iconEmoji'] as String?
          ..sortOrder = json['sortOrder'] as int
          ..isActive = json['isActive'] as bool
          ..storeId = json['storeId'] as String?
          ..createdAt = DateTime.parse(json['createdAt'] as String).toLocal()
          ..updatedAt = DateTime.parse(json['updatedAt'] as String).toLocal()
          ..isSynced = json['isSynced'] as bool
          ..isDeleted = json['isDeleted'] as bool;
        await isar.categoryCollections.put(c);
      }

      // 5. Repopulate MenuItems
      final itemsList = data['menuItems'] as List;
      for (final item in itemsList) {
        final Map<String, dynamic> json = item as Map<String, dynamic>;
        final m = MenuItemCollection()
          ..syncId = json['syncId'] as String
          ..categoryId = json['categoryId'] as String
          ..name = json['name'] as String
          ..description = json['description'] as String?
          ..basePrice = (json['basePrice'] as num).toDouble()
          ..imageUrl = json['imageUrl'] as String?
          ..isAvailable = json['isAvailable'] as bool
          ..isFavorite = json['isFavorite'] as bool
          ..sortOrder = json['sortOrder'] as int
          ..variantsJson = List<String>.from(json['variantsJson'] as List)
          ..variantGroupsJson = List<String>.from(json['variantGroupsJson'] as List)
          ..modifiersJson = List<String>.from(json['modifiersJson'] as List)
          ..storeId = json['storeId'] as String?
          ..createdAt = DateTime.parse(json['createdAt'] as String).toLocal()
          ..updatedAt = DateTime.parse(json['updatedAt'] as String).toLocal()
          ..isSynced = json['isSynced'] as bool
          ..isDeleted = json['isDeleted'] as bool;
        await isar.menuItemCollections.put(m);
      }

      // 6. Repopulate Orders
      final ordersList = data['orders'] as List;
      for (final item in ordersList) {
        final Map<String, dynamic> json = item as Map<String, dynamic>;
        final o = OrderCollection()
          ..syncId = json['syncId'] as String
          ..orderNumber = json['orderNumber'] as String
          ..cashierId = json['cashierId'] as String
          ..cashierName = json['cashierName'] as String
          ..orderItemsJson = List<String>.from(json['orderItemsJson'] as List)
          ..subtotal = (json['subtotal'] as num).toDouble()
          ..discountAmount = (json['discountAmount'] as num).toDouble()
          ..discountReason = json['discountReason'] as String?
          ..taxAmount = (json['taxAmount'] as num).toDouble()
          ..totalAmount = (json['totalAmount'] as num).toDouble()
          ..amountTendered = (json['amountTendered'] as num).toDouble()
          ..changeAmount = (json['changeAmount'] as num).toDouble()
          ..paymentMethod = json['paymentMethod'] as String
          ..paymentReference = json['paymentReference'] as String?
          ..status = json['status'] as String
          ..voidReason = json['voidReason'] as String?
          ..refundReason = json['refundReason'] as String?
          ..voidedById = json['voidedById'] as String?
          ..voidedAt = json['voidedAt'] == null ? null : DateTime.parse(json['voidedAt'] as String).toLocal()
          ..voidedByName = json['voidedByName'] as String?
          ..isPartialRefund = json['isPartialRefund'] as bool? ?? false
          ..refundAmount = json['refundAmount'] == null ? null : (json['refundAmount'] as num).toDouble()
          ..refundedAt = json['refundedAt'] == null ? null : DateTime.parse(json['refundedAt'] as String).toLocal()
          ..refundedById = json['refundedById'] as String?
          ..refundedByName = json['refundedByName'] as String?
          ..orderedAt = DateTime.parse(json['orderedAt'] as String).toLocal()
          ..storeId = json['storeId'] as String?
          ..createdAt = DateTime.parse(json['createdAt'] as String).toLocal()
          ..updatedAt = DateTime.parse(json['updatedAt'] as String).toLocal()
          ..isSynced = json['isSynced'] as bool
          ..isDeleted = json['isDeleted'] as bool;
        await isar.orderCollections.put(o);
      }
    });

    ref.invalidate(currentStoreProvider);
    await loadSettings();
  }
}

/// Riverpod provider for all configurations and setting details.
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
