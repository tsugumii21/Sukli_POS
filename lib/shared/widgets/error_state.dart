import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';

/// A highly polished error state widget with a retry callback.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.onRetry,
    this.message,
    this.title = 'Something went wrong',
  });

  final VoidCallback onRetry;
  final String? message;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon with subtle ripple effect
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: errorColor,
              ),
            ).animate().shake(
                  duration: AppDuration.slow,
                  curve: AppCurve.standard,
                ),
            const SizedBox(height: AppSpacing.lg),
            // Error title
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3(context).copyWith(
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: AppDuration.medium),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              // Error description
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary(context).copyWith(
                  color: textSecondary,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: AppDuration.medium),
            ],
            const SizedBox(height: AppSpacing.lg),
            // Retry Button
            AppPrimaryButton(
              label: 'Try Again',
              onPressed: onRetry,
              width: 180,
              icon: Icons.refresh_rounded,
            ).animate().fadeIn(delay: 300.ms, duration: AppDuration.medium).slideY(
                  begin: 0.1,
                  end: 0,
                  duration: AppDuration.medium,
                  curve: AppCurve.standard,
                ),
          ],
        ),
      ),
    );
  }
}
