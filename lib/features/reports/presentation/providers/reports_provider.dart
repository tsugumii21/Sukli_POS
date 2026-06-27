import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/isar_collections/store_collection.dart';
import '../../../../shared/providers/isar_provider.dart';
import '../../../../shared/providers/store_provider.dart';

export 'reports_provider.dart';

enum ReportPeriod { day, week, month, year, custom }

// ── Data models for chart sections ────────────────────────────────────────────

class PaymentBreakdownItem {
  final String method;
  final double amount;
  final double percentage;

  const PaymentBreakdownItem({
    required this.method,
    required this.amount,
    required this.percentage,
  });

  String get methodLabel {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'gcash':
        return 'GCash';
      case 'maya':
        return 'Maya';
      case 'card':
        return 'Card';
      default:
        return 'Other';
    }
  }
}

class TopItem {
  final String name;
  final int qtySold;
  final double revenue;

  const TopItem({
    required this.name,
    required this.qtySold,
    required this.revenue,
  });
}

// ── ReportState ────────────────────────────────────────────────────────────────

class ReportState {
  final ReportPeriod period;
  final DateTime? customStart;
  final DateTime? customEnd;

  final bool isLoading;
  final double totalSales;
  final int totalOrders;
  final double averageOrderValue;
  final double highestSale;
  final double totalVoids;
  final double totalRefunds;
  final String topCashierName;
  final List<PaymentBreakdownItem> paymentBreakdown;
  final List<TopItem> topItems;
  final List<FlSpot> revenueSpots;
  final List<String> xLabels;
  final List<String> tooltipLabels;

  const ReportState({
    required this.period,
    this.customStart,
    this.customEnd,
    this.isLoading = false,
    this.totalSales = 0.0,
    this.totalOrders = 0,
    this.averageOrderValue = 0.0,
    this.highestSale = 0.0,
    this.totalVoids = 0.0,
    this.totalRefunds = 0.0,
    this.topCashierName = '—',
    this.paymentBreakdown = const [],
    this.topItems = const [],
    this.revenueSpots = const [FlSpot(0, 0)],
    this.xLabels = const ['0'],
    this.tooltipLabels = const ['—'],
  });

  ReportState copyWith({
    ReportPeriod? period,
    DateTime? customStart,
    DateTime? customEnd,
    bool? isLoading,
    double? totalSales,
    int? totalOrders,
    double? averageOrderValue,
    double? highestSale,
    double? totalVoids,
    double? totalRefunds,
    String? topCashierName,
    List<PaymentBreakdownItem>? paymentBreakdown,
    List<TopItem>? topItems,
    List<FlSpot>? revenueSpots,
    List<String>? xLabels,
    List<String>? tooltipLabels,
  }) {
    return ReportState(
      period: period ?? this.period,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      isLoading: isLoading ?? this.isLoading,
      totalSales: totalSales ?? this.totalSales,
      totalOrders: totalOrders ?? this.totalOrders,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      highestSale: highestSale ?? this.highestSale,
      totalVoids: totalVoids ?? this.totalVoids,
      totalRefunds: totalRefunds ?? this.totalRefunds,
      topCashierName: topCashierName ?? this.topCashierName,
      paymentBreakdown: paymentBreakdown ?? this.paymentBreakdown,
      topItems: topItems ?? this.topItems,
      revenueSpots: revenueSpots ?? this.revenueSpots,
      xLabels: xLabels ?? this.xLabels,
      tooltipLabels: tooltipLabels ?? this.tooltipLabels,
    );
  }

  // ── Period label ─────────────────────────────────────────────────────────

  String get periodLabel {
    switch (period) {
      case ReportPeriod.day:
        return 'Today';
      case ReportPeriod.week:
        return 'This Week';
      case ReportPeriod.month:
        return DateFormat('MMMM yyyy').format(DateTime.now());
      case ReportPeriod.year:
        return '${DateTime.now().year}';
      case ReportPeriod.custom:
        if (customStart == null || customEnd == null) return 'Custom';
        final fmt = DateFormat('MMM d');
        final fmtYear = DateFormat('MMM d, yyyy');
        return '${fmt.format(customStart!)} – ${fmtYear.format(customEnd!)}';
    }
  }
}

enum _ReportGranularity { hourly, daily, weekly, monthly }

// ── Notifier ───────────────────────────────────────────────────────────────────

class ReportsNotifier extends Notifier<ReportState> {
  @override
  ReportState build() {
    final storeId = ref.watch(currentStoreIdProvider);
    if (storeId.isEmpty) return const ReportState(period: ReportPeriod.day);

    _loadData(storeId);
    return const ReportState(period: ReportPeriod.day);
  }

  void setPeriod(
    ReportPeriod period, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final storeId = ref.read(currentStoreIdProvider);
    state = state.copyWith(
      period: period,
      customStart: customStart,
      customEnd: customEnd,
    );
    _loadData(storeId);
  }

  Future<void> _loadData(String storeId) async {
    var finalStoreId = storeId;
    if (finalStoreId.isEmpty) {
      final db = ref.read(isarProvider);
      final store = db.storeCollections.filter().isDeletedEqualTo(false).build().findFirstSync();
      if (store != null) {
        finalStoreId = store.syncId;
      } else {
        return;
      }
    }

    final isar = ref.read(isarProvider);
    DateTime start;
    DateTime end = DateTime.now();

    switch (state.period) {
      case ReportPeriod.day:
        if (state.customStart != null && state.customEnd != null) {
          start = state.customStart!;
          end = state.customEnd!;
        } else {
          start = DateTime(end.year, end.month, end.day);
        }
        break;
      case ReportPeriod.week:
        start = end.subtract(const Duration(days: 7));
        break;
      case ReportPeriod.month:
        start = DateTime(end.year, end.month, 1);
        final lastDay = DateTime(end.year, end.month + 1, 0);
        end = lastDay;
        break;
      case ReportPeriod.year:
        start = DateTime(end.year, 1, 1);
        break;
      case ReportPeriod.custom:
        start = state.customStart ?? end.subtract(const Duration(days: 7));
        end = state.customEnd ?? end;
        break;
    }

    state = state.copyWith(isLoading: true);

    final allOrdersCount = await isar.orderCollections
        .filter()
        .storeIdEqualTo(finalStoreId)
        .and()
        .orderedAtBetween(start, end)
        .and()
        .isDeletedEqualTo(false)
        .count();

    if (allOrdersCount == 0) {
      state = state.copyWith(
        isLoading: false,
        totalOrders: 0,
        totalSales: 0.0,
        averageOrderValue: 0.0,
        highestSale: 0.0,
        totalVoids: 0.0,
        totalRefunds: 0.0,
        topCashierName: '—',
        paymentBreakdown: const [],
        topItems: const [],
        revenueSpots: const [FlSpot(0, 0)],
        xLabels: const ['—'],
        tooltipLabels: const ['—'],
      );
      return;
    }

    int completedOrdersCount = 0;
    double totalSales = 0.0;
    double highestSale = 0.0;
    double totalVoids = 0.0;
    double totalRefunds = 0.0;
    final cashierCounts = <String, int>{};
    final paymentTotals = <String, double>{};
    final itemRevenue = <String, double>{};
    final itemQty = <String, int>{};

    _ReportGranularity granularity;
    List<double> buckets;
    List<String> xLabels = [];
    List<String> tooltipLabels = [];

    final totalDays = end.difference(start).inDays + 1;

    int dayStartHour = 8;
    int dayEndHour = 17;

    if (state.period == ReportPeriod.day) {
      granularity = _ReportGranularity.hourly;
      final dayOrders = await isar.orderCollections
          .filter()
          .storeIdEqualTo(finalStoreId)
          .and()
          .orderedAtBetween(start, end)
          .and()
          .isDeletedEqualTo(false)
          .findAll();

      int? minH;
      int? maxH;
      for (final o in dayOrders) {
        if (o.status == 'completed' || o.status == 'refunded') {
          final h = o.orderedAt.hour;
          if (minH == null || h < minH) minH = h;
          if (maxH == null || h > maxH) maxH = h;
        }
      }

      if (minH != null && maxH != null) {
        dayStartHour = minH;
        dayEndHour = maxH;
      } else {
        dayStartHour = 8;
        dayEndHour = 17;
      }

      final totalHours = dayEndHour - dayStartHour + 1;
      buckets = List<double>.filled(totalHours, 0);

      for (int i = 0; i < totalHours; i++) {
        final h = dayStartHour + i;
        final hourStr = h == 0
            ? '12 AM'
            : (h == 12 ? '12 PM' : (h < 12 ? '$h AM' : '${h - 12} PM'));
        xLabels.add(hourStr);
        tooltipLabels.add(hourStr);
      }
    } else if (state.period == ReportPeriod.week) {
      granularity = _ReportGranularity.daily;
      buckets = List<double>.filled(7, 0);
      final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (int i = 0; i < 7; i++) {
        final date = start.add(Duration(days: i));
        xLabels.add(daysOfWeek[i % 7]);
        tooltipLabels.add(DateFormat('EEEE, MMM d').format(date));
      }
    } else if (state.period == ReportPeriod.year) {
      granularity = _ReportGranularity.monthly;
      buckets = List<double>.filled(12, 0);
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      for (int m = 0; m < 12; m++) {
        xLabels.add(monthNames[m]);
        tooltipLabels.add(DateFormat('MMMM yyyy').format(DateTime(start.year, m + 1, 1)));
      }
    } else {
      // Month or Custom period
      if (totalDays <= 10) {
        granularity = _ReportGranularity.daily;
        buckets = List<double>.filled(totalDays, 0);
        for (int i = 0; i < totalDays; i++) {
          final date = start.add(Duration(days: i));
          xLabels.add(DateFormat('MMM d').format(date));
          tooltipLabels.add(DateFormat('EEEE, MMM d').format(date));
        }
      } else if (totalDays <= 60) {
        granularity = _ReportGranularity.weekly;
        final numWeeks = ((totalDays - 1) ~/ 7) + 1;
        buckets = List<double>.filled(numWeeks, 0);
        final isMultiMonth = start.month != end.month;

        for (int w = 0; w < numWeeks; w++) {
          final wStart = start.add(Duration(days: w * 7));
          final wEndTemp = start.add(Duration(days: (w + 1) * 7 - 1));
          final wEnd = wEndTemp.isAfter(end) ? end : wEndTemp;

          if (isMultiMonth) {
            final monthStr = DateFormat('MMM').format(wStart);
            xLabels.add('W${w + 1} - $monthStr');
          } else {
            xLabels.add('Week ${w + 1}');
          }
          tooltipLabels.add('Week ${w + 1} (${DateFormat('MMM d').format(wStart)} – ${DateFormat('MMM d').format(wEnd)})');
        }
      } else {
        granularity = _ReportGranularity.monthly;
        final numMonths = (end.year - start.year) * 12 + end.month - start.month + 1;
        buckets = List<double>.filled(numMonths, 0);
        for (int m = 0; m < numMonths; m++) {
          final mDate = DateTime(start.year, start.month + m, 1);
          xLabels.add(DateFormat('MMM').format(mDate));
          tooltipLabels.add(DateFormat('MMMM yyyy').format(mDate));
        }
      }
    }

    int offset = 0;
    const batchSize = AppConstants.reportsBatchSize;

    while (true) {
      final batch = await isar.orderCollections
          .filter()
          .storeIdEqualTo(finalStoreId)
          .and()
          .orderedAtBetween(start, end)
          .and()
          .isDeletedEqualTo(false)
          .offset(offset)
          .limit(batchSize)
          .findAll();

      if (batch.isEmpty) break;

      for (final o in batch) {
        if (o.status == 'completed' || o.status == 'refunded') {
          double amt = o.totalAmount;
          if (o.status == 'refunded') {
            final refundAmt = o.refundAmount ?? o.totalAmount;
            totalRefunds += refundAmt;
            amt = o.totalAmount - refundAmt;
          }

          if (amt <= 0 && o.status == 'refunded') {
            continue;
          }

          if (o.status == 'completed') {
            completedOrdersCount++;
            totalSales += amt;
            if (amt > highestSale) highestSale = amt;
            cashierCounts[o.cashierName] = (cashierCounts[o.cashierName] ?? 0) + 1;

            final method = o.paymentMethod.toLowerCase();
            paymentTotals[method] = (paymentTotals[method] ?? 0) + amt;

            for (final json in o.orderItemsJson) {
              try {
                final map = jsonDecode(json);
                final name = map['itemName'] as String?;
                final price = (map['subtotal'] as num?)?.toDouble() ?? 0.0;
                final count = (map['quantity'] as num?)?.toInt() ?? 1;

                if (name == null) continue;

                itemRevenue[name] = (itemRevenue[name] ?? 0) + price;
                itemQty[name] = (itemQty[name] ?? 0) + count;
              } catch (_) {
                continue;
              }
            }
          }

          switch (granularity) {
            case _ReportGranularity.hourly:
              if (o.orderedAt.year == start.year &&
                  o.orderedAt.month == start.month &&
                  o.orderedAt.day == start.day) {
                final idx = o.orderedAt.hour - dayStartHour;
                if (idx >= 0 && idx < buckets.length) {
                  buckets[idx] += amt;
                }
              }
              break;
            case _ReportGranularity.daily:
              final diff = o.orderedAt.difference(start).inDays;
              if (diff >= 0 && diff < buckets.length) {
                buckets[diff] += amt;
              }
              break;
            case _ReportGranularity.weekly:
              final diffDays = o.orderedAt.difference(start).inDays;
              final weekIdx = diffDays ~/ 7;
              if (weekIdx >= 0 && weekIdx < buckets.length) {
                buckets[weekIdx] += amt;
              }
              break;
            case _ReportGranularity.monthly:
              final monthDiff = (o.orderedAt.year - start.year) * 12 + (o.orderedAt.month - start.month);
              if (monthDiff >= 0 && monthDiff < buckets.length) {
                buckets[monthDiff] += amt;
              }
              break;
          }
        } else if (o.status == 'voided') {
          totalVoids += o.totalAmount;
        }
      }

      offset += batchSize;
      if (batch.length < batchSize) break;
    }

    final topCashier = cashierCounts.isEmpty 
      ? '—' 
      : cashierCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    final breakdownItems = paymentTotals.entries
        .map((e) => PaymentBreakdownItem(
              method: e.key,
              amount: e.value,
              percentage: totalSales > 0 ? (e.value / totalSales) * 100 : 0.0,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final topItemList = itemRevenue.entries
        .map((e) => TopItem(
              name: e.key,
              qtySold: itemQty[e.key] ?? 0,
              revenue: e.value,
            ))
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    final spots = List.generate(
      buckets.length,
      (i) => FlSpot(i.toDouble(), buckets[i]),
    );

    state = state.copyWith(
      isLoading: false,
      totalOrders: completedOrdersCount,
      totalSales: totalSales,
      averageOrderValue: completedOrdersCount > 0 ? (totalSales / completedOrdersCount) : 0.0,
      highestSale: highestSale,
      totalVoids: totalVoids,
      totalRefunds: totalRefunds,
      topCashierName: topCashier,
      paymentBreakdown: breakdownItems,
      topItems: topItemList.take(5).toList(),
      revenueSpots: spots,
      xLabels: xLabels,
      tooltipLabels: tooltipLabels,
    );
  }
}

final reportsProvider =
    NotifierProvider<ReportsNotifier, ReportState>(() => ReportsNotifier());
