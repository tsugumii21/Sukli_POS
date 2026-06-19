import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_layout.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/category_collection.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/shimmer_list.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../providers/menu_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/item_customization_modal.dart';
import 'package:sukli_pos/core/theme/app_text_styles.dart';

/// NewOrderScreen — The heart of the POS.
/// Category filters → searchable item grid → item customization → cart FAB.
class NewOrderScreen extends ConsumerStatefulWidget {
  const NewOrderScreen({super.key});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen> {
  final _searchController = TextEditingController();
  late final MenuNotifier _menuNotifier;

  @override
  void initState() {
    super.initState();
    _menuNotifier = ref.read(menuProvider.notifier);
    // If items are already in the cart from a previous session, ask the user
    // whether they want to continue or start fresh.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final order = ref.read(orderProvider);
      if (order.isNotEmpty) _showContinueDialog(context, order);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    Future.microtask(() {
      _menuNotifier.selectCategory(null);
      _menuNotifier.updateSearch('');
    });
    super.dispose();
  }

  void _showContinueDialog(BuildContext context, dynamic order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppColors.surfaceDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : const Color(0xFF6B6B6B);
    final accentColor = isDark ? AppColors.accentDark : Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryDark : AppColors.secondaryLight;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_rounded,
                  color: accentColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Continue Previous Order?',
                style: AppTextStyles.bodyLarge(context).copyWith(color: textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You have ${order.itemCount} item${order.itemCount == 1 ? '' : 's'} '
                '(${CurrencyFormatter.format(order.total)}) left in your cart.',
                style: AppTextStyles.body(context).copyWith(color: textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Yes, Continue',
                    style: AppTextStyles.body(context),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Start fresh button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(orderProvider.notifier).clearCart();
                    Navigator.pop(ctx);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: textSecondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'No, Start Fresh',
                    style: AppTextStyles.body(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuProvider);
    final orderState = ref.watch(orderProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final topLevelCategories = menuState.categories
        .where((cat) => cat.parentId == null || cat.parentId!.isEmpty)
        .toList();

    final selectedCategory = menuState.selectedCategoryId != null
        ? menuState.categories.firstWhere(
            (c) => c.syncId == menuState.selectedCategoryId,
            orElse: () => CategoryCollection()
              ..syncId = ''
              ..name = '',
          )
        : null;

    final activeParentId = (selectedCategory != null &&
            selectedCategory.parentId != null &&
            selectedCategory.parentId!.isNotEmpty)
        ? selectedCategory.parentId
        : menuState.selectedCategoryId;

    final subCategories = activeParentId != null
        ? menuState.categories
            .where((c) => c.parentId == activeParentId)
            .toList()
        : <CategoryCollection>[];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteConstants.cashierHome);
            }
          },
        ),
        title: Text(
          'New Order',
          style: AppTextStyles.h3(context).copyWith(color: textPrimary),
        ),
        centerTitle: false,
        actions: [
          // Cart badge icon
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined,
                    color: textPrimary, size: 26),
                onPressed: orderState.isNotEmpty
                    ? () {
                        HapticFeedback.lightImpact();
                        _showCartSheet(context);
                      }
                    : null,
              ),
              if (orderState.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.accentDark
                          : Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryDark : AppColors.secondaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      orderState.itemCount.toString(),
                      style: AppTextStyles.label(context).copyWith(color: AppColors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────────────
          // ── Search Bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.sm,
              bottom: AppSpacing.md,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDarkElevated : AppColors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isDark
                      ? AppColors.accentDark.withValues(alpha: 0.3)
                      : AppColors.secondaryLight.withValues(alpha: 0.2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) =>
                    ref.read(menuProvider.notifier).updateSearch(v),
                style: AppTextStyles.body(context).copyWith(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  hintStyle: AppTextStyles.body(context).copyWith(
                    color: isDark ? AppColors.textSecondaryDark : textPrimary.withValues(alpha:0.35),
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? AppColors.textSecondaryDark : textPrimary.withValues(alpha: 0.35),
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: isDark ? AppColors.textSecondaryDark : textPrimary.withValues(alpha: 0.35),
                              size: 20),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _searchController.clear();
                            ref.read(menuProvider.notifier).updateSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),

          // ── Category Pills ──────────────────────────────────────────────
          if (topLevelCategories.isNotEmpty)
            _CategoryTabsRow(
              categories: topLevelCategories,
              selectedId: activeParentId,
              allCount: menuState.allItems.length,
              countForCategory: menuState.countForCategory,
              onSelect: ref.read(menuProvider.notifier).selectCategory,
              isDark: isDark,
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

          if (subCategories.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            _SubCategoryTabsRow(
              categories: subCategories,
              selectedId: menuState.selectedCategoryId,
              parentId: activeParentId!,
              countForCategory: menuState.countForCategory,
              onSelect: ref.read(menuProvider.notifier).selectCategory,
              isDark: isDark,
            ).animate().fadeIn(duration: 300.ms),
          ],

          const SizedBox(height: AppSpacing.md),

          // ── Item Grid ───────────────────────────────────────────────────
          Expanded(
            child: menuState.isLoading
                ? const ShimmerMenuGrid()
                : menuState.items.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.search_off_rounded,
                        title: 'No items found',
                        subtitle: 'Try a different search or category.',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveLayout.gridColumns(context),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: ResponsiveLayout.adaptiveAspectRatio(context, phoneRatio: 0.80),
                        ),
                        itemCount: menuState.items.length,
                        itemBuilder: (context, index) {
                          final item = menuState.items[index];
                          return ItemCard(
                            item: item,
                            onTap: () => _showItemCustomization(context, item),
                          )
                              .animate()
                              .fadeIn(
                                duration: 400.ms,
                                delay: (50 * index).ms,
                              )
                              .slideY(
                                begin: 0.08,
                                end: 0,
                                duration: 300.ms,
                                delay: (50 * index).ms,
                              );
                        },
                      ),
          ),
        ],
      ),

      // ── Cart FAB ──────────────────────────────────────────────────────
      floatingActionButton: orderState.isNotEmpty
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              width: double.infinity,
              height: 60,
              child: FloatingActionButton.extended(
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryDark : AppColors.secondaryLight,
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push(RouteConstants.checkout);
                },
                icon: const Icon(Icons.shopping_cart_checkout_rounded,
                    color: AppColors.white),
                label: Text(
                  'Checkout  •  ${CurrencyFormatter.format(orderState.total)}',
                  style: AppTextStyles.bodyLarge(context).copyWith(color: AppColors.white),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(
              begin: 0.5, end: 0, duration: 300.ms, curve: Curves.easeOut)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── Item Customization ──────────────────────────────────────────────────
  void _showItemCustomization(BuildContext context, MenuItemCollection item) {
    ItemCustomizationModal.show(context, item: item);
  }

  // ── Cart Preview Sheet ──────────────────────────────────────────────────
  void _showCartSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final order = ref.watch(orderProvider);
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: textPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Order',
                        style: AppTextStyles.h3(context).copyWith(color: textPrimary),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(orderProvider.notifier).clearCart();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Clear All',
                          style: AppTextStyles.body(context).copyWith(color: AppColors.errorLight),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: order.items.length,
                      itemBuilder: (context, index) {
                        final cartItem = order.items[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.itemName,
                                      style: AppTextStyles.body(context).copyWith(color: textPrimary),
                                    ),
                                    if (cartItem.variantName != null)
                                      Text(
                                        cartItem.variantName!,
                                        style: AppTextStyles.body(context).copyWith(
                                          color: isDark ? AppColors.textSecondaryDark : textPrimary.withValues(alpha: 0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                    Text(
                                      CurrencyFormatter.format(
                                          cartItem.subtotal),
                                      style: AppTextStyles.body(context).copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryDark : AppColors.secondaryLight,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity controls
                              Row(
                                children: [
                                  _QtyButton(
                                    icon: Icons.remove_rounded,
                                    onTap: () => ref
                                        .read(orderProvider.notifier)
                                        .updateQuantity(cartItem.cartKey,
                                            cartItem.quantity - 1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    child: Text(
                                      cartItem.quantity.toString(),
                                      style: AppTextStyles.bodyLarge(context).copyWith(color: textPrimary),
                                    ),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add_rounded,
                                    onTap: () => ref
                                        .read(orderProvider.notifier)
                                        .updateQuantity(cartItem.cartKey,
                                            cartItem.quantity + 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Checkout button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        this.context.mounted
                            ? GoRouter.of(this.context)
                                .push(RouteConstants.checkout)
                            : null;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryDark : AppColors.secondaryLight,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Checkout  •  ${CurrencyFormatter.format(order.total)}',
                        style: AppTextStyles.bodyLarge(context, color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Small +/- button used in the cart quantity controls.
class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, size: 18, color: Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryDark : AppColors.secondaryLight),
      ),
    );
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
    final maroon = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;

    return SizedBox(
      height: 56,
      child: ListView(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          _Tab(
            label: 'All',
            count: allCount,
            isSelected: selectedId == null,
            onTap: () => onSelect(null),
            maroon: maroon,
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
              maroon: maroon,
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
    final maroon = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;

    return SizedBox(
      height: 56,
      child: ListView(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          _Tab(
            label: 'All',
            count: countForCategory(parentId),
            isSelected: selectedId == parentId,
            onTap: () => onSelect(parentId),
            maroon: maroon,
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
              maroon: maroon,
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
      borderRadius: BorderRadius.circular(999),
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
                borderRadius: BorderRadius.circular(99),
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
