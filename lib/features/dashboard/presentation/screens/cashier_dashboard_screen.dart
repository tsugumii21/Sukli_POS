import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/sync_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/stats_card.dart';
import '../../../../shared/widgets/sync_status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

/// CashierDashboardScreen — The main home screen for cashiers.
/// Displays daily stats, favorites, and low stock alerts.
class CashierDashboardScreen extends ConsumerWidget {
  const CashierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // These providers are defined in the imported files above
    final authState = ref.watch(authProvider);
    final dashboardAsync = ref.watch(dashboardProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final isSyncing = ref.watch(isSyncingProvider);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;

    final cashierName = authState.selectedCashier?.name ?? 'Cashier';

    return Scaffold(
      backgroundColor: bg,
      drawer: _DashboardDrawer(cashierName: cashierName),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded, color: textPrimary, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF8B4049).withValues(alpha: 0.1),
              child: Text(
                cashierName.isNotEmpty ? cashierName[0].toUpperCase() : '?',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF8B4049),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning,',
                  style: GoogleFonts.inter(
                    color: textPrimary.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  cashierName,
                  style: GoogleFonts.plusJakartaSans(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SyncStatusBadge(
              isOnline: isOnline,
              isSyncing: isSyncing,
            ),
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, st) => Center(child: Text('Error loading dashboard: $err')),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Stats Row ────────────────────────────────────────────────
              Row(
                children: [
                  StatsCard(
                    title: "Today's Sales",
                    value: CurrencyFormatter.format(data.todaySales),
                    icon: Icons.payments_outlined,
                    valueColor: const Color(0xFF8B4049),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  StatsCard(
                    title: "Orders Today",
                    value: data.todayOrders.toString(),
                    icon: Icons.shopping_bag_outlined,
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppSpacing.lg),

              // ── Main Action ──────────────────────────────────────────────
              AppPrimaryButton(
                label: 'Take Order',
                icon: Icons.add_circle_outline_rounded,
                onPressed: () => context.push(RouteConstants.newOrder),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

              const SizedBox(height: AppSpacing.xl),

              // ── Low Stock Banner ─────────────────────────────────────────
              if (data.lowStockItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A574).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4A574).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFD4A574)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${data.lowStockItems.length} items are low on stock!',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFB8935E),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(RouteConstants.adminInventory),
                        child: Text(
                          'View',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFB8935E),
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().shake(delay: 800.ms),

              // ── Favorites Section ────────────────────────────────────────
              if (data.favorites.isNotEmpty) ...[
                Text(
                  'Quick Picks',
                  style: GoogleFonts.plusJakartaSans(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.favorites.length,
                    itemBuilder: (context, index) {
                      final item = data.favorites[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            item.name,
                            style: GoogleFonts.inter(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: 0.1, end: 0),
                const SizedBox(height: AppSpacing.xl),
              ],

              // ── Recent Orders ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Orders',
                    style: GoogleFonts.plusJakartaSans(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(RouteConstants.orderHistory),
                    child: Text(
                      'See All',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8B4049),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (data.recentOrders.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No orders yet today.',
                      style: GoogleFonts.inter(color: textPrimary.withValues(alpha: 0.4)),
                    ),
                  ),
                )
              else
                ...data.recentOrders.map((order) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B4049).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF8B4049)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '#${order.orderNumber}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${order.orderedAt.hour}:${order.orderedAt.minute.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.inter(
                                    color: textPrimary.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(order.totalAmount),
                            style: GoogleFonts.plusJakartaSans(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.05, end: 0)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardDrawer extends ConsumerWidget {
  const _DashboardDrawer({required this.cashierName});
  final String cashierName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF8B4049)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(
                cashierName.isNotEmpty ? cashierName[0].toUpperCase() : '?',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            accountName: Text(
              cashierName,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
            accountEmail: const Text('Cashier Role'),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.add_shopping_cart_rounded),
            title: const Text('New Order'),
            onTap: () => context.push(RouteConstants.newOrder),
          ),
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: const Text('Order History'),
            onTap: () => context.push(RouteConstants.orderHistory),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.errorLight),
            title: const Text('Logout', style: TextStyle(color: AppColors.errorLight)),
            onTap: () {
              // Removed await because logout() is not a Future
              ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(RouteConstants.cashierSelect);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
