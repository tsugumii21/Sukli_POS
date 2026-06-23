import 'dart:io';

import 'package:syncfusion_flutter_xlsio/xlsio.dart' as sf;
import 'package:syncfusion_officechart/officechart.dart' as sfc;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/providers/isar_provider.dart';
import '../../../../shared/providers/store_provider.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/reports_provider.dart';

/// Export bottom sheet — PDF and Excel export options.
class ExportSheet extends ConsumerWidget {
  const ExportSheet({super.key, required this.state});
  final ReportState state;

  static Future<void> show(BuildContext context, ReportState state) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportSheet(state: state),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: AppRadius.large),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: textSecondary.withValues(alpha: 0.3),
                borderRadius: AppRadius.pillBR,
              ),
            ),
          ),
          Text('Export Report', style: AppTextStyles.h3(context)),
          Text(state.periodLabel,
              style: AppTextStyles.captionSecondary(context)),
          const SizedBox(height: AppSpacing.lg),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PDF
                Expanded(
                  child: AppCard(
                    onTap: () => _exportPdf(context, ref),
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg, horizontal: AppSpacing.md),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.errorLight.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.picture_as_pdf_rounded,
                              size: 32, color: AppColors.errorLight),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text('PDF Report',
                            style: AppTextStyles.bodySemiBold(context)),
                        const SizedBox(height: 4),
                        Text('Full report\nwith charts',
                            style: AppTextStyles.captionSecondary(context),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Excel
                Expanded(
                  child: AppCard(
                    onTap: () => _exportExcel(context, ref),
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg, horizontal: AppSpacing.md),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.successLight.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.table_chart_rounded,
                              size: 32, color: AppColors.successLight),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Excel File',
                            style: AppTextStyles.bodySemiBold(context)),
                        const SizedBox(height: 4),
                        Text('3 sheets:\nSummary, Orders,\nCashier',
                            style: AppTextStyles.captionSecondary(context),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PDF Export ──────────────────────────────────────────────────────────────

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();
    final orders = await _fetchOrders(ref, state);
    final topItems = state.topItems;
    final dateFmt = DateFormat('MMM d, yyyy h:mm a');

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Text('Sukli POS — Sales Report',
              style:
                  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Text(
              'Period: ${state.periodLabel}  |  Generated: ${dateFmt.format(DateTime.now())}'),
          pw.SizedBox(height: 16),
          pw.Divider(),
          pw.SizedBox(height: 8),
          // KPIs
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfKpi(
                  'Total Revenue', CurrencyFormatter.format(state.totalSales)),
              _pdfKpi('Total Orders', '${state.totalOrders}'),
              _pdfKpi('Average Order',
                  CurrencyFormatter.format(state.averageOrderValue)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfKpi(
                  'Highest Sale', CurrencyFormatter.format(state.highestSale)),
              _pdfKpi('Total Voids', CurrencyFormatter.format(state.totalVoids)),
              _pdfKpi('Total Refunds', CurrencyFormatter.format(state.totalRefunds)),
            ],
          ),
          pw.SizedBox(height: 16),
          // Orders table
          pw.Text('Order Details',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (orders.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headers: [
                'Order #',
                'Cashier',
                'Date & Time',
                'Payment',
                'Total'
              ],
              data: orders
                  .map((o) => [
                        o.orderNumber,
                        o.cashierName,
                        dateFmt.format(o.orderedAt),
                        o.paymentMethod.toUpperCase(),
                        CurrencyFormatter.format(o.totalAmount),
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration:
                  pw.BoxDecoration(color: PdfColor.fromHex('#6B2C33')),
              oddRowDecoration:
                  pw.BoxDecoration(color: PdfColor.fromHex('#FAF6F1')),
            )
          else
            pw.Text('No orders in this period.'),
          pw.SizedBox(height: 16),
          // Top items
          if (topItems.isNotEmpty) ...[
            pw.Text('Top Selling Items',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Rank', 'Item Name', 'Qty Sold', 'Revenue'],
              data: topItems
                  .asMap()
                  .entries
                  .map((e) => [
                        '#${e.key + 1}',
                        e.value.name,
                        '${e.value.qtySold}',
                        CurrencyFormatter.format(e.value.revenue),
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration:
                  pw.BoxDecoration(color: PdfColor.fromHex('#6B2C33')),
            ),
          ],
          pw.SizedBox(height: 24),
          pw.Text('Generated by Sukli POS v1.0',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
        ],
      ),
    );

    final pdfBytes = await doc.save();
    final fileName =
        'sukli-report-${DateFormat('yyyy-MM-dd-HHmmss').format(DateTime.now())}.pdf';
    Directory? downloadsDir;

    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        downloadsDir = await getExternalStorageDirectory();
      }
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
    }

    if (downloadsDir == null) return;

    final filePath = '${downloadsDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved to Downloads/$fileName',
            style: AppTextStyles.bodySemiBold(context)
                .copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.successLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  pw.Widget _pdfKpi(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  // ── Excel Export ────────────────────────────────────────────────────────────

  Future<void> _exportExcel(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();
    final orders = await _fetchOrders(ref, state);
    final dateFmt = DateFormat('MMM d, yyyy');
    final timeFmt = DateFormat('h:mm a');

    // Create a new Excel document
    final sf.Workbook workbook = sf.Workbook();
    
    // ── Sheet 1: Summary ──────────────────────────────────────────────────
    final sf.Worksheet summarySheet = workbook.worksheets[0];
    summarySheet.name = 'Summary';

    void setCell(sf.Worksheet sheet, int r, int c, dynamic val, {String? numberFormat}) {
      final cell = sheet.getRangeByIndex(r, c);
      if (val is num) {
        cell.setNumber(val.toDouble());
        if (numberFormat != null) {
          cell.numberFormat = numberFormat;
        }
      } else if (val is String) {
        cell.setText(val);
      } else {
        cell.setValue(val.toString());
      }
    }

    int r = 1;
    setCell(summarySheet, r, 1, 'Sukli POS — Sales Report');
    r++;
    setCell(summarySheet, r, 1, 'Period: ${state.periodLabel}   Generated: ${dateFmt.format(DateTime.now())}');
    r += 2;

    setCell(summarySheet, r, 1, 'Metric');
    setCell(summarySheet, r, 2, 'Value');
    r++;

    setCell(summarySheet, r, 1, 'Total Revenue');
    setCell(summarySheet, r, 2, state.totalSales, numberFormat: r'"₱"#,##0.00');
    r++;

    setCell(summarySheet, r, 1, 'Total Orders');
    setCell(summarySheet, r, 2, state.totalOrders);
    r++;

    setCell(summarySheet, r, 1, 'Average Order');
    setCell(summarySheet, r, 2, state.averageOrderValue, numberFormat: r'"₱"#,##0.00');
    r++;

    setCell(summarySheet, r, 1, 'Highest Sale');
    setCell(summarySheet, r, 2, state.highestSale, numberFormat: r'"₱"#,##0.00');
    r++;

    setCell(summarySheet, r, 1, 'Total Voids');
    setCell(summarySheet, r, 2, state.totalVoids, numberFormat: r'"₱"#,##0.00');
    r++;

    setCell(summarySheet, r, 1, 'Total Refunds');
    setCell(summarySheet, r, 2, state.totalRefunds, numberFormat: r'"₱"#,##0.00');
    r++;

    setCell(summarySheet, r, 1, 'Top Cashier');
    setCell(summarySheet, r, 2, state.topCashierName);
    r += 2;

    setCell(summarySheet, r, 1, 'Payment Breakdown');
    r++;
    setCell(summarySheet, r, 1, 'Method');
    setCell(summarySheet, r, 2, 'Amount');
    setCell(summarySheet, r, 3, '% of Total');
    r++;

    final paymentStartRow = r;
    for (final p in state.paymentBreakdown) {
      setCell(summarySheet, r, 1, p.methodLabel);
      setCell(summarySheet, r, 2, p.amount, numberFormat: r'"₱"#,##0.00');
      setCell(summarySheet, r, 3, p.percentage / 100.0, numberFormat: '0.0%');
      r++;
    }
    final paymentEndRow = r - 1;

    // Create Pie Chart for Payment Breakdown
    if (state.paymentBreakdown.isNotEmpty) {
      final sfc.ChartCollection charts = sfc.ChartCollection(summarySheet);
      final sfc.Chart chart = charts.add();
      chart.chartType = sfc.ExcelChartType.pie;
      chart.dataRange = summarySheet.getRangeByIndex(paymentStartRow, 1, paymentEndRow, 2);
      chart.isSeriesInRows = false;
      chart.chartTitle = 'Payment Methods';
      
      chart.topRow = 4;
      chart.leftColumn = 4;
      chart.bottomRow = 18;
      chart.rightColumn = 10;
      
      summarySheet.charts = charts;
    }

    // ── Sheet 2: Orders ───────────────────────────────────────────────────
    final sf.Worksheet ordersSheet = workbook.worksheets.addWithName('Orders');
    int or = 1;
    setCell(ordersSheet, or, 1, 'Order #');
    setCell(ordersSheet, or, 2, 'Cashier');
    setCell(ordersSheet, or, 3, 'Date');
    setCell(ordersSheet, or, 4, 'Time');
    setCell(ordersSheet, or, 5, 'Payment');
    setCell(ordersSheet, or, 6, 'Total');
    setCell(ordersSheet, or, 7, 'Status');
    or++;

    for (final o in orders) {
      setCell(ordersSheet, or, 1, o.orderNumber);
      setCell(ordersSheet, or, 2, o.cashierName);
      setCell(ordersSheet, or, 3, dateFmt.format(o.orderedAt));
      setCell(ordersSheet, or, 4, timeFmt.format(o.orderedAt));
      setCell(ordersSheet, or, 5, o.paymentMethod.toUpperCase());
      setCell(ordersSheet, or, 6, o.totalAmount, numberFormat: r'"₱"#,##0.00');
      setCell(ordersSheet, or, 7, o.status);
      or++;
    }

    // ── Sheet 3: Cashier Summary ──────────────────────────────────────────
    final sf.Worksheet cashierSheet = workbook.worksheets.addWithName('Cashier Summary');
    int cr = 1;
    setCell(cashierSheet, cr, 1, 'Cashier Name');
    setCell(cashierSheet, cr, 2, 'Total Orders');
    setCell(cashierSheet, cr, 3, 'Total Revenue');
    setCell(cashierSheet, cr, 4, 'Avg Order Value');
    setCell(cashierSheet, cr, 5, 'Most Used Payment');
    cr++;

    // Group by cashier
    final cashierMap = <String, List<OrderCollection>>{};
    for (final o in orders) {
      cashierMap.putIfAbsent(o.cashierName, () => []);
      cashierMap[o.cashierName]!.add(o);
    }
    final cashierEntries = cashierMap.entries.toList()
      ..sort((a, b) {
        final ra = a.value.fold<double>(0, (s, o) => s + o.totalAmount);
        final rb = b.value.fold<double>(0, (s, o) => s + o.totalAmount);
        return rb.compareTo(ra);
      });

    final cashierStartRow = cr;
    for (final entry in cashierEntries) {
      final list = entry.value;
      final totalRev = list.fold<double>(0, (s, o) => s + o.totalAmount);
      final avgVal = list.isEmpty ? 0.0 : totalRev / list.length;
      
      final payMap = <String, int>{};
      for (final o in list) {
        final m = o.paymentMethod.toUpperCase();
        payMap[m] = (payMap[m] ?? 0) + 1;
      }
      final topPay = payMap.isEmpty 
          ? 'N/A' 
          : payMap.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

      setCell(cashierSheet, cr, 1, entry.key);
      setCell(cashierSheet, cr, 2, list.length);
      setCell(cashierSheet, cr, 3, totalRev, numberFormat: r'"₱"#,##0.00');
      setCell(cashierSheet, cr, 4, avgVal, numberFormat: r'"₱"#,##0.00');
      setCell(cashierSheet, cr, 5, topPay);
      cr++;
    }
    final cashierEndRow = cr - 1;

    // Create Column Chart for Revenue by Cashier
    if (cashierEntries.isNotEmpty) {
      final sfc.ChartCollection cashierCharts = sfc.ChartCollection(cashierSheet);
      final sfc.Chart chart = cashierCharts.add();
      chart.chartType = sfc.ExcelChartType.column;
      
      final sfc.ChartSerie series = chart.series.add();
      series.name = 'Total Revenue';
      series.categoryLabels = cashierSheet.getRangeByIndex(cashierStartRow, 1, cashierEndRow, 1);
      series.values = cashierSheet.getRangeByIndex(cashierStartRow, 3, cashierEndRow, 3);
      
      chart.chartTitle = 'Revenue by Cashier';
      chart.isSeriesInRows = false;
      chart.legend!.position = sfc.ExcelLegendPosition.right;
      
      chart.topRow = 2;
      chart.leftColumn = 7;
      chart.bottomRow = 16;
      chart.rightColumn = 13;
      
      cashierSheet.charts = cashierCharts;
    }

    // Save Workbook
    final List<int> bytes = workbook.saveSync();
    workbook.dispose();

    final fileName = 'sukli-report-${DateFormat('yyyy-MM-dd-HHmmss').format(DateTime.now())}.xlsx';
    Directory? downloadsDir;

    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        downloadsDir = await getExternalStorageDirectory();
      }
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
    }

    if (downloadsDir == null) return;

    final filePath = '${downloadsDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved to Downloads/$fileName',
            style: AppTextStyles.bodySemiBold(context).copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.successLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<List<OrderCollection>> _fetchOrders(WidgetRef ref, ReportState state) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId.isEmpty) return [];

    final isar = ref.read(isarProvider);
    DateTime start;
    DateTime end = DateTime.now();

    switch (state.period) {
      case ReportPeriod.day:
        start = DateTime(end.year, end.month, end.day);
        break;
      case ReportPeriod.week:
        start = end.subtract(const Duration(days: 7));
        break;
      case ReportPeriod.month:
        start = DateTime(end.year, end.month, 1);
        break;
      case ReportPeriod.year:
        start = DateTime(end.year, 1, 1);
        break;
      case ReportPeriod.custom:
        start = state.customStart ?? end.subtract(const Duration(days: 7));
        end = state.customEnd ?? end;
        break;
    }

    return await isar.orderCollections
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .orderedAtBetween(start, end)
        .and()
        .isDeletedEqualTo(false)
        .sortByOrderNumberDesc()
        .findAll();
  }
}
