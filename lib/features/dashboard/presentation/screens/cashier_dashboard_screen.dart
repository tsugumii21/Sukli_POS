import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_layout.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/order_number_helper.dart';
import '../../../../shared/providers/sync_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/stats_card.dart';
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;

    final cashierName = authState.selectedCashier?.name ?? 'Cashier';
    final initials =
        cashierName.isNotEmpty ? cashierName[0].toUpperCase() : '?';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'morning'
        : hour < 17
            ? 'afternoon'
            : 'evening';

    return Scaffold(
      backgroundColor: bg,
      drawer: _DashboardDrawer(cashierName: cashierName),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 60,
        // All content lives in flexibleSpace so NavigationToolbar's
        // intrinsic-width measurement cycle never touches title/actions.
        // A single Row + Expanded makes overflow physically impossible.
        automaticallyImplyLeading: false,
        flexibleSpace: Builder(
          builder: (context) => SafeArea(
            bottom: false,
            child: SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Drawer button
                  SizedBox(
                    width: 48,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.menu_rounded,
                          color: textPrimary, size: 28),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  // Avatar circle with online indicator badge
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.secondary(context).withValues(alpha: 0.15),
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: AppColors.secondary(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? AppColors.successLight
                                : AppColors.errorLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: bg,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Expanded absorbs all remaining width — overflow impossible
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Good $greeting,',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTextStyles.caption(context).copyWith(
                            color: isDark ? AppColors.textSecondaryDark : textPrimary.withValues(alpha: 0.55),
                          ),
                        ),
                        Text(
                          cashierName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTextStyles.bodySemiBold(context)
                              .copyWith(color: textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ),
      ),
      body: dashboardAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, st) =>
            Center(child: Text('Error loading dashboard: $err')),
        data: (data) => SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
            child: ResponsiveLayout.constrainedBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // ── Stats Row (60/40 asymmetric) ─────────────────────────────
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: StatsCard(
                        title: "Today's Sales",
                        value: CurrencyFormatter.format(data.todaySales),
                        icon: Icons.payments_outlined,
                        valueColor: Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryDark : AppColors.secondaryLight,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 4,
                      child: StatsCard(
                        title: "Orders Today",
                        value: data.todayOrders.toString(),
                        icon: Icons.shopping_bag_outlined,
                      ),
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

                // ── Recent Orders ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Orders',
                      style: AppTextStyles.h3(context).copyWith(color: textPrimary),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.push(RouteConstants.orderHistory),
                      child: Text(
                        'See All',
                        style: AppTextStyles.body(context).copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryDark : AppColors.secondaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (data.recentOrders.isEmpty)
                  const EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: 'No orders yet',
                    subtitle: 'Orders will appear here once placed.',
                  )
                else
                  ...data.recentOrders.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final order = entry.value;
                    // Show only the short order number, e.g. #0004
                    final rawNum = order.orderNumber;
                    final shortNum = OrderNumberHelper.toShort(
                      rawNum,
                      cashierName: order.cashierName,
                    );
                    final accentColor = order.status == 'completed'
                        ? AppColors.successDark
                        : order.status == 'voided'
                            ? AppColors.errorDark
                            : AppColors.warningDark;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 3px left accent bar
                              Container(width: 3, color: accentColor),
                              // Card content
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryDark : AppColors.secondaryLight
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                            Icons.receipt_long_rounded,
                                            color: isDark ? AppColors.secondaryDark : AppColors.secondaryLight),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              shortNum,
                                              style: AppTextStyles.bodyLarge(context).copyWith(color: textPrimary),
                                            ),
                                            Text(
                                              DateFormat('MMM dd, yyyy  h:mm a').format(order.orderedAt),
                                              style: AppTextStyles.body(context).copyWith(
                                                color: isDark ? AppColors.textSecondaryDark : textPrimary.withValues(alpha: 0.5),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(
                                            order.totalAmount),
                                        style: AppTextStyles.bodyLarge(context).copyWith(
                                          color: textPrimary,
                                          fontFeatures: [const FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        .animate(delay: Duration(milliseconds: idx * 50))
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.08, end: 0);
                  }),
                ],
              ),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maroon = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final drawerBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF5F5F5) : AppColors.textPrimaryLight;
    final textSecondary = isDark ? const Color(0xFF8E8E93) : AppColors.textSecondaryLight;
    final itemHoverBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F0F1);
    final iconPrimary = isDark ? const Color(0xFFE8D5C4) : AppColors.textPrimaryLight;
    final dividerColor = isDark ? const Color(0xFF3A3A3C) : AppColors.textPrimaryLight.withValues(alpha: 0.08);
    final headerBg = isDark ? const Color(0xFF2C2C2E) : maroon;
    final currentPath = GoRouterState.of(context).uri.path;
    final initial = cashierName.isNotEmpty ? cashierName[0].toUpperCase() : '?';

    return Drawer(
      backgroundColor: drawerBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 28,
              left: 28,
              right: 28,
              bottom: 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0xFF6B2C33) : Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: AppTextStyles.h2(context).copyWith(color: Colors.white),
                    ),
                  ),
                ).animate().scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 16),
                Text(
                  cashierName,
                  style: AppTextStyles.h3(context).copyWith(color: Colors.white),
                ).animate().fadeIn(duration: 350.ms, delay: 80.ms),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Cashier',
                    style: AppTextStyles.body(context).copyWith(color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ).animate().fadeIn(duration: 350.ms, delay: 140.ms),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Text(
              'MENU',
              style: AppTextStyles.body(context).copyWith(
                color: textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 160.ms),
          const SizedBox(height: 4),
          _NavItem(
            icon: Icons.grid_view_rounded,
            label: 'Home',
            delay: 180,
            isSelected: currentPath == RouteConstants.cashierHome,
            onTap: () {
              Navigator.pop(context);
              if (currentPath != RouteConstants.cashierHome) {
                context.push(RouteConstants.cashierHome);
              }
            },
            hoverBg: itemHoverBg,
            textColor: textPrimary,
            iconColor: iconPrimary,
          ),
          _NavItem(
            icon: Icons.point_of_sale_rounded,
            label: 'New Order',
            delay: 220,
            isSelected: currentPath == RouteConstants.newOrder,
            onTap: () {
              Navigator.pop(context);
              if (currentPath != RouteConstants.newOrder) {
                context.push(RouteConstants.newOrder);
              }
            },
            hoverBg: itemHoverBg,
            textColor: textPrimary,
            iconColor: iconPrimary,
          ),
          _NavItem(
            icon: Icons.receipt_long_rounded,
            label: 'Order History',
            delay: 260,
            isSelected: currentPath == RouteConstants.orderHistory,
            onTap: () {
              Navigator.pop(context);
              if (currentPath != RouteConstants.orderHistory) {
                context.push(RouteConstants.orderHistory);
              }
            },
            hoverBg: itemHoverBg,
            textColor: textPrimary,
            iconColor: iconPrimary,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: dividerColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: dividerColor),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.secondaryDark : AppColors.secondaryLight).withValues(alpha: 0.10),
                borderRadius: AppRadius.smallBR,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 18,
                color: isDark ? AppColors.secondaryDark : AppColors.secondaryLight,
              ),
            ),
            title: Text(
              'Switch Cashier',
              style: AppTextStyles.bodySemiBold(context).copyWith(color: textPrimary),
            ),
            subtitle: Text(
              'Select another cashier profile',
              style: AppTextStyles.caption(context).copyWith(color: textSecondary),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              ref.read(authProvider.notifier).switchCashier();
              context.go(RouteConstants.cashierSelect);
            },
          ),
          Divider(height: 1, color: dividerColor),
          ListTile(
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.accentLight.withValues(alpha: 0.10),
                borderRadius: AppRadius.smallBR,
              ),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                size: 18,
                color: isDark ? AppColors.accentDark : AppColors.accentLight,
              ),
            ),
            title: Text(
              'Switch to Admin',
              style: AppTextStyles.bodySemiBold(context).copyWith(color: isDark ? AppColors.accentDark : AppColors.accentLight),
            ),
            subtitle: Text(
              'Requires admin login',
              style: AppTextStyles.caption(context).copyWith(color: textSecondary),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              context.push(RouteConstants.switchToAdmin);
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.hoverBg,
    required this.textColor,
    required this.iconColor,
    this.isSelected = false,
    this.delay = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color hoverBg;
  final Color textColor;
  final Color iconColor;
  final bool isSelected;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final selectedBg = isDark ? const Color(0xFF6B2C33) : AppColors.secondaryLight;
    final selectedText = Colors.white;

    final currentBg = isSelected ? selectedBg : Colors.transparent;
    final currentText = isSelected ? selectedText : textColor;
    final currentIcon = isSelected ? selectedText : iconColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: currentBg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(14),
          splashColor: currentIcon.withValues(alpha: 0.1),
          highlightColor: hoverBg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 21, color: currentIcon),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: AppTextStyles.body(context).copyWith(color: currentText, fontWeight: isSelected ? FontWeight.w600 : null),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 280.ms,
          delay: delay.ms,
        )
        .slideX(
          begin: -0.06,
          end: 0,
          duration: 280.ms,
          delay: delay.ms,
          curve: Curves.easeOut,
        );
  }
}


