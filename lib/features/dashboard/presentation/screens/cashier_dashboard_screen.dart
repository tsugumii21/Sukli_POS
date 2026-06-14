import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/order_number_helper.dart';
import '../../../../shared/providers/sync_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
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
                  // Avatar circle
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
                  // Badge sits at its natural width; Expanded guarantees no bleed
                  SyncStatusBadge(
                    isOnline: isOnline,
                    isSyncing: isSyncing,
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

                // ── Favorites / Quick Picks Section ──────────────────────────
                if (data.favorites.isNotEmpty) ...[
                  Text(
                    'Quick Picks',
                    style: AppTextStyles.h3(context).copyWith(color: textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Stack adds a right-edge fade so the list naturally trails off.
                  Stack(
                    children: [
                      SizedBox(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: data.favorites.length,
                          itemBuilder: (context, index) {
                            final item = data.favorites[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
                                  style: AppTextStyles.bodySemiBold(context).copyWith(color: textPrimary),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Right-edge fade gradient
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: Container(
                            width: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [bg.withAlpha(0), bg],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideX(begin: 0.1, end: 0),
                  const SizedBox(height: AppSpacing.xl),
                ],

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
                    final shortNum = OrderNumberHelper.toShort(rawNum);
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
                                              '${order.orderedAt.hour}:${order.orderedAt.minute.toString().padLeft(2, '0')}',
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
    final drawerBg = isDark ? const Color(0xFF2A1215) : Colors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final itemHoverBg =
        isDark ? Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : AppColors.textPrimaryLight : const Color(0xFFF9F0F1);
    final initial = cashierName.isNotEmpty ? cashierName[0].toUpperCase() : '?';

    return Drawer(
      backgroundColor: drawerBg,
      // Slight rounded right edge for a modern feel.
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Profile header ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: maroon,
              borderRadius: BorderRadius.only(
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
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
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

                // Name
                Text(
                  cashierName,
                  style: AppTextStyles.h3(context).copyWith(color: Colors.white),
                ).animate().fadeIn(duration: 350.ms, delay: 80.ms),

                const SizedBox(height: 6),

                // Role chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Cashier',
                    style: AppTextStyles.body(context).copyWith(color: Colors.white.withValues(alpha:0.9),
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

          // ── Nav section label ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Text(
              'MENU',
              style: AppTextStyles.body(context).copyWith(
                color: isDark ? AppColors.textSecondaryDark : textPrimary.withValues(alpha: 0.35),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 160.ms),

          const SizedBox(height: 4),

          // ── Nav items ──────────────────────────────────────────────────
          _NavItem(
            icon: Icons.grid_view_rounded,
            label: 'Home',
            delay: 180,
            onTap: () => Navigator.pop(context),
            hoverBg: itemHoverBg,
            textColor: textPrimary,
          ),
          _NavItem(
            icon: Icons.point_of_sale_rounded,
            label: 'New Order',
            delay: 220,
            onTap: () {
              Navigator.pop(context);
              context.push(RouteConstants.newOrder);
            },
            hoverBg: itemHoverBg,
            textColor: textPrimary,
          ),
          _NavItem(
            icon: Icons.receipt_long_rounded,
            label: 'Order History',
            delay: 260,
            onTap: () {
              Navigator.pop(context);
              context.push(RouteConstants.orderHistory);
            },
            hoverBg: itemHoverBg,
            textColor: textPrimary,
          ),
          const Spacer(),

          // ── Footer divider ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: textPrimary.withValues(alpha: 0.08),
              height: 1,
            ),
          ),

          const SizedBox(height: 8),

          // ── Theme toggle ───────────────────────────────────────────────
          _ThemeToggleTile(
            textColor: textPrimary,
            hoverBg: itemHoverBg,
          ),

          const Divider(height: 1),

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
              style: AppTextStyles.bodySemiBold(context).copyWith(color: isDark ? AppColors.accentDark :AppColors.accentLight),
            ),
            subtitle: Text(
              'Requires admin login',
              style: AppTextStyles.caption(context).copyWith(color: textSecondary),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context); // close drawer first
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

/// A single tappable row used in [_DashboardDrawer].
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.hoverBg,
    required this.textColor,
    this.delay = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color hoverBg;
  final Color textColor;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final ic = textColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(14),
          splashColor: ic.withValues(alpha: 0.1),
          highlightColor: hoverBg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 21, color: ic),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: AppTextStyles.body(context).copyWith(color: textColor),
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

/// Theme toggle row — sits above Logout in the drawer footer.
/// Tapping anywhere on the row (or the switch) toggles light/dark mode.
class _ThemeToggleTile extends ConsumerWidget {
  const _ThemeToggleTile({
    required this.textColor,
    required this.hoverBg,
  });

  final Color textColor;
  final Color hoverBg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final maroon = Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryDark : AppColors.secondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(themeProvider.notifier).toggle();
          },
          borderRadius: BorderRadius.circular(14),
          splashColor: textColor.withValues(alpha: 0.08),
          highlightColor: hoverBg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  size: 21,
                  color: isDark ? AppColors.accentDarkLight : maroon,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isDark ? 'Dark Mode' : 'Light Mode',
                    style: AppTextStyles.body(context).copyWith(color: textColor),
                  ),
                ),
                Switch.adaptive(
                  value: isDark,
                  onChanged: (_) {
                    HapticFeedback.lightImpact();
                    ref.read(themeProvider.notifier).toggle();
                  },
                  activeThumbColor: AppColors.accentDark,
                  activeTrackColor: AppColors.accentDark.withValues(alpha: 0.5),
                  inactiveThumbColor: maroon,
                  inactiveTrackColor: maroon.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

