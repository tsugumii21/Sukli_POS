import 'dart:convert';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../utils/currency_formatter.dart';
import '../../shared/isar_collections/order_collection.dart';

/// Abstract contract for thermal receipt printing.
abstract class PrinterService {
  /// Generates ESC/POS bytes for the given order receipt.
  Future<List<int>> buildReceiptBytes(
    OrderCollection order, {
    String paperSize = '58mm',
    bool autoCut = true,
    String? storeName,
    String? receiptHeader,
    String? receiptFooter,
  });

  /// Attempts to deliver the receipt to a connected thermal printer.
  Future<bool> printReceipt(
    OrderCollection order, {
    String paperSize = '58mm',
    bool autoCut = true,
    String? storeName,
    String? receiptHeader,
    String? receiptFooter,
  });
}

/// Concrete implementation using [esc_pos_utils_plus] for byte generation.
class ThermalPrinterService implements PrinterService {
  ThermalPrinterService._();
  static final ThermalPrinterService instance = ThermalPrinterService._();

  static final _dateFormat = DateFormat('MMM dd, yyyy  hh:mm a');

  @override
  Future<List<int>> buildReceiptBytes(
    OrderCollection order, {
    String paperSize = '58mm',
    bool autoCut = true,
    String? storeName,
    String? receiptHeader,
    String? receiptFooter,
  }) async {
    final profile = await CapabilityProfile.load();
    final is58 = paperSize.contains('58');
    final pSize = is58 ? PaperSize.mm58 : PaperSize.mm80;
    final gen = Generator(pSize, profile);
    final bytes = <int>[];

    final dateStr = _dateFormat.format(order.orderedAt);
    final headerTitle = receiptHeader?.isNotEmpty == true
        ? receiptHeader!
        : (storeName?.isNotEmpty == true ? storeName! : AppConstants.appName);

    // ── Header ────────────────────────────────────────────────────────────
    bytes.addAll(gen.text(
      headerTitle.toUpperCase(),
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: is58 ? PosTextSize.size1 : PosTextSize.size2,
        width: is58 ? PosTextSize.size1 : PosTextSize.size2,
      ),
    ));
    bytes.addAll(gen.text(
      'OFFICIAL RECEIPT',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ));
    bytes.addAll(gen.hr());
    bytes.addAll(gen.text(
      dateStr,
      styles: const PosStyles(align: PosAlign.center),
    ));

    // Custom Order Number with Cashier Initials (e.g. #0043-JD_123)
    bytes.addAll(gen.text(
      'Order: ${order.orderNumber}',
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(gen.text(
      'Cashier: ${order.cashierName}',
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(gen.hr());

    // ── Items ─────────────────────────────────────────────────────────────
    final maxLabelLen = is58 ? 14 : 24;
    final col1Width = is58 ? 7 : 8;
    final col2Width = is58 ? 5 : 4;

    for (final jsonStr in order.orderItemsJson) {
      final item = jsonDecode(jsonStr) as Map<String, dynamic>;
      final name = (item['itemName'] as String?) ?? '';
      final qty = (item['quantity'] as int?) ?? 1;
      final variant = item['variantName'] as String?;
      final subtotal = ((item['subtotal'] as num?) ?? 0).toDouble();

      final label = variant != null ? '$name ($variant)' : name;
      final truncated = label.length > maxLabelLen
          ? '${label.substring(0, maxLabelLen - 3)}...'
          : label;

      bytes.addAll(gen.row([
        PosColumn(text: '$truncated x$qty', width: col1Width),
        PosColumn(
          text: CurrencyFormatter.format(subtotal),
          width: col2Width,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));
    }

    bytes.addAll(gen.hr());

    // ── Totals ────────────────────────────────────────────────────────────
    final labelWidth = is58 ? 6 : 7;
    final valWidth = is58 ? 6 : 5;

    bytes.addAll(gen.row([
      PosColumn(text: 'Subtotal', width: labelWidth),
      PosColumn(
        text: CurrencyFormatter.format(order.subtotal),
        width: valWidth,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]));

    if (order.discountAmount > 0) {
      bytes.addAll(gen.row([
        PosColumn(text: 'Discount', width: labelWidth),
        PosColumn(
          text: '-${CurrencyFormatter.format(order.discountAmount)}',
          width: valWidth,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));
    }

    bytes.addAll(gen.row([
      PosColumn(
        text: 'TOTAL',
        width: labelWidth,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: CurrencyFormatter.format(order.totalAmount),
        width: valWidth,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]));

    bytes.addAll(gen.hr());

    // ── Payment ───────────────────────────────────────────────────────────
    bytes.addAll(
      gen.text('Payment: ${order.paymentMethod.toUpperCase()}'),
    );
    bytes.addAll(gen.row([
      PosColumn(text: 'Tendered', width: labelWidth),
      PosColumn(
        text: CurrencyFormatter.format(order.amountTendered),
        width: valWidth,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]));

    if (order.changeAmount > 0) {
      bytes.addAll(gen.row([
        PosColumn(text: 'Change', width: labelWidth),
        PosColumn(
          text: CurrencyFormatter.format(order.changeAmount),
          width: valWidth,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));
    }

    bytes.addAll(gen.hr());

    // ── Footer ────────────────────────────────────────────────────────────
    final footerMsg = receiptFooter?.isNotEmpty == true
        ? receiptFooter!
        : 'Thank you for your order!';
    bytes.addAll(gen.text(
      footerMsg,
      styles: const PosStyles(align: PosAlign.center),
    ));
    bytes.addAll(gen.text(
      'Powered by Sukli POS',
      styles: const PosStyles(align: PosAlign.center),
    ));
    bytes.addAll(gen.feed(3));

    if (autoCut) {
      bytes.addAll(gen.cut());
    }

    return bytes;
  }

  @override
  Future<bool> printReceipt(
    OrderCollection order, {
    String paperSize = '58mm',
    bool autoCut = true,
    String? storeName,
    String? receiptHeader,
    String? receiptFooter,
  }) async {
    try {
      await buildReceiptBytes(
        order,
        paperSize: paperSize,
        autoCut: autoCut,
        storeName: storeName,
        receiptHeader: receiptHeader,
        receiptFooter: receiptFooter,
      );
      return false; // ESC/POS bytes generated cleanly
    } catch (_) {
      return false;
    }
  }
}

/// Riverpod provider exposing the singleton [ThermalPrinterService].
final printerServiceProvider = Provider<PrinterService>(
  (_) => ThermalPrinterService.instance,
);
