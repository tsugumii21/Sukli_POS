import 'dart:io';

import 'package:syncfusion_flutter_xlsio/xlsio.dart' as sf;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

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
    try {
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

      try {
        Directory? downloadsDir;
        if (Platform.isAndroid) {
          downloadsDir = Directory('/storage/emulated/0/Download');
          if (!await downloadsDir.exists()) {
            downloadsDir = await getExternalStorageDirectory();
          }
        } else {
          downloadsDir = await getApplicationDocumentsDirectory();
        }

        if (downloadsDir == null) throw Exception('Could not determine storage directory');

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
      } catch (e) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/$fileName';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(pdfBytes);

        await Share.shareXFiles(
          [XFile(tempPath)],
          subject: fileName,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to export PDF: $e',
              style: AppTextStyles.bodySemiBold(context).copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.errorLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
            duration: const Duration(seconds: 4),
          ),
        );
      }
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
    try {
      final orders = await _fetchOrders(ref, state);
      final dateFmt = DateFormat('MMM d, yyyy');
      final timeFmt = DateFormat('h:mm a');

      // Create a new Excel document
      final sf.Workbook workbook = sf.Workbook();

      void setCell(sf.Worksheet sheet, int r, int c, dynamic val, {sf.Style? style}) {
        final cell = sheet.getRangeByIndex(r, c);
        if (val is num) {
          cell.setNumber(val.toDouble());
        } else if (val is String) {
          cell.setText(val);
        } else {
          cell.setValue(val.toString());
        }
        if (style != null) {
          cell.cellStyle = style;
        }
      }

      if (orders.isEmpty) {
        final sf.Worksheet sheet = workbook.worksheets[0];
        sheet.name = 'Empty Report';
        setCell(sheet, 1, 1, 'No orders found for the selected period.');
      } else {
        // Define all style objects on the workbook
        final sf.Style titleStyle = workbook.styles.add('titleStyle');
        titleStyle.fontName = 'Segoe UI';
        titleStyle.fontSize = 14;
        titleStyle.bold = true;
        titleStyle.fontColor = '#4A121A'; // Dark maroon

        final sf.Style dateHeaderStyle = workbook.styles.add('dateHeaderStyle');
        dateHeaderStyle.fontName = 'Segoe UI';
        dateHeaderStyle.fontSize = 10;
        dateHeaderStyle.italic = true;
        dateHeaderStyle.fontColor = '#555555';

        // KPI Styles (Labels and Values)
        final sf.Style kpiGreen = workbook.styles.add('kpiGreen');
        kpiGreen.backColor = '#E6F4EA'; // Light green
        kpiGreen.fontName = 'Segoe UI';
        kpiGreen.fontSize = 10;
        kpiGreen.fontColor = '#137333';
        kpiGreen.bold = true;
        kpiGreen.hAlign = sf.HAlignType.center;
        kpiGreen.vAlign = sf.VAlignType.center;
        kpiGreen.borders.all.lineStyle = sf.LineStyle.thin;
        kpiGreen.borders.all.color = '#137333';

        final sf.Style kpiGreenVal = workbook.styles.add('kpiGreenVal');
        kpiGreenVal.backColor = '#E6F4EA';
        kpiGreenVal.fontName = 'Segoe UI';
        kpiGreenVal.fontSize = 11;
        kpiGreenVal.fontColor = '#137333';
        kpiGreenVal.bold = true;
        kpiGreenVal.hAlign = sf.HAlignType.center;
        kpiGreenVal.vAlign = sf.VAlignType.center;
        kpiGreenVal.borders.all.lineStyle = sf.LineStyle.thin;
        kpiGreenVal.borders.all.color = '#137333';
        kpiGreenVal.numberFormat = r'"₱"#,##0.00';

        final sf.Style kpiBlue = workbook.styles.add('kpiBlue');
        kpiBlue.backColor = '#E8F0FE'; // Light blue
        kpiBlue.fontName = 'Segoe UI';
        kpiBlue.fontSize = 10;
        kpiBlue.fontColor = '#1A73E8';
        kpiBlue.bold = true;
        kpiBlue.hAlign = sf.HAlignType.center;
        kpiBlue.vAlign = sf.VAlignType.center;
        kpiBlue.borders.all.lineStyle = sf.LineStyle.thin;
        kpiBlue.borders.all.color = '#1A73E8';

        final sf.Style kpiBlueVal = workbook.styles.add('kpiBlueVal');
        kpiBlueVal.backColor = '#E8F0FE';
        kpiBlueVal.fontName = 'Segoe UI';
        kpiBlueVal.fontSize = 11;
        kpiBlueVal.fontColor = '#1A73E8';
        kpiBlueVal.bold = true;
        kpiBlueVal.hAlign = sf.HAlignType.center;
        kpiBlueVal.vAlign = sf.VAlignType.center;
        kpiBlueVal.borders.all.lineStyle = sf.LineStyle.thin;
        kpiBlueVal.borders.all.color = '#1A73E8';

        final sf.Style kpiPurple = workbook.styles.add('kpiPurple');
        kpiPurple.backColor = '#F3E8FD'; // Light purple
        kpiPurple.fontName = 'Segoe UI';
        kpiPurple.fontSize = 10;
        kpiPurple.fontColor = '#7A22CC';
        kpiPurple.bold = true;
        kpiPurple.hAlign = sf.HAlignType.center;
        kpiPurple.vAlign = sf.VAlignType.center;
        kpiPurple.borders.all.lineStyle = sf.LineStyle.thin;
        kpiPurple.borders.all.color = '#7A22CC';

        final sf.Style kpiPurpleVal = workbook.styles.add('kpiPurpleVal');
        kpiPurpleVal.backColor = '#F3E8FD';
        kpiPurpleVal.fontName = 'Segoe UI';
        kpiPurpleVal.fontSize = 11;
        kpiPurpleVal.fontColor = '#7A22CC';
        kpiPurpleVal.bold = true;
        kpiPurpleVal.hAlign = sf.HAlignType.center;
        kpiPurpleVal.vAlign = sf.VAlignType.center;
        kpiPurpleVal.borders.all.lineStyle = sf.LineStyle.thin;
        kpiPurpleVal.borders.all.color = '#7A22CC';
        kpiPurpleVal.numberFormat = r'"₱"#,##0.00';

        final sf.Style kpiRed = workbook.styles.add('kpiRed');
        kpiRed.backColor = '#FCE8E6'; // Light red
        kpiRed.fontName = 'Segoe UI';
        kpiRed.fontSize = 10;
        kpiRed.fontColor = '#C5221F';
        kpiRed.bold = true;
        kpiRed.hAlign = sf.HAlignType.center;
        kpiRed.vAlign = sf.VAlignType.center;
        kpiRed.borders.all.lineStyle = sf.LineStyle.thin;
        kpiRed.borders.all.color = '#C5221F';

        final sf.Style kpiRedVal = workbook.styles.add('kpiRedVal');
        kpiRedVal.backColor = '#FCE8E6';
        kpiRedVal.fontName = 'Segoe UI';
        kpiRedVal.fontSize = 11;
        kpiRedVal.fontColor = '#C5221F';
        kpiRedVal.bold = true;
        kpiRedVal.hAlign = sf.HAlignType.center;
        kpiRedVal.vAlign = sf.VAlignType.center;
        kpiRedVal.borders.all.lineStyle = sf.LineStyle.thin;
        kpiRedVal.borders.all.color = '#C5221F';

        // Table Header Style
        final sf.Style tableHeaderStyle = workbook.styles.add('tableHeaderStyle');
        tableHeaderStyle.backColor = '#4A121A'; // Dark maroon
        tableHeaderStyle.fontName = 'Segoe UI';
        tableHeaderStyle.fontSize = 11;
        tableHeaderStyle.bold = true;
        tableHeaderStyle.fontColor = '#FFFFFF';
        tableHeaderStyle.hAlign = sf.HAlignType.center;
        tableHeaderStyle.vAlign = sf.VAlignType.center;
        tableHeaderStyle.borders.all.lineStyle = sf.LineStyle.thin;
        tableHeaderStyle.borders.all.color = '#3A0D14';

        // Data Row Styles (Standard & Alternate)
        final sf.Style rowStyleStandard = workbook.styles.add('rowStyleStandard');
        rowStyleStandard.fontName = 'Segoe UI';
        rowStyleStandard.fontSize = 10;
        rowStyleStandard.vAlign = sf.VAlignType.center;
        rowStyleStandard.borders.all.lineStyle = sf.LineStyle.thin;
        rowStyleStandard.borders.all.color = '#E0DCD3';

        final sf.Style rowStyleAlternate = workbook.styles.add('rowStyleAlternate');
        rowStyleAlternate.backColor = '#FAF8F4';
        rowStyleAlternate.fontName = 'Segoe UI';
        rowStyleAlternate.fontSize = 10;
        rowStyleAlternate.vAlign = sf.VAlignType.center;
        rowStyleAlternate.borders.all.lineStyle = sf.LineStyle.thin;
        rowStyleAlternate.borders.all.color = '#E0DCD3';

        final sf.Style currencyStyleStandard = workbook.styles.add('currencyStyleStandard');
        currencyStyleStandard.fontName = 'Segoe UI';
        currencyStyleStandard.fontSize = 10;
        currencyStyleStandard.vAlign = sf.VAlignType.center;
        currencyStyleStandard.hAlign = sf.HAlignType.right;
        currencyStyleStandard.numberFormat = r'"₱"#,##0.00';
        currencyStyleStandard.borders.all.lineStyle = sf.LineStyle.thin;
        currencyStyleStandard.borders.all.color = '#E0DCD3';

        final sf.Style currencyStyleAlternate = workbook.styles.add('currencyStyleAlternate');
        currencyStyleAlternate.backColor = '#FAF8F4';
        currencyStyleAlternate.fontName = 'Segoe UI';
        currencyStyleAlternate.fontSize = 10;
        currencyStyleAlternate.vAlign = sf.VAlignType.center;
        currencyStyleAlternate.hAlign = sf.HAlignType.right;
        currencyStyleAlternate.numberFormat = r'"₱"#,##0.00';
        currencyStyleAlternate.borders.all.lineStyle = sf.LineStyle.thin;
        currencyStyleAlternate.borders.all.color = '#E0DCD3';

        final sf.Style centerStyleStandard = workbook.styles.add('centerStyleStandard');
        centerStyleStandard.fontName = 'Segoe UI';
        centerStyleStandard.fontSize = 10;
        centerStyleStandard.vAlign = sf.VAlignType.center;
        centerStyleStandard.hAlign = sf.HAlignType.center;
        centerStyleStandard.borders.all.lineStyle = sf.LineStyle.thin;
        centerStyleStandard.borders.all.color = '#E0DCD3';

        final sf.Style centerStyleAlternate = workbook.styles.add('centerStyleAlternate');
        centerStyleAlternate.backColor = '#FAF8F4';
        centerStyleAlternate.fontName = 'Segoe UI';
        centerStyleAlternate.fontSize = 10;
        centerStyleAlternate.vAlign = sf.VAlignType.center;
        centerStyleAlternate.hAlign = sf.HAlignType.center;
        centerStyleAlternate.borders.all.lineStyle = sf.LineStyle.thin;
        centerStyleAlternate.borders.all.color = '#E0DCD3';

        // Status Styles
        final sf.Style statusCompletedStd = workbook.styles.add('statusCompletedStd');
        statusCompletedStd.fontName = 'Segoe UI';
        statusCompletedStd.fontSize = 10;
        statusCompletedStd.bold = true;
        statusCompletedStd.fontColor = '#137333';
        statusCompletedStd.vAlign = sf.VAlignType.center;
        statusCompletedStd.hAlign = sf.HAlignType.center;
        statusCompletedStd.borders.all.lineStyle = sf.LineStyle.thin;
        statusCompletedStd.borders.all.color = '#E0DCD3';

        final sf.Style statusCompletedAlt = workbook.styles.add('statusCompletedAlt');
        statusCompletedAlt.backColor = '#FAF8F4';
        statusCompletedAlt.fontName = 'Segoe UI';
        statusCompletedAlt.fontSize = 10;
        statusCompletedAlt.bold = true;
        statusCompletedAlt.fontColor = '#137333';
        statusCompletedAlt.vAlign = sf.VAlignType.center;
        statusCompletedAlt.hAlign = sf.HAlignType.center;
        statusCompletedAlt.borders.all.lineStyle = sf.LineStyle.thin;
        statusCompletedAlt.borders.all.color = '#E0DCD3';

        final sf.Style statusRefundedStd = workbook.styles.add('statusRefundedStd');
        statusRefundedStd.fontName = 'Segoe UI';
        statusRefundedStd.fontSize = 10;
        statusRefundedStd.bold = true;
        statusRefundedStd.fontColor = '#E37400';
        statusRefundedStd.vAlign = sf.VAlignType.center;
        statusRefundedStd.hAlign = sf.HAlignType.center;
        statusRefundedStd.borders.all.lineStyle = sf.LineStyle.thin;
        statusRefundedStd.borders.all.color = '#E0DCD3';

        final sf.Style statusRefundedAlt = workbook.styles.add('statusRefundedAlt');
        statusRefundedAlt.backColor = '#FAF8F4';
        statusRefundedAlt.fontName = 'Segoe UI';
        statusRefundedAlt.fontSize = 10;
        statusRefundedAlt.bold = true;
        statusRefundedAlt.fontColor = '#E37400';
        statusRefundedAlt.vAlign = sf.VAlignType.center;
        statusRefundedAlt.hAlign = sf.HAlignType.center;
        statusRefundedAlt.borders.all.lineStyle = sf.LineStyle.thin;
        statusRefundedAlt.borders.all.color = '#E0DCD3';

        final sf.Style statusVoidedStd = workbook.styles.add('statusVoidedStd');
        statusVoidedStd.fontName = 'Segoe UI';
        statusVoidedStd.fontSize = 10;
        statusVoidedStd.bold = true;
        statusVoidedStd.fontColor = '#C5221F';
        statusVoidedStd.vAlign = sf.VAlignType.center;
        statusVoidedStd.hAlign = sf.HAlignType.center;
        statusVoidedStd.borders.all.lineStyle = sf.LineStyle.thin;
        statusVoidedStd.borders.all.color = '#E0DCD3';

        final sf.Style statusVoidedAlt = workbook.styles.add('statusVoidedAlt');
        statusVoidedAlt.backColor = '#FAF8F4';
        statusVoidedAlt.fontName = 'Segoe UI';
        statusVoidedAlt.fontSize = 10;
        statusVoidedAlt.bold = true;
        statusVoidedAlt.fontColor = '#C5221F';
        statusVoidedAlt.vAlign = sf.VAlignType.center;
        statusVoidedAlt.hAlign = sf.HAlignType.center;
        statusVoidedAlt.borders.all.lineStyle = sf.LineStyle.thin;
        statusVoidedAlt.borders.all.color = '#E0DCD3';

        // Group orders by yyyy-MM
        final Map<String, List<OrderCollection>> monthlyOrders = {};
        for (final o in orders) {
          final String ym = DateFormat('yyyy-MM').format(o.orderedAt);
          monthlyOrders.putIfAbsent(ym, () => []);
          monthlyOrders[ym]!.add(o);
        }

        // Sort keys chronologically
        final sortedYearMonths = monthlyOrders.keys.toList()..sort();

        for (int i = 0; i < sortedYearMonths.length; i++) {
          final String ym = sortedYearMonths[i];
          final List<OrderCollection> monthOrders = monthlyOrders[ym]!;

          final DateTime parsedDate = DateFormat('yyyy-MM').parse(ym);
          final String tabName = DateFormat('MMMM yyyy').format(parsedDate);

          sf.Worksheet sheet;
          if (i == 0) {
            sheet = workbook.worksheets[0];
            sheet.name = tabName;
          } else {
            sheet = workbook.worksheets.addWithName(tabName);
          }

          // Calculate KPIs for this month
          double monthRevenue = 0.0;
          int monthCompletedAndRefundedCount = 0;
          double monthHighestSale = 0.0;
          int monthVoidCount = 0;
          double monthVoidAmount = 0.0;
          int monthRefundCount = 0;
          double monthRefundAmount = 0.0;

          for (final o in monthOrders) {
            if (o.status == 'completed') {
              monthRevenue += o.totalAmount;
              monthCompletedAndRefundedCount++;
              if (o.totalAmount > monthHighestSale) {
                monthHighestSale = o.totalAmount;
              }
            } else if (o.status == 'refunded') {
              final refundAmt = o.refundAmount ?? o.totalAmount;
              final netAmt = o.totalAmount - refundAmt;
              monthRevenue += netAmt;
              monthRefundCount++;
              monthRefundAmount += refundAmt;
              if (netAmt > 0.0) {
                monthCompletedAndRefundedCount++;
              }
              if (o.totalAmount > monthHighestSale) {
                monthHighestSale = o.totalAmount;
              }
            } else if (o.status == 'voided') {
              monthVoidCount++;
              monthVoidAmount += o.totalAmount;
            }
          }

          // Write KPI Section
          setCell(sheet, 1, 1, 'Sales Report — $tabName', style: titleStyle);
          setCell(sheet, 2, 1, 'Generated: ${dateFmt.format(DateTime.now())}', style: dateHeaderStyle);

          setCell(sheet, 3, 1, 'Net Revenue', style: kpiGreen);
          setCell(sheet, 4, 1, monthRevenue, style: kpiGreenVal);

          setCell(sheet, 3, 2, 'Total Orders', style: kpiBlue);
          setCell(sheet, 4, 2, monthCompletedAndRefundedCount, style: kpiBlueVal);

          setCell(sheet, 3, 3, 'Highest Sale', style: kpiPurple);
          setCell(sheet, 4, 3, monthHighestSale, style: kpiPurpleVal);

          setCell(sheet, 3, 4, 'Voids', style: kpiRed);
          setCell(sheet, 4, 4, '$monthVoidCount Voids (₱${monthVoidAmount.toStringAsFixed(2)})', style: kpiRedVal);

          setCell(sheet, 3, 5, 'Refunds', style: kpiRed);
          setCell(sheet, 4, 5, '$monthRefundCount Refunds (₱${monthRefundAmount.toStringAsFixed(2)})', style: kpiRedVal);

          // Write Table Headers on Row 6
          setCell(sheet, 6, 1, 'Order #', style: tableHeaderStyle);
          setCell(sheet, 6, 2, 'Cashier', style: tableHeaderStyle);
          setCell(sheet, 6, 3, 'Date', style: tableHeaderStyle);
          setCell(sheet, 6, 4, 'Time', style: tableHeaderStyle);
          setCell(sheet, 6, 5, 'Payment', style: tableHeaderStyle);
          setCell(sheet, 6, 6, 'Total Amount', style: tableHeaderStyle);
          setCell(sheet, 6, 7, 'Status', style: tableHeaderStyle);

          // Write Table Data Rows
          int or = 7;
          for (final o in monthOrders) {
            final isAlt = (or % 2 == 0);
            final stdStyle = isAlt ? rowStyleAlternate : rowStyleStandard;
            final centerStyle = isAlt ? centerStyleAlternate : centerStyleStandard;
            final currencyStyle = isAlt ? currencyStyleAlternate : currencyStyleStandard;

            sf.Style statusStyle;
            if (o.status == 'completed') {
              statusStyle = isAlt ? statusCompletedAlt : statusCompletedStd;
            } else if (o.status == 'refunded') {
              statusStyle = isAlt ? statusRefundedAlt : statusRefundedStd;
            } else {
              statusStyle = isAlt ? statusVoidedAlt : statusVoidedStd;
            }

            setCell(sheet, or, 1, o.orderNumber, style: stdStyle);
            setCell(sheet, or, 2, o.cashierName, style: stdStyle);
            setCell(sheet, or, 3, dateFmt.format(o.orderedAt), style: centerStyle);
            setCell(sheet, or, 4, timeFmt.format(o.orderedAt), style: centerStyle);
            setCell(sheet, or, 5, o.paymentMethod.toUpperCase(), style: centerStyle);
            setCell(sheet, or, 6, o.totalAmount, style: currencyStyle);
            setCell(sheet, or, 7, o.status.toUpperCase(), style: statusStyle);

            or++;
          }
          // Auto-fit all columns
          for (int col = 1; col <= 7; col++) {
            sheet.autoFitColumn(col);
          }
        }
      }

      // Save Workbook using saveAsStream()
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final fileName = 'sukli-report-${DateFormat('yyyy-MM-dd-HHmmss').format(DateTime.now())}.xlsx';

      try {
        Directory? downloadsDir;
        if (Platform.isAndroid) {
          downloadsDir = Directory('/storage/emulated/0/Download');
          if (!await downloadsDir.exists()) {
            downloadsDir = await getExternalStorageDirectory();
          }
        } else {
          downloadsDir = await getApplicationDocumentsDirectory();
        }

        if (downloadsDir == null) throw Exception('Could not determine storage directory');

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
      } catch (e) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/$fileName';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(tempPath)],
          subject: fileName,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to export Excel: $e',
              style: AppTextStyles.bodySemiBold(context).copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.errorLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
            duration: const Duration(seconds: 4),
          ),
        );
      }
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
