import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Standard red-themed confirmation dialog for destructive actions.
/// Use for: clear cart, void order, delete item, delete user, etc.
Future<bool> showDestructiveDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  IconData icon = Icons.warning_amber_rounded,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.largeBR),
      icon: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: AppColors.errorLight.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.errorLight, size: 28),
      ),
      title: Text(title,
        style: AppTextStyles.h3(context),
        textAlign: TextAlign.center),
      content: Text(message,
        style: AppTextStyles.body(context).copyWith(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
        textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      actions: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryLight),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.pillBR),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(cancelLabel,
              style: AppTextStyles.bodySemiBold(context)),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorLight,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.pillBR),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(confirmLabel,
              style: AppTextStyles.bodySemiBold(context)
                .copyWith(color: Colors.white)),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
