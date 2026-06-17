import os

file_path = r'r:\Code\Sukli POS\sukli_pos\lib\features\dashboard\presentation\screens\admin_dashboard_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

start_marker = 'class _AdminNavDrawer extends ConsumerWidget {'

start_idx = content.find(start_marker)

if start_idx != -1:
    new_drawer_code = '''class _AdminNavDrawer extends ConsumerWidget {
  const _AdminNavDrawer({required this.adminEmail});
  final String adminEmail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final _maroon = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    
    // User requested dark mode colors:
    final drawerBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final headerBg = isDark ? const Color(0xFF2C2C2E) : _maroon;
    final textPrimary = isDark ? const Color(0xFFF5F5F5) : AppColors.textPrimaryLight;
    final iconPrimary = isDark ? const Color(0xFFE8D5C4) : AppColors.textPrimaryLight;
    final textSecondary = isDark ? const Color(0xFF8E8E93) : AppColors.textSecondaryLight;
    final dividerColor = isDark ? const Color(0xFF3A3A3C) : AppColors.textPrimaryLight.withValues(alpha: 0.08);
    final itemHoverBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F0F1);
    
    final currentPath = GoRouterState.of(context).uri.path;
    final initial = adminEmail.isNotEmpty ? adminEmail[0].toUpperCase() : 'A';

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
              borderRadius: const BorderRadius.only(topRight: Radius.circular(28)),
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
                const SizedBox(height: 14),
                Text(
                  adminEmail.isNotEmpty ? adminEmail : 'Admin',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge(context).copyWith(color: Colors.white),
                ).animate().fadeIn(duration: 350.ms, delay: 80.ms),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Administrator',
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
              'NAVIGATION',
              style: AppTextStyles.body(context).copyWith(
                color: textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 160.ms),
          const SizedBox(height: 4),
          _AdminNavItem(
            icon: Icons.dashboard_rounded,
            label: 'Home',
            delay: 180,
            isSelected: currentPath == RouteConstants.adminHome,
            onTap: () {
              Navigator.pop(context);
              if (currentPath != RouteConstants.adminHome) {
                context.push(RouteConstants.adminHome);
              }
            },
            hoverBg: itemHoverBg,
            textColor: textPrimary,
            iconColor: iconPrimary,
          ),
          _AdminNavItem(
            icon: Icons.people_outline_rounded,
            label: 'Users',
            delay: 200,
            isSelected: currentPath == RouteConstants.adminUsers,
            onTap: () {
              Navigator.pop(context);
              if (currentPath != RouteConstants.adminUsers) {
                context.push(RouteConstants.adminUsers);
              }
            },
            hoverBg: itemHoverBg,
            textColor: textPrimary,
            iconColor: iconPrimary,
          ),
          _AdminNavItem(
            icon: Icons.restaurant_menu_rounded,
            label: 'Menu',
            delay: 220,
            isSelected: currentPath == RouteConstants.adminMenuItems,
            onTap: () {
              Navigator.pop(context);
              if (currentPath != RouteConstants.adminMenuItems) {
                context.push(RouteConstants.adminMenuItems);
              }
            },
            hoverBg: itemHoverBg,
            textColor: textPrimary,
            iconColor: iconPrimary,
          ),
          _AdminNavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Reports',
            delay: 300,
            isSelected: currentPath == RouteConstants.adminReports,
            onTap: () {
              Navigator.pop(context);
              if (currentPath != RouteConstants.adminReports) {
                context.push(RouteConstants.adminReports);
              }
            },
            hoverBg: itemHoverBg,
            textColor: textPrimary,
            iconColor: iconPrimary,
          ),
          _AdminNavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            delay: 340,
            isSelected: currentPath == RouteConstants.adminSettings,
            onTap: () {
              Navigator.pop(context);
              if (currentPath != RouteConstants.adminSettings) {
                context.push(RouteConstants.adminSettings);
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
          _AdminThemeToggleTile(
            textColor: textPrimary,
            hoverBg: itemHoverBg,
          ),
          Divider(height: 1, color: dividerColor),
          ListTile(
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.successLight.withValues(alpha: 0.12),
                borderRadius: AppRadius.smallBR,
              ),
              child: Icon(
                Icons.point_of_sale_rounded,
                size: 18,
                color: isDark ? AppColors.successDark : AppColors.successLight,
              ),
            ),
            title: Text(
              'Switch to Cashier',
              style: AppTextStyles.bodySemiBold(context).copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
            subtitle: Text(
              'Go to cashier login screen',
              style: AppTextStyles.caption(context).copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go(RouteConstants.cashierSelect);
            },
          ),
          _AdminNavItem(
            icon: Icons.power_settings_new_rounded,
            label: 'Logout',
            delay: 0,
            iconColor: isDark ? const Color(0xFFFF453A) : AppColors.errorLight,
            textColor: isDark ? const Color(0xFFFF453A) : AppColors.errorLight,
            hoverBg: AppColors.errorLight.withValues(alpha: 0.07),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(adminAuthProvider.notifier).signOut();
              if (context.mounted) context.go(RouteConstants.adminLogin);
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

class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.hoverBg,
    required this.textColor,
    this.iconColor,
    this.isSelected = false,
    this.delay = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color hoverBg;
  final Color textColor;
  final Color? iconColor;
  final bool isSelected;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ic = iconColor ?? textColor;
    
    final selectedBg = isDark ? const Color(0xFF6B2C33) : AppColors.secondaryLight;
    final selectedText = Colors.white;

    final currentBg = isSelected ? selectedBg : Colors.transparent;
    final currentText = isSelected ? selectedText : textColor;
    final currentIcon = isSelected ? selectedText : ic;

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
    ).animate().fadeIn(duration: 280.ms, delay: delay.ms).slideX(
          begin: -0.06,
          end: 0,
          duration: 280.ms,
          delay: delay.ms,
          curve: Curves.easeOut,
        );
  }
}

class _AdminThemeToggleTile extends ConsumerWidget {
  const _AdminThemeToggleTile({
    required this.textColor,
    required this.hoverBg,
  });

  final Color textColor;
  final Color hoverBg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final _maroon = Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryDark : AppColors.secondaryLight;

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
                  color: isDark ? const Color(0xFFE8D5C4) : _maroon,
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
                  activeTrackColor: isDark ? const Color(0xFF6B2C33) : AppColors.accentDark.withValues(alpha: 0.5),
                  inactiveThumbColor: _maroon,
                  inactiveTrackColor: _maroon.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
'''
    content = content[:start_idx] + new_drawer_code
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Replaced admin dashboard drawer.")
else:
    print("Could not find start marker.")
