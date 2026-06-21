import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../shared/isar_collections/category_collection.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../../../../shared/providers/store_provider.dart';

/// Holds a category together with its menu-item count.
class CategoryWithCount {
  final CategoryCollection category;
  final int itemCount;

  const CategoryWithCount({required this.category, required this.itemCount});

  CategoryWithCount copyWith({CategoryCollection? category, int? itemCount}) =>
      CategoryWithCount(
        category: category ?? this.category,
        itemCount: itemCount ?? this.itemCount,
      );
}

/// CategoryNotifier manages CRUD + reorder for categories.
class CategoryNotifier extends Notifier<AsyncValue<List<CategoryWithCount>>> {
  static const _uuid = Uuid();

  @override
  AsyncValue<List<CategoryWithCount>> build() {
    final storeId = ref.watch(currentStoreIdProvider);
    if (storeId.isEmpty) return const AsyncValue.data([]);

    _init(storeId);
    return const AsyncValue.loading();
  }

  IsarService get _isar => IsarService.instance;

  void _init(String storeId) {
    Future.microtask(() => _load(storeId));
    final sub1 = _isar.isar.categoryCollections.watchLazy().listen((_) => _load(storeId));
    final sub2 = _isar.isar.menuItemCollections.watchLazy().listen((_) => _load(storeId));
    ref.onDispose(() {
      sub1.cancel();
      sub2.cancel();
    });
  }

  // ── Load ────────────────────────────────────────────────────────────────────

  Future<void> _load(String storeId) async {
    try {
      // Two indexed-field queries (isActive=true / false) then merge.
      final active = await _isar.isar.categoryCollections
          .filter()
          .storeIdEqualTo(storeId)
          .isActiveEqualTo(true)
          .and()
          .isDeletedEqualTo(false)
          .sortBySortOrder()
          .findAll();

      final inactive = await _isar.isar.categoryCollections
          .filter()
          .storeIdEqualTo(storeId)
          .isActiveEqualTo(false)
          .and()
          .isDeletedEqualTo(false)
          .sortBySortOrder()
          .findAll();

      final categories = [...active, ...inactive]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      // Build item counts per category using indexed categoryId.
      final result = <CategoryWithCount>[];
      for (final cat in categories) {
        final items = await _isar.isar.menuItemCollections
            .filter()
            .storeIdEqualTo(storeId)
            .categoryIdEqualTo(cat.syncId)
            .and()
            .isDeletedEqualTo(false)
            .findAll();
        result.add(CategoryWithCount(category: cat, itemCount: items.length));
      }

      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() {
    final storeId = ref.read(currentStoreIdProvider);
    return _load(storeId);
  }

  // ── Create ──────────────────────────────────────────────────────────────────

  Future<void> createCategory({
    required String name,
    String? iconEmoji,
    String? description,
    String? parentId,
  }) async {
    await _doCreate(
        name: name,
        iconEmoji: iconEmoji,
        description: description,
        parentId: parentId);
  }

  /// Creates a category and returns its new syncId.
  /// Used for inline "Create New" from item form.
  Future<String> createCategoryAndReturnId({
    required String name,
    String? iconEmoji,
    String? description,
    String? parentId,
  }) async {
    return await _doCreate(
        name: name,
        iconEmoji: iconEmoji,
        description: description,
        parentId: parentId);
  }

  Future<String> _doCreate({
    required String name,
    String? iconEmoji,
    String? description,
    String? parentId,
  }) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId.isEmpty) throw Exception('No active store');

    final now = DateTime.now();
    final syncId = _uuid.v4();

    // Place at end of the list
    final currentList = state.asData?.value ?? [];
    final nextOrder = currentList.isEmpty
        ? 1
        : (currentList
                .map((c) => c.category.sortOrder)
                .reduce((a, b) => a > b ? a : b) +
            1);

    final category = CategoryCollection()
      ..syncId = syncId
      ..storeId = storeId
      ..parentId = parentId
      ..name = name.trim()
      ..iconEmoji =
          iconEmoji?.trim().isNotEmpty == true ? iconEmoji!.trim() : null
      ..description =
          description?.trim().isNotEmpty == true ? description!.trim() : null
      ..sortOrder = nextOrder
      ..isActive = true
      ..createdAt = now
      ..updatedAt = now
      ..isSynced = false
      ..isDeleted = false;

    await _isar.isar.writeTxn(() async {
      await _isar.isar.categoryCollections.put(category);
    });
    await SyncService.instance.addToQueue(
      tableName: SupabaseConstants.categoriesTable,
      recordSyncId: syncId,
      operation: 'insert',
      payload: _toPayload(category),
    );
    return syncId;
  }

  // ── Update ──────────────────────────────────────────────────────────────────

  Future<void> updateCategory({
    required CategoryCollection category,
    required String name,
    String? iconEmoji,
    String? description,
    bool? isActive,
  }) async {
    category
      ..name = name.trim()
      ..iconEmoji =
          iconEmoji?.trim().isNotEmpty == true ? iconEmoji!.trim() : null
      ..description =
          description?.trim().isNotEmpty == true ? description!.trim() : null
      ..isActive = isActive ?? category.isActive
      ..updatedAt = DateTime.now()
      ..isSynced = false;

    await _isar.isar.writeTxn(() async {
      await _isar.isar.categoryCollections.put(category);
    });
    await SyncService.instance.addToQueue(
      tableName: SupabaseConstants.categoriesTable,
      recordSyncId: category.syncId,
      operation: 'update',
      payload: _toPayload(category),
    );
  }

  // ── Toggle Active ────────────────────────────────────────────────────────────

  Future<void> toggleActive(CategoryCollection category) async {
    category
      ..isActive = !category.isActive
      ..updatedAt = DateTime.now()
      ..isSynced = false;

    await _isar.isar.writeTxn(() async {
      await _isar.isar.categoryCollections.put(category);
    });
    await SyncService.instance.addToQueue(
      tableName: SupabaseConstants.categoriesTable,
      recordSyncId: category.syncId,
      operation: 'update',
      payload: _toPayload(category),
    );
  }

  // ── Reorder ──────────────────────────────────────────────────────────────────

  /// Called after a drag-and-drop reorder. Assigns fresh sequential sortOrders.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.asData?.value;
    if (current == null) return;

    // Flutter's ReorderableListView passes newIndex AFTER removal.
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;

    final list = List<CategoryWithCount>.from(current);
    final moved = list.removeAt(oldIndex);
    list.insert(adjusted, moved);

    // Optimistic update in state immediately.
    state = AsyncValue.data(list);

    // Persist new sortOrders to Isar + SyncQueue.
    await _isar.isar.writeTxn(() async {
      for (int i = 0; i < list.length; i++) {
        final cat = list[i].category;
        cat
          ..sortOrder = i + 1
          ..updatedAt = DateTime.now()
          ..isSynced = false;
        await _isar.isar.categoryCollections.put(cat);
      }
    });

    for (int i = 0; i < list.length; i++) {
      await SyncService.instance.addToQueue(
        tableName: SupabaseConstants.categoriesTable,
        recordSyncId: list[i].category.syncId,
        operation: 'update',
        payload: _toPayload(list[i].category),
      );
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────────

  /// Returns true if the category has menu items (used to show a warning).
  Future<int> getItemCount(CategoryCollection category) async {
    final storeId = ref.read(currentStoreIdProvider);
    final items = await _isar.isar.menuItemCollections
        .filter()
        .storeIdEqualTo(storeId)
        .categoryIdEqualTo(category.syncId)
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    return items.length;
  }

  Future<void> softDelete(CategoryCollection category) async {
    final storeId = ref.read(currentStoreIdProvider);

    // 1. Find all subcategories in Isar
    final subcategories = await _isar.isar.categoryCollections
        .filter()
        .parentIdEqualTo(category.syncId)
        .findAll();

    // 2. Build list of category IDs to delete (parent + subcategories)
    final List<String> targetCategoryIds = [category.syncId];
    final subIds = subcategories.map((c) => c.syncId).toList();
    targetCategoryIds.addAll(subIds);

    // 3. Find all items belonging to these categories in Isar
    var itemsQuery = _isar.isar.menuItemCollections
        .filter()
        .storeIdEqualTo(storeId);
    
    if (targetCategoryIds.length == 1) {
      itemsQuery = itemsQuery.and().categoryIdEqualTo(targetCategoryIds.first);
    } else {
      itemsQuery = itemsQuery.and().group((q) {
        var subQuery = q.categoryIdEqualTo(targetCategoryIds.first);
        for (var i = 1; i < targetCategoryIds.length; i++) {
          subQuery = subQuery.or().categoryIdEqualTo(targetCategoryIds[i]);
        }
        return subQuery;
      });
    }
    
    final items = await itemsQuery.findAll();

    // 4. Perform hard deletes in Isar in a transaction
    await _isar.isar.writeTxn(() async {
      // Delete menu items
      for (final item in items) {
        await _isar.isar.menuItemCollections.delete(item.id);
      }
      // Delete subcategories
      for (final sub in subcategories) {
        await _isar.isar.categoryCollections.delete(sub.id);
      }
      // Delete parent category
      await _isar.isar.categoryCollections.delete(category.id);
    });

    // 5. Add deletions to Sync Queue in order of dependencies (items first, then subcategories, then parent)
    for (final item in items) {
      await SyncService.instance.addToQueue(
        tableName: SupabaseConstants.menuItemsTable,
        recordSyncId: item.syncId,
        operation: 'delete',
        payload: {},
      );
    }

    for (final sub in subcategories) {
      await SyncService.instance.addToQueue(
        tableName: SupabaseConstants.categoriesTable,
        recordSyncId: sub.syncId,
        operation: 'delete',
        payload: {},
      );
    }

    await SyncService.instance.addToQueue(
      tableName: SupabaseConstants.categoriesTable,
      recordSyncId: category.syncId,
      operation: 'delete',
      payload: {},
    );
  }


  // ── Helpers ──────────────────────────────────────────────────────────────────

  Map<String, dynamic> _toPayload(CategoryCollection c) => {
        'sync_id': c.syncId,
        'store_id': c.storeId,
        'parent_id': c.parentId,
        'name': c.name,
        'description': c.description,
        'icon_emoji': c.iconEmoji,
        'sort_order': c.sortOrder,
        'is_active': c.isActive,
        'is_deleted': c.isDeleted,
        'created_at': c.createdAt.toUtc().toIso8601String(),
        'updated_at': c.updatedAt.toUtc().toIso8601String(),
      };
}

/// Provider for category management.
final categoryProvider =
    NotifierProvider<CategoryNotifier, AsyncValue<List<CategoryWithCount>>>(
  CategoryNotifier.new,
);
