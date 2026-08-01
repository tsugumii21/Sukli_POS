import 'package:sukli_pos/core/theme/app_text_styles.dart';
import 'package:sukli_pos/core/theme/app_colors.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/printer_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/providers/store_provider.dart';
import '../../../../core/utils/receipt_helper.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/order_history_provider.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OrderDetailSheet — draggable bottom sheet showing full order breakdown
// ─────────────────────────────────────────────────────────────────────────────

class OrderDetailSheet extends ConsumerWidget {
  const OrderDetailSheet({super.key, required this.order});

  final OrderCollection order;

  static void show(BuildContext context, OrderCollection order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        // Cap at 80 % of screen height so a simple 1-item order doesn't fill
        // the whole screen, while long orders still scroll comfortably.
        final maxH = MediaQuery.of(ctx).size.height * 0.80;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: OrderDetailSheet(order: order),
        );
      },
    );
  }

  static final _dateFmt = DateFormat('MMMM dd, yyyy  •  hh:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2A1215) : Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimaryDark : AppColors.backgroundLight;
    final cardBg = isDark ? const Color(0xFF5D2832) : Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final maroon = Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryDark : AppColors.secondaryLight;

    final items = order.orderItemsJson
        .map((raw) => jsonDecode(raw) as Map<String, dynamic>)
        .toList();

    // Content-adaptive sheet: shrinks to fit the order, scrolls when tall.
    // Height is capped by the ConstrainedBox in OrderDetailSheet.show().
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // shrink-wrap to content
        children: [
          // ── Drag handle ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textSecondary.withAlpha(80),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          // ── Header bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: AppTextStyles.bodyLarge(context).copyWith(color: textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _dateFmt.format(order.orderedAt),
                        style: AppTextStyles.caption(context).copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                ),
                _StatusChipDetail(status: order.status),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: textSecondary.withAlpha(50),
              indent: 16,
              endIndent: 16),

          // ── Scrollable body (Flexible so it doesn't push past cap) ───
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cashier & Customer info
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Cashier',
                    value: order.cashierName,
                    textSecondary: textSecondary,
                    textPrimary: textPrimary,
                  ),
                  if (order.customerName != null && order.customerName!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.account_circle_outlined,
                      label: 'Customer',
                      value: order.customerName!,
                      textSecondary: textSecondary,
                      textPrimary: textPrimary,
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Items section
                  Text(
                    'Items',
                    style: AppTextStyles.body(context).copyWith(color: textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < items.length; i++) ...[
                          _ItemRow(
                              item: items[i],
                              textPrimary: textPrimary,
                              textSecondary: textSecondary),
                          if (i < items.length - 1)
                            Divider(
                                height: 1,
                                color: textSecondary.withAlpha(40),
                                indent: 16,
                                endIndent: 16),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Summary section
                  Text(
                    'Summary',
                    style: AppTextStyles.body(context).copyWith(color: textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                            label: 'Subtotal',
                            value: CurrencyFormatter.format(order.subtotal),
                            textPrimary: textPrimary,
                            textSecondary: textSecondary),
                        if (order.discountAmount > 0) ...[
                          const SizedBox(height: 6),
                          _SummaryRow(
                            label:
                                'Discount${order.discountReason != null ? ' (${order.discountReason})' : ''}',
                            value:
                                '- ${CurrencyFormatter.format(order.discountAmount)}',
                            textPrimary: const Color(0xFF2E7D32),
                            textSecondary: textSecondary,
                            valueColor: const Color(0xFF2E7D32),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Divider(height: 1, color: textSecondary.withAlpha(40)),
                        const SizedBox(height: 6),
                        _SummaryRow(
                          label: 'Total',
                          value: CurrencyFormatter.format(order.totalAmount),
                          textPrimary: maroon,
                          textSecondary: textSecondary,
                          isBold: true,
                          valueColor: maroon,
                        ),
                        const SizedBox(height: 10),
                        Divider(height: 1, color: textSecondary.withAlpha(40)),
                        const SizedBox(height: 10),
                        _SummaryRow(
                          label: 'Payment',
                          value: _paymentLabel(order.paymentMethod),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(height: 6),
                        _SummaryRow(
                          label: 'Tendered',
                          value: CurrencyFormatter.format(order.amountTendered),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(height: 6),
                        _SummaryRow(
                          label: 'Change',
                          value: CurrencyFormatter.format(order.changeAmount),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reprint button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _onReprint(context, ref),
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: Text(
                        'Reprint Receipt',
                        style: AppTextStyles.bodySemiBold(context),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: maroon,
                        side: BorderSide(color: maroon, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Future<void> _onReprint(BuildContext context, WidgetRef ref) async {
    final printer = ref.read(printerServiceProvider);
    final store = ref.read(currentStoreProvider).value;
    final settings = ref.read(settingsProvider);

    try {
      if (settings.selectedPrinterMac != null && settings.selectedPrinterMac!.isNotEmpty) {
        final success = await printer.printReceipt(
          order,
          paperSize: settings.paperSize,
          autoCut: settings.autoCut,
          storeName: settings.storeName,
          receiptHeader: settings.receiptHeader,
          receiptFooter: settings.receiptFooter,
          macAddress: settings.selectedPrinterMac,
        );
        if (success) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Receipt printed via Bluetooth thermal printer.', style: AppTextStyles.body(context)),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          return;
        }
      }

      if (store != null) {
        await ReceiptHelper.printReceipt(
          order: order,
          store: store,
          paperSize: settings.paperSize,
        );
      } else {
        throw Exception('Store configuration not loaded');
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Print failed: $e', style: AppTextStyles.body(context)),
          backgroundColor: AppColors.errorLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
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
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
    this.onTap,
    this.showEditHint = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback? onTap;
  final bool showEditHint;

  @override
  Widget build(BuildContext context) {
    final rowChild = Row(
      children: [
        Icon(icon, size: 16, color: textSecondary),
        const SizedBox(width: 8),
        Text('$label: ',
            style: AppTextStyles.body(context).copyWith(color: textSecondary)),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body(context).copyWith(color: textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showEditHint) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.edit_outlined,
            size: 14,
            color: textSecondary.withValues(alpha: 0.6),
          ),
        ],
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: rowChild,
        ),
      );
    }

    return rowChild;
  }
}

void _showEditCustomerDialog(
  BuildContext context,
  WidgetRef ref,
  OrderCollection order,
) {
  final controller = TextEditingController(text: order.customerName ?? '');
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final dialogBg = isDark ? AppColors.surfaceDark : AppColors.white;
  final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Edit Customer Name',
        style: GoogleFonts.dmSans(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: 'Enter buyer / customer name',
          hintStyle: TextStyle(color: textPrimary.withValues(alpha: 0.5)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final newName = controller.text.trim();
            Navigator.pop(ctx);

            final isar = ref.read(isarProvider);
            await isar.writeTxn(() async {
              order.customerName = newName.isEmpty ? null : newName;
              await isar.orderCollections.put(order);
            });

            final syncService = ref.read(syncServiceProvider);
            await syncService.addToQueue(
              tableName: 'orders',
              recordSyncId: order.syncId,
              operation: 'update',
              payload: {
                'sync_id': order.syncId,
                if (order.customerName != null) 'customer_name': order.customerName,
                'updated_at': DateTime.now().toUtc().toIso8601String(),
              },
            );

            ref.read(orderHistoryProvider.notifier).refresh();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.primaryDark : AppColors.secondaryLight,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Map<String, dynamic> item;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final name = item['itemName']?.toString() ?? '';
    final variant = item['variantName']?.toString() ?? '';
    final qty = (item['quantity'] as num?)?.toInt() ?? 1;
    final unitPrice = (item['unitPrice'] as num?)?.toDouble() ?? 0.0;
    final subtotal = (item['subtotal'] as num?)?.toDouble() ?? 0.0;
    final rawMods = item['modifiers'];

    double modTotalSum = 0.0;
    final modList = <Map<String, dynamic>>[];
    if (rawMods is List && rawMods.isNotEmpty) {
      for (final m in rawMods) {
        final str = m?.toString().trim() ?? '';
        if (str.isEmpty) continue;
        if (str.contains('|')) {
          final parts = str.split('|');
          final mName = parts[0];
          final mPrice = double.tryParse(parts[1]) ?? 0.0;
          modTotalSum += mPrice;
          modList.add({
            'name': mName,
            'price': mPrice > 0 ? '+₱${mPrice.toStringAsFixed(2)}' : '',
          });
        } else if (str.contains('(+₱')) {
          final parts = str.split('(+₱');
          final mName = parts[0].trim();
          final pStr = parts[1].replaceAll(')', '').trim();
          final mPrice = double.tryParse(pStr) ?? 0.0;
          modTotalSum += mPrice;
          modList.add({
            'name': mName,
            'price': mPrice > 0 ? '+₱${mPrice.toStringAsFixed(2)}' : '',
          });
        } else {
          modList.add({'name': str, 'price': ''});
        }
      }
    }

    final baseProductPrice = (unitPrice - modTotalSum).clamp(0.0, double.infinity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top line: Main Item Name & Base Product Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.body(context).copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (variant.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        variant,
                        style: AppTextStyles.caption(context).copyWith(
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₱${baseProductPrice.toStringAsFixed(2)}',
                style: AppTextStyles.body(context).copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Modifiers (small font, indented, with right-aligned add-on price)
          if (modList.isNotEmpty) ...[
            const SizedBox(height: 4),
            for (final mod in modList) ...[
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 1, bottom: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        mod['name'] as String,
                        style: AppTextStyles.caption(context).copyWith(
                          color: textSecondary.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if ((mod['price'] as String).isNotEmpty)
                      Text(
                        mod['price'] as String,
                        style: AppTextStyles.caption(context).copyWith(
                          color: textSecondary.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],

          const SizedBox(height: 6),
          // Bottom line (Quantity / Item Total)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                qty > 1 ? '₱${unitPrice.toStringAsFixed(2)} × $qty' : 'Qty: $qty',
                style: AppTextStyles.caption(context).copyWith(
                  color: textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                '₱${subtotal.toStringAsFixed(2)}',
                style: AppTextStyles.bodySemiBold(context).copyWith(
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.body(context).copyWith(color: textSecondary)),
        Text(value,
            style: AppTextStyles.body(context).copyWith(color: valueColor ?? textPrimary)),
      ],
    );
  }
}

class _StatusChipDetail extends StatelessWidget {
  const _StatusChipDetail({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = const Color(0xFF2E7D32);
        break;
      case 'voided':
        color = const Color(0xFFC62828);
        break;
      case 'refunded':
        color = const Color(0xFFE65100);
        break;
      default:
        color = const Color(0xFF546E7A);
    }
    final label =
        status.isEmpty ? status : status[0].toUpperCase() + status.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(120), width: 1),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(context).copyWith(color: color),
      ),
    );
  }
}
