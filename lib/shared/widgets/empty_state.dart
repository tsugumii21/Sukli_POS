import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';

/// A highly polished empty state display for lists and panels.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon wrapper with smooth background circle
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: primaryColor,
              ),
            ).animate().scale(
                  duration: AppDuration.medium,
                  curve: AppCurve.standard,
                ),
            const SizedBox(height: AppSpacing.lg),
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3(context).copyWith(
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: AppDuration.medium),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              // Subtitle
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary(context).copyWith(
                  color: textSecondary,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: AppDuration.medium),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              // Action Button
              AppPrimaryButton(
                label: actionLabel!,
                onPressed: onAction!,
                width: 220,
              ).animate().fadeIn(delay: 300.ms, duration: AppDuration.medium).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: AppDuration.medium,
                    curve: AppCurve.standard,
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
