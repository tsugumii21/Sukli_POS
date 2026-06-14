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
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = AppColors.secondary(context);
    final unselectedBg =
        isDark ? AppColors.surfaceDarkElevated : AppColors.cardLight;
    final selectedText = AppColors.white;
    final unselectedText =
        isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight;

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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(99),
          border: isSelected
              ? null
              : Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: isSelected
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
          style: AppTextStyles.body(context).copyWith(color: isSelected ? selectedText :unselectedText),
        ),
      ),
    );
  }
}
