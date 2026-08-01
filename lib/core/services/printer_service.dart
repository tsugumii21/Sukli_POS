import 'dart:convert';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import 'package:permission_handler/permission_handler.dart';

import '../constants/app_constants.dart';
import '../utils/currency_formatter.dart';
import '../../shared/isar_collections/order_collection.dart';

/// Abstract contract for thermal receipt printing.
abstract class PrinterService {
  /// Requests necessary Bluetooth runtime permissions (Nearby Devices / Location).
  Future<bool> requestBluetoothPermissions();

  /// Returns a list of paired Bluetooth devices on the phone.
  Future<List<BluetoothInfo>> getPairedDevices();

  /// Returns whether Bluetooth is currently enabled on the device.
  Future<bool> isBluetoothEnabled();

  /// Connects to a Bluetooth printer using its MAC address.
  Future<bool> connect(String macAddress);

  /// Disconnects from the currently connected Bluetooth printer.
  Future<bool> disconnect();

  /// Checks if a Bluetooth printer is currently connected.
  Future<bool> isConnected();

  /// Generates ESC/POS bytes for the given order receipt.
  Future<List<int>> buildReceiptBytes(
    OrderCollection order, {
    String paperSize = '58mm',
    bool autoCut = true,
    String? storeName,
    String? receiptHeader,
    String? receiptFooter,
  });

  /// Sends receipt bytes to the connected Bluetooth thermal printer.
  Future<bool> printReceipt(
    OrderCollection order, {
    String paperSize = '58mm',
    bool autoCut = true,
    String? storeName,
    String? receiptHeader,
    String? receiptFooter,
    String? macAddress,
  });

  /// Prints a test alignment page to verify thermal printer output.
  Future<bool> printTestReceipt({
    String paperSize = '58mm',
    String? storeName,
    String? macAddress,
  });
}

/// Concrete implementation using [esc_pos_utils_plus] and [PrintBluetoothThermal].
class ThermalPrinterService implements PrinterService {
  ThermalPrinterService._();
  static final ThermalPrinterService instance = ThermalPrinterService._();

  static final _dateFormat = DateFormat('MMM dd, yyyy  hh:mm a');

  String _formatForPrinter(double amount) {
    return 'P${amount.toStringAsFixed(2)}';
  }

  @override
  Future<bool> requestBluetoothPermissions() async {
    try {
      final statuses = await [
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
      ].request();

      final connectOk = statuses[Permission.bluetoothConnect]?.isGranted ?? true;
      final scanOk = statuses[Permission.bluetoothScan]?.isGranted ?? true;
      return connectOk && scanOk;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<BluetoothInfo>> getPairedDevices() async {
    try {
      return await PrintBluetoothThermal.pairedBluetooths
          .timeout(const Duration(seconds: 2), onTimeout: () => []);
    } catch (e) {
      debugPrint('[PrinterService] Failed to fetch paired devices: $e');
      return [];
    }
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled
          .timeout(const Duration(seconds: 1), onTimeout: () => false);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> connect(String macAddress) async {
    if (macAddress.trim().isEmpty) return false;
    try {
      final isAlreadyConnected = await isConnected();
      if (isAlreadyConnected) return true;

      // Clean up any stale or hanging Android SPP socket handle before connecting
      try {
        await PrintBluetoothThermal.disconnect
            .timeout(const Duration(seconds: 1), onTimeout: () => false);
      } catch (_) {}

      return await PrintBluetoothThermal.connect(macPrinterAddress: macAddress)
          .timeout(const Duration(seconds: 6), onTimeout: () => false);
    } catch (e) {
      debugPrint('[PrinterService] Connection failed to $macAddress: $e');
      return false;
    }
  }

  @override
  Future<bool> disconnect() async {
    try {
      return await PrintBluetoothThermal.disconnect
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      return await PrintBluetoothThermal.connectionStatus
          .timeout(const Duration(milliseconds: 800), onTimeout: () => false);
    } catch (_) {
      return false;
    }
  }

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
    if (order.customerName != null && order.customerName!.trim().isNotEmpty) {
      bytes.addAll(gen.text(
        'Customer: ${order.customerName}',
        styles: const PosStyles(bold: true),
      ));
    }
    bytes.addAll(gen.hr());

    // ── Items ─────────────────────────────────────────────────────────────
    final maxLabelLen = is58 ? 14 : 24;
    final valWidth = is58 ? 5 : 6;
    final labelWidth = 12 - valWidth;

    for (final jsonStr in order.orderItemsJson) {
      try {
        if (jsonStr.trim().isEmpty) continue;
        final decoded = jsonDecode(jsonStr);
        if (decoded is! Map) continue;
        final item = Map<String, dynamic>.from(decoded);

        // Rule 1: Safe quantity parsing
        final qty = (item['quantity'] as num?)?.toInt()
            ?? (item['qty'] as num?)?.toInt()
            ?? 1;

        // Rule 2: Safe price parsing
        final unitPrice = (item['unitPrice'] as num?)?.toDouble()
            ?? (item['unit_price'] as num?)?.toDouble()
            ?? (item['price'] as num?)?.toDouble()
            ?? 0.0;

        final subtotal = (item['subtotal'] as num?)?.toDouble()
            ?? (item['totalPrice'] as num?)?.toDouble()
            ?? (item['total_price'] as num?)?.toDouble()
            ?? (unitPrice * qty);

        // Rule 3: Safe string key fallback
        final name = (item['itemName'] as String?)
            ?? (item['productName'] as String?)
            ?? (item['name'] as String?)
            ?? 'Item';

        final variant = (item['variant'] as String?)
            ?? (item['variantName'] as String?)
            ?? '';

        final label = variant.isNotEmpty ? '$name ($variant)' : name;
        final truncated = label.length > maxLabelLen
            ? '${label.substring(0, maxLabelLen - 3)}...'
            : label;

        bytes.addAll(gen.row([
          PosColumn(text: '$qty x $truncated', width: labelWidth),
          PosColumn(
            text: _formatForPrinter(subtotal),
            width: valWidth,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]));

        final rawMods = item['modifiers'] ?? item['selectedAddonNames'];
        if (rawMods is List && rawMods.isNotEmpty) {
          final modsStr = rawMods
              .map((m) => m?.toString().trim() ?? '')
              .where((s) => s.isNotEmpty)
              .join(', ');
          if (modsStr.isNotEmpty) {
            bytes.addAll(gen.text(
              '  + $modsStr',
              styles: const PosStyles(align: PosAlign.left),
            ));
          }
        }
      } catch (e) {
        // Rule 4: Log real error, continue next item
        debugPrint('RECEIPT BUILD ERROR on item "$jsonStr": $e');
        continue;
      }
    }

    bytes.addAll(gen.hr());

    // ── Totals ────────────────────────────────────────────────────────────
    try {
      bytes.addAll(gen.row([
        PosColumn(text: 'Subtotal', width: labelWidth),
        PosColumn(
          text: _formatForPrinter(order.subtotal),
          width: valWidth,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));

      if (order.discountAmount > 0) {
        bytes.addAll(gen.row([
          PosColumn(text: 'Discount', width: labelWidth),
          PosColumn(
            text: '-${_formatForPrinter(order.discountAmount)}',
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
          text: _formatForPrinter(order.totalAmount),
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
          text: _formatForPrinter(order.amountTendered),
          width: valWidth,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));

      if (order.changeAmount > 0) {
        bytes.addAll(gen.row([
          PosColumn(text: 'Change', width: labelWidth),
          PosColumn(
            text: _formatForPrinter(order.changeAmount),
            width: valWidth,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]));
      }
    } catch (e) {
      debugPrint('RECEIPT TOTALS ERROR: $e');
      bytes.addAll(gen.text('TOTAL: ${_formatForPrinter(order.totalAmount)}'));
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
    String? macAddress,
  }) async {
    // DEBUG — log exactly what was passed
    debugPrint('[PrinterService] printReceipt called');
    debugPrint('[PrinterService] macAddress: ${macAddress ?? "NULL - not passed!"}');
    debugPrint('[PrinterService] orderNumber: ${order.orderNumber}');
    debugPrint('[PrinterService] itemCount: ${order.orderItemsJson.length}');

    try {
      // Step 1: Build bytes FIRST (before opening socket). Rule 5: Catch data errors
      List<int> bytes;
      try {
        bytes = await buildReceiptBytes(
          order,
          paperSize: paperSize,
          autoCut: autoCut,
          storeName: storeName,
          receiptHeader: receiptHeader,
          receiptFooter: receiptFooter,
        );
      } catch (e) {
        debugPrint('RECEIPT DATA ERROR: $e');
        rethrow;
      }

      // Step 2: Connect and transmit
      try {
        bool connected = false;
        if (macAddress != null && macAddress.trim().isNotEmpty) {
          // MAC provided — actively connect
          connected = await connect(macAddress);
        } else {
          // No MAC provided — check if already connected
          connected = await isConnected();
          debugPrint('[PrinterService] WARNING: printReceipt called without macAddress. isConnected=$connected');
        }

        if (!connected) {
          debugPrint('[PrinterService] FAILED: No connection. macAddress was: $macAddress');
          return false;
        }

        // Attempt write
        var success = await PrintBluetoothThermal.writeBytes(bytes);

        // Auto-retry once with socket reset if first write attempt failed
        if (!success && macAddress != null && macAddress.trim().isNotEmpty) {
          debugPrint('[PrinterService] Initial write failed. Attempting socket reset & reconnect...');
          await disconnect();
          await Future.delayed(const Duration(milliseconds: 500));
          final reconnected = await connect(macAddress);
          if (reconnected) {
            success = await PrintBluetoothThermal.writeBytes(bytes);
          }
        }

        return success;
      } catch (e) {
        debugPrint('PRINTER CONNECTION ERROR: $e');
        return false;
      }
    } catch (e) {
      debugPrint('PRINT RECEIPT UNEXPECTED ERROR: $e');
      return false;
    }
  }

  @override
  Future<bool> printTestReceipt({
    String paperSize = '58mm',
    String? storeName,
    String? macAddress,
  }) async {
    try {
      if (macAddress != null && macAddress.trim().isNotEmpty) {
        final connected = await connect(macAddress);
        if (!connected) return false;
      } else {
        final connected = await isConnected();
        if (!connected) return false;
      }

      final profile = await CapabilityProfile.load();
      final is58 = paperSize.contains('58');
      final pSize = is58 ? PaperSize.mm58 : PaperSize.mm80;
      final gen = Generator(pSize, profile);
      final bytes = <int>[];

      final title = storeName?.isNotEmpty == true ? storeName! : AppConstants.appName;

      bytes.addAll(gen.text(
        title.toUpperCase(),
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          height: is58 ? PosTextSize.size1 : PosTextSize.size2,
          width: is58 ? PosTextSize.size1 : PosTextSize.size2,
        ),
      ));
      bytes.addAll(gen.text(
        'TEST PRINT SUCCESSFUL',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ));
      bytes.addAll(gen.hr());
      bytes.addAll(gen.text(
        'Printer Paper: $paperSize',
        styles: const PosStyles(align: PosAlign.center),
      ));
      bytes.addAll(gen.text(
        'Date: ${_dateFormat.format(DateTime.now())}',
        styles: const PosStyles(align: PosAlign.center),
      ));
      bytes.addAll(gen.hr());
      bytes.addAll(gen.text(
        'Your Bluetooth Thermal Printer is working correctly with Sukli POS!',
        styles: const PosStyles(align: PosAlign.center),
      ));
      bytes.addAll(gen.feed(3));
      bytes.addAll(gen.cut());

      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      debugPrint('[PrinterService] Test print failed: $e');
      return false;
    }
  }
}

/// Riverpod provider exposing the singleton [ThermalPrinterService].
final printerServiceProvider = Provider<PrinterService>(
  (_) => ThermalPrinterService.instance,
);

