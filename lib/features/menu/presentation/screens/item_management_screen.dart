import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_layout.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/destructive_action_dialog.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/shimmer_list.dart';
import '../../../../shared/isar_collections/category_collection.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../providers/item_provider.dart';
import '../widgets/item_manage_tile.dart';
import 'item_form_screen.dart';

/// ItemManagementScreen — Admin screen for browsing and managing menu items.
///
/// Features:
/// - AppBar with search toggle
/// - Category filter tabs (All + per-category with item count)
/// - Scrollable list of ItemManageTile rows
/// - FAB to add new item
/// - Edit / Delete actions per tile
class ItemManagementScreen extends ConsumerStatefulWidget {
  const ItemManagementScreen({super.key});

  @override
  ConsumerState<ItemManagementScreen> createState() =>
      _ItemManagementScreenState();
}

class _ItemManagementScreenState extends ConsumerState<ItemManagementScreen>
    with SingleTickerProviderStateMixin {
  bool _showSearch = false;
  bool _isGridView = false;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openForm({MenuItemCollection? item}) async {
    final stateData = ref.read(itemProvider).asData?.value;
    if (stateData == null) return;
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ItemFormScreen(item: item),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, MenuItemCollection item) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDestructiveDialog(
      context: context,
      title: 'Delete Item?',
      message: 'Are you sure you want to delete "${item.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      icon: Icons.delete_outline_rounded,
    );
    if (confirmed == true && context.mounted) {
      await ref.read(itemProvider.notifier).softDelete(item);
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text('${item.name} deleted',
            style: AppTextStyles.bodySemiBold(context)
                .copyWith(color: Colors.white)),
        backgroundColor: AppColors.errorLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
      ));
    }
  }

  void _toggleSearch(bool isDark, Color textPrimary) {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchCtrl.clear();
        ref.read(itemProvider.notifier).setSearch('');
      } else {
        Future.delayed(
            const Duration(milliseconds: 80), _searchFocus.requestFocus);
      }
    });
  }

  AppBar _buildAppBar(BuildContext context, bool isDark, Color textPrimary) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: textPrimary, size: 20),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteConstants.adminHome);
          }
        },
      ),
      title: _showSearch
          ? TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              onChanged: ref.read(itemProvider.notifier).setSearch,
              style: AppTextStyles.body(context).copyWith(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Search items…',
                hintStyle: AppTextStyles.body(context)
                    .copyWith(color: textPrimary.withValues(alpha: 0.4)),
                border: InputBorder.none,
              ),
            )
          : Text('Menu Items', style: AppTextStyles.h3(context)),
      actions: [
        if (!_showSearch)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, icon: Icon(Icons.list_rounded, size: 18)),
                ButtonSegment(value: true, icon: Icon(Icons.grid_view_rounded, size: 18)),
              ],
              selected: {_isGridView},
              onSelectionChanged: (Set<bool> newSelection) {
                HapticFeedback.lightImpact();
                setState(() => _isGridView = newSelection.first);
              },
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        IconButton(
          icon: Icon(
            _showSearch ? Icons.close_rounded : Icons.search_rounded,
            color: textPrimary,
          ),
          onPressed: () => _toggleSearch(isDark, textPrimary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final _maroon = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;

    final itemsAsync = ref.watch(itemProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(context, isDark, textPrimary),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          _openForm();
        },
        backgroundColor: _maroon,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Add Item',
            style: AppTextStyles.bodySemiBold(context)
                .copyWith(color: Colors.white)),
      )
          .animate()
          .slideY(begin: 0.3, end: 0, duration: 400.ms)
          .fadeIn(duration: 400.ms),
      body: itemsAsync.when(
        loading: () => ShimmerMenuGrid(
          aspectRatio: ResponsiveLayout.adaptiveAspectRatio(context, phoneRatio: 0.80),
        ),
        error: (e, _) => Center(
          child: Text('Error loading items: $e',
              style: AppTextStyles.body(context)),
        ),
        data: (state) => _buildBody(context, state, isDark, textPrimary),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ItemManageState state,
    bool isDark,
    Color textPrimary,
  ) {
    final _maroon = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final categories = state.categories;
    final filtered = state.filtered;

    // Filter categories hierarchically
    final topLevelCategories = categories
        .where((cat) => cat.parentId == null || cat.parentId!.isEmpty)
        .toList();

    final selectedCategory = state.selectedCategoryId != null
        ? categories.firstWhere(
            (c) => c.syncId == state.selectedCategoryId,
            orElse: () => CategoryCollection()
              ..syncId = ''
              ..name = '',
          )
        : null;

    final activeParentId = (selectedCategory != null &&
            selectedCategory.parentId != null &&
            selectedCategory.parentId!.isNotEmpty)
        ? selectedCategory.parentId
        : state.selectedCategoryId;

    final subCategories = activeParentId != null
        ? categories
            .where((c) => c.parentId == activeParentId)
            .toList()
        : <CategoryCollection>[];

    // Tab count = total (index 0 = All)
    final allCount = state.allItems.length;

    return Column(
      children: [
        // ── Category Tabs ──────────────────────────────────────────
        if (topLevelCategories.isNotEmpty)
          _CategoryTabsRow(
            categories: topLevelCategories,
            selectedId: activeParentId,
            allCount: allCount,
            countForCategory: state.countForCategory,
            onSelect: ref.read(itemProvider.notifier).selectCategory,
            isDark: isDark,
          ),

        if (subCategories.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          _SubCategoryTabsRow(
            categories: subCategories,
            selectedId: state.selectedCategoryId,
            parentId: activeParentId!,
            countForCategory: state.countForCategory,
            onSelect: ref.read(itemProvider.notifier).selectCategory,
            isDark: isDark,
          ),
        ],

        // ── Item List ──────────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? _EmptyState(
                  hasCategoryFilter: state.selectedCategoryId != null,
                  hasSearch: state.searchQuery.isNotEmpty,
                  onAdd: () => _openForm(),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(itemProvider.notifier).refresh(),
                  color: _maroon,
                  child: _isGridView
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 80),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: ResponsiveLayout.gridColumns(context),
                            childAspectRatio: ResponsiveLayout.adaptiveAspectRatio(context, phoneRatio: 0.80),
                            crossAxisSpacing: AppSpacing.sm,
                            mainAxisSpacing: AppSpacing.sm,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final item = filtered[i];
                            final catName =
                                _categoryName(state.categories, item.categoryId);
                            return ItemManageGridTile(
                              key: ValueKey(item.syncId),
                              item: item,
                              categoryName: catName,
                              animationIndex: i,
                              onEdit: () => _openForm(item: item),
                              onDelete: () => _confirmDelete(context, item),
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md, AppSpacing.sm, AppSpacing.md, 80),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final item = filtered[i];
                            final catName =
                                _categoryName(state.categories, item.categoryId);
                            return ItemManageTile(
                              key: ValueKey(item.syncId),
                              item: item,
                              categoryName: catName,
                              animationIndex: i,
                              onEdit: () => _openForm(item: item),
                              onDelete: () => _confirmDelete(context, item),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }

  String _categoryName(List<CategoryCollection> cats, String categoryId) {
    try {
      return cats.firstWhere((c) => c.syncId == categoryId).name;
    } catch (_) {
      return '';
    }
  }
}

// ── Category Tabs Row ─────────────────────────────────────────────────────────

class _CategoryTabsRow extends StatelessWidget {
  const _CategoryTabsRow({
    required this.categories,
    required this.selectedId,
    required this.allCount,
    required this.countForCategory,
    required this.onSelect,
    required this.isDark,
  });

  final List<CategoryCollection> categories;
  final String? selectedId;
  final int allCount;
  final int Function(String) countForCategory;
  final ValueChanged<String?> onSelect;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final unselectedBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final _maroon = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;

    return SizedBox(
      height: 56,
      child: ListView(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          // All tab
          _Tab(
            label: 'All',
            count: allCount,
            isSelected: selectedId == null,
            onTap: () => onSelect(null),
            maroon: _maroon,
            unselectedBg: unselectedBg,
            textPrimary: textPrimary,
          ),
          ...categories.map((cat) {
            final count = countForCategory(cat.syncId);
            return _Tab(
              label: cat.name,
              count: count,
              isSelected: selectedId == cat.syncId,
              onTap: () => onSelect(cat.syncId),
              maroon: _maroon,
              unselectedBg: unselectedBg,
              textPrimary: textPrimary,
            );
          }),
        ],
      ),
    );
  }
}

class _SubCategoryTabsRow extends StatelessWidget {
  const _SubCategoryTabsRow({
    required this.categories,
    required this.selectedId,
    required this.parentId,
    required this.countForCategory,
    required this.onSelect,
    required this.isDark,
  });

  final List<CategoryCollection> categories;
  final String? selectedId;
  final String parentId;
  final int Function(String) countForCategory;
  final ValueChanged<String?> onSelect;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final unselectedBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final _maroon = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;

    return SizedBox(
      height: 56,
      child: ListView(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          // "All" tab pointing to parentId
          _Tab(
            label: 'All',
            count: countForCategory(parentId),
            isSelected: selectedId == parentId,
            onTap: () => onSelect(parentId),
            maroon: _maroon,
            unselectedBg: unselectedBg,
            textPrimary: textPrimary,
            isSecondary: true,
          ),
          ...categories.map((cat) {
            final count = countForCategory(cat.syncId);
            return _Tab(
              label: cat.name,
              count: count,
              isSelected: selectedId == cat.syncId,
              onTap: () => onSelect(cat.syncId),
              maroon: _maroon,
              unselectedBg: unselectedBg,
              textPrimary: textPrimary,
              isSecondary: true,
            );
          }),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.maroon,
    required this.unselectedBg,
    required this.textPrimary,
    this.isSecondary = false,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color maroon;
  final Color unselectedBg;
  final Color textPrimary;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? maroon
        : (isSecondary ? Colors.transparent : unselectedBg);
    final border = isSelected
        ? Border.all(color: Colors.transparent)
        : (isSecondary
            ? Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDark
                    : textPrimary.withValues(alpha: 0.2))
            : Border.all(color: Colors.transparent));

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: isSecondary ? 10 : 14, vertical: 0),
        decoration: BoxDecoration(
          color: bg,
          border: border,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.captionMedium(context).copyWith(
                fontSize: isSecondary ? 12 : 13,
                color: isSelected
                    ? Colors.white
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : textPrimary.withValues(alpha: 0.7)),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : maroon.withValues(alpha: 0.12),
                borderRadius: AppRadius.pillBR,
              ),
              child: Text(
                '$count',
                style: AppTextStyles.captionMedium(context).copyWith(
                  color: isSelected ? Colors.white : maroon,
                  fontSize: isSecondary ? 10 : 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasCategoryFilter,
    required this.hasSearch,
    required this.onAdd,
  });
  final bool hasCategoryFilter;
  final bool hasSearch;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final message = hasSearch
        ? 'No items match your search.'
        : hasCategoryFilter
            ? 'No items in this category yet.'
            : 'No menu items yet.';

    return EmptyStateWidget(
      icon: Icons.restaurant_menu_outlined,
      title: message,
      subtitle: !hasSearch ? 'Add menu items from the admin panel.' : null,
      actionLabel: !hasSearch ? 'Add First Item' : null,
      onAction: !hasSearch ? onAdd : null,
    );
  }
}
