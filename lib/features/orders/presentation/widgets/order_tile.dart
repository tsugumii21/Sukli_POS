import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/providers/active_role_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/order_number_helper.dart';
import '../../../../shared/isar_collections/order_collection.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OrderTile — single card in the order history list
// ─────────────────────────────────────────────────────────────────────────────

class OrderTile extends ConsumerWidget {
  const OrderTile({
    super.key,
    required this.order,
    required this.onTap,
  });

  final OrderCollection order;
  final VoidCallback onTap;

  static final _dateFmt = DateFormat("h:mm a '•' MMM d, yyyy");

  /// Shows time and date (e.g. 9:23 AM • Jul 23, 2026).
  static String _timeLabel(DateTime dt) {
    return _dateFmt.format(dt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(activeRoleProvider) == ActiveRole.admin;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : const Color(0xFF6B6B6B);
    final totalColor = isDark ? AppColors.white : AppColors.secondaryLight;

    final statusColor = _statusColor(order.status);
    final payIcon = _paymentIcon(order.paymentMethod);
    final payLabel = _paymentLabel(order.paymentMethod);
    final timeLabel = _timeLabel(order.orderedAt);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      splashColor: isDark ? AppColors.accentDark.withValues(alpha: 0.08) : AppColors.accentLight.withValues(alpha: 0.08),
      highlightColor: isDark ? AppColors.accentDark.withValues(alpha: 0.04) : AppColors.accentLight.withValues(alpha: 0.04),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border:
              isDark ? Border.all(color: AppColors.borderDark, width: 1) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: order number (primary) + relative time ───────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      OrderNumberHelper.toShort(
                        order.orderNumber,
                        cashierName: order.cashierName,
                        isAdmin: isAdmin,
                      ),
                      style: AppTextStyles.bodySemiBold(context).copyWith(
                        color: textPrimary,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeLabel,
                    style: AppTextStyles.caption(context)
                        .copyWith(color: textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Divider(
                height: 1,
                color:
                    isDark ? AppColors.borderDark : Colors.black.withAlpha(12),
              ),
              const SizedBox(height: 10),

              // ── Row 2: payment method (left) + total + status (right) ───
              Row(
                children: [
                  // Subtle payment icon + label — no background chip
                  Icon(payIcon, size: 14, color: textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    payLabel,
                    style: AppTextStyles.caption(context)
                        .copyWith(color: textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    '₱${order.totalAmount.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: totalColor,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge — aligned with price on the right
                  _StatusChip(status: order.status, color: statusColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF2E7D32);
      case 'voided':
        return const Color(0xFFC62828);
      case 'refunded':
        return const Color(0xFFE65100);
      default:
        return const Color(0xFF546E7A);
    }
  }

  IconData _paymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.payments_outlined;
      case 'gcash':
        return Icons.smartphone_rounded;
      default:
        return Icons.credit_card_rounded;
    }
  }

  String _paymentLabel(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'gcash':
        return 'GCash';
      default:
        return 'Other';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status chip
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.color});

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(51), // 20 % opacity
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label(status),
        style: AppTextStyles.captionMedium(context).copyWith(
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _label(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
