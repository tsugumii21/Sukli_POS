import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// VoidSheet — A DraggableScrollableSheet bottom sheet for processing
/// a void on a completed order.
///
/// Returns the reason String on confirm, or null if dismissed.
class VoidSheet extends StatefulWidget {
  const VoidSheet({
    super.key,
    required this.order,
    this.scrollController,
  });

  final OrderCollection order;
  final ScrollController? scrollController;

  static Future<String?> show(
    BuildContext context,
    OrderCollection order,
  ) {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.40,
          maxChildSize: 0.95,
          snap: true,
          snapSizes: const [0.55, 0.95],
          builder: (_, scrollCtrl) => VoidSheet(
            order: order,
            scrollController: scrollCtrl,
          ),
        ),
      ),
    );
  }

  @override
  State<VoidSheet> createState() => _VoidSheetState();
}

class _VoidSheetState extends State<VoidSheet> {
  final _reasonCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_reasonCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;
    final borderCol = isDark ? AppColors.borderDark : AppColors.primaryLight;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: AppRadius.large),
        boxShadow: AppShadow.level4,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
          children: [
            // ── Handle bar ───────────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.only(
                    top: AppSpacing.sm, bottom: AppSpacing.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: AppRadius.pillBR,
                ),
              ),
            ),

            // ── Header ───────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: errorColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.block_flipped, color: errorColor, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Void Order',
                        style: AppTextStyles.h3(context),
                      ),
                      Text(
                        widget.order.orderNumber,
                        style: AppTextStyles.captionSecondary(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Order summary card ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppRadius.mediumBR,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SummaryPair(
                    label: 'Cashier',
                    value: widget.order.cashierName,
                    textSecondary: textSecondary,
                    textPrimary: textPrimary,
                  ),
                  Container(width: 1, height: 32, color: borderCol),
                  _SummaryPair(
                    label: 'Payment',
                    value: _capitalize(widget.order.paymentMethod),
                    textSecondary: textSecondary,
                    textPrimary: textPrimary,
                  ),
                  Container(width: 1, height: 32, color: borderCol),
                  _SummaryPair(
                    label: 'Total',
                    value: CurrencyFormatter.format(widget.order.totalAmount),
                    textSecondary: textSecondary,
                    textPrimary: errorColor,
                    bold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Reason field ──────────────────────────────────────────
            _SectionLabel(
                label: 'REASON FOR VOID (REQUIRED)', textSecondary: textSecondary),
            AppTextField(
              controller: _reasonCtrl,
              maxLines: 3,
              hint: 'e.g. Order entered by mistake / duplicate order',
              onChanged: (v) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Reason is required';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Summary warning line ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.08),
                borderRadius: AppRadius.mediumBR,
                border: Border.all(color: errorColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: errorColor),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Warning: Voiding this order will revert all calculations and mark it as voided. This action cannot be undone.',
                      style: AppTextStyles.caption(context).copyWith(
                        color: errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Buttons ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _reasonCtrl.text.trim().isEmpty ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorColor,
                  disabledBackgroundColor: errorColor.withValues(alpha: 0.4),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
                ),
                child: Text(
                  'Continue to Admin Verification',
                  style: AppTextStyles.bodyMedium(context)
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                  top: AppSpacing.xs, bottom: AppSpacing.md),
              child: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  style: TextButton.styleFrom(
                    foregroundColor: textSecondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.mediumBR),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyMedium(context)
                        .copyWith(color: textSecondary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.textSecondary});
  final String label;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.caption(context).copyWith(
          color: textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SummaryPair extends StatelessWidget {
  const _SummaryPair({
    required this.label,
    required this.value,
    required this.textSecondary,
    required this.textPrimary,
    this.bold = false,
  });
  final String label;
  final String value;
  final Color textSecondary;
  final Color textPrimary;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.caption(context).copyWith(color: textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: bold
              ? AppTextStyles.bodySemiBold(context).copyWith(color: textPrimary)
              : AppTextStyles.bodySemiBold(context)
                  .copyWith(color: textPrimary),
        ),
      ],
    );
  }
}
