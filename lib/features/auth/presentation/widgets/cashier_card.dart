import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import 'package:sukli_pos/core/theme/app_text_styles.dart';

/// CashierCard — displays a single cashier in the selection grid.
/// Redesigned with Plus Jakarta Sans and Inter for a modern look.
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

    // Modern gradient for avatar
    final avatarGradient = isDark
        ? LinearGradient(colors: [AppColors.secondaryDark, AppColors.primaryDarkVariant])
        : LinearGradient(colors: [AppColors.secondaryLight, AppColors.accentLight]);

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      splashColor: isDark ? AppColors.accentDark.withValues(alpha: 0.08) : AppColors.accentLight.withValues(alpha: 0.08),
      highlightColor: isDark ? AppColors.accentDark.withValues(alpha: 0.04) : AppColors.accentLight.withValues(alpha: 0.04),
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(28), // Softer corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xl,
              horizontal: AppSpacing.md,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar circle with gradient and white border
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: avatarGradient,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryDark : AppColors.secondaryLight.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _initial,
                      style: AppTextStyles.priceDisplay(context).copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Cashier name: Plus Jakarta Sans
                Text(
                  widget.cashier.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge(context).copyWith(color: textPrimary),
                ),
                const SizedBox(height: 6),

                // Caption: Inter
                Text(
                  'Tap to login'.toUpperCase(),
                  style: AppTextStyles.body(context).copyWith(color: textSecondary.withValues(alpha:0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
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
