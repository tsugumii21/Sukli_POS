import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:sukli_pos/core/theme/app_text_styles.dart';

/// CategoryPill — Horizontal filter chip for menu categories.
/// No emoji is rendered; category name text only.
class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isSecondary = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = AppColors.secondary(context);
    final unselectedBg = isSecondary
        ? Colors.transparent
        : (isDark ? AppColors.surfaceDarkElevated : AppColors.cardLight);
    final selectedText = AppColors.white;
    final unselectedText =
        isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight;

    final padding = isSecondary
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    final textStyle = isSecondary
        ? AppTextStyles.body(context).copyWith(fontSize: 13)
        : AppTextStyles.body(context);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(99),
      splashColor: isDark ? AppColors.accentDark.withValues(alpha: 0.08) : AppColors.accentLight.withValues(alpha: 0.08),
      highlightColor: isDark ? AppColors.accentDark.withValues(alpha: 0.04) : AppColors.accentLight.withValues(alpha: 0.04),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isSecondary
                    ? (isDark ? AppColors.borderDark : AppColors.textSecondaryLight.withValues(alpha: 0.2))
                    : Colors.black.withValues(alpha: 0.06)),
            width: 1,
          ),
          boxShadow: isSelected && !isSecondary
              ? [
                  BoxShadow(
                    color: selectedBg.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: textStyle.copyWith(color: isSelected ? selectedText : unselectedText),
        ),
      ),
    );
  }
}

