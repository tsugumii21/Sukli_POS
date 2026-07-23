import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../shared/providers/active_role_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/order_history_provider.dart';
import '../widgets/order_detail_sheet.dart';
import '../widgets/order_filter_sheet.dart';
import '../widgets/order_tile.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/shimmer_list.dart';
import 'package:sukli_pos/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OrderHistoryScreen — cashier's paginated, searchable, filterable order list
// ─────────────────────────────────────────────────────────────────────────────

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _showSearch = false;



  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Always refresh from Isar when the screen mounts so any orders completed
    // since the provider was first built are immediately visible.
    Future.microtask(
      () => ref.read(orderHistoryProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 600) {
      ref.read(orderHistoryProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auto-trigger next page if previous load finished while scroll remains near bottom
    ref.listen<OrderHistoryState>(orderHistoryProvider, (previous, next) {
      if (previous?.isLoadingMore == true && !next.isLoadingMore && next.hasMore) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _onScroll();
        });
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : const Color(0xFF6B6B6B);
    final inputBg =
        isDark ? AppColors.surfaceDarkElevated : AppColors.cardLight;
    final maroon = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;

    final histState = ref.watch(orderHistoryProvider);
    final hasActiveFilter = histState.filter.isActive;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Order History',
          style: AppTextStyles.h3(context).copyWith(color: textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              final activeRole = ref.read(activeRoleProvider);
              if (activeRole == ActiveRole.admin) {
                context.go(RouteConstants.adminHome);
              } else {
                context.go(RouteConstants.cashierHome);
              }
            }
          },
        ),
        actions: [
          // Search toggle
          IconButton(
            icon: Icon(
              _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
              color: textPrimary,
            ),
            tooltip: _showSearch ? 'Hide search' : 'Search',
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchController.clear();
                ref.read(orderHistoryProvider.notifier).updateSearch('');
              }
            },
          ),

          // Filter button
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.tune_rounded, color: textPrimary),
                tooltip: 'Filter',
                onPressed: () => _openFilter(context),
              ),
              if (hasActiveFilter)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: maroon,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),


        ],
      ),
      body: Column(
        children: [
          // ── Search bar (collapsible) ──────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: _showSearch
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: AppTextStyles.body(context).copyWith(color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search by order number…',
                        hintStyle: AppTextStyles.body(context).copyWith(color: textSecondary),
                        prefixIcon:
                            Icon(Icons.search_rounded, color: textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded,
                                    color: textSecondary, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(orderHistoryProvider.notifier)
                                      .updateSearch('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (v) {
                        setState(() {}); // refresh suffix icon
                        ref
                            .read(orderHistoryProvider.notifier)
                            .updateSearch(v.trim());
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // ── Active filter chips ───────────────────────────────────────────
          if (hasActiveFilter) _ActiveFiltersRow(filter: histState.filter),

          // ── Body: loading / empty / list ─────────────────────────────────
          Expanded(
            child: histState.isLoading
                ? const ShimmerOrderList()
                : RefreshIndicator(
                    color: maroon,
                    backgroundColor: surface,
                    onRefresh: () =>
                        ref.read(orderHistoryProvider.notifier).refresh(),
                    child: histState.orders.isEmpty
                        ? _EmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            itemCount: histState.orders.length + 1,
                            itemBuilder: (context, index) {
                              if (index == histState.orders.length) {
                                if (histState.isLoadingMore) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            color: maroon,
                                            strokeWidth: 2),
                                      ),
                                    ),
                                  );
                                }
                                if (!histState.hasMore && histState.orders.isNotEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: Text(
                                        'All ${histState.orders.length} orders loaded',
                                        style: AppTextStyles.body(context).copyWith(color: textSecondary),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }
                              final order = histState.orders[index];
                              return OrderTile(
                                order: order,
                                onTap: () =>
                                    OrderDetailSheet.show(context, order),
                              )
                                  .animate()
                                  .fadeIn(
                                    delay: Duration(milliseconds: index * 50),
                                    duration: const Duration(milliseconds: 250),
                                  )
                                  .slideY(
                                    begin: 0.08,
                                    end: 0,
                                    duration: const Duration(milliseconds: 250),
                                  );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _openFilter(BuildContext context) async {
    final current = ref.read(orderHistoryProvider).filter;
    final result = await OrderFilterSheet.show(context, current);
    if (result != null) {
      ref.read(orderHistoryProvider.notifier).applyFilter(result);
    }
  }


}

// ─────────────────────────────────────────────────────────────────────────────
// Active filters summary row (shown below search bar when filters are set)
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveFiltersRow extends ConsumerWidget {
  const _ActiveFiltersRow({required this.filter});

  final OrderFilter filter;
  static final _dateFmt = DateFormat('MMM d');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : const Color(0xFF6B6B6B);
    final maroon = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;

    final chips = <String>[];
    if (filter.paymentMethod != null) {
      chips.add(_capitalize(filter.paymentMethod!));
    }
    if (filter.status != null) {
      chips.add(_capitalize(filter.status!));
    }
    if (filter.startDate != null || filter.endDate != null) {
      final start =
          filter.startDate != null ? _dateFmt.format(filter.startDate!) : '…';
      final end =
          filter.endDate != null ? _dateFmt.format(filter.endDate!) : '…';
      chips.add('$start – $end');
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Icon(Icons.filter_list_rounded, size: 14, color: textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: chips
                    .map(
                      (c) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: maroon.withAlpha(20),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: maroon.withAlpha(100), width: 1),
                        ),
                        child: Text(c,
                            style: AppTextStyles.captionMedium(context).copyWith(color: maroon)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => ref.read(orderHistoryProvider.notifier).clearFilter(),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Clear',
                style: AppTextStyles.caption(context).copyWith(color: maroon),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: const EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: 'No orders yet',
            subtitle: 'Orders will appear here once placed.',
          ),
        ),
      ],
    );
  }
}
