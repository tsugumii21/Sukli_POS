import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/isar_collections/user_collection.dart';

/// CashierCard — displays a single cashier in the selection grid.
class CashierCard extends StatefulWidget {
  const CashierCard({
    super.key,
    required this.cashier,
    required this.onTap,
  });

  final UserCollection cashier;
  final VoidCallback onTap;

  @override
  State<CashierCard> createState() => _CashierCardState();
}

class _CashierCardState extends State<CashierCard> {
  bool _isPressed = false;

  String get _initial => widget.cashier.name.isNotEmpty
      ? widget.cashier.name[0].toUpperCase()
      : '?';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final avatarBg = isDark ? AppColors.primaryDark : AppColors.accentLight;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppRadius.largeBR,
            boxShadow: AppShadow.level2,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
              horizontal: AppSpacing.md,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar circle
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: avatarBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _initial,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DMSans',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Cashier name
                Text(
                  widget.cashier.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DMSans',
                  ),
                ),
                const SizedBox(height: 4),

                // Caption
                Text(
                  'Tap to login',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontFamily: 'DMSans',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
