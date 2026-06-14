import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/isar_collections/order_collection.dart';
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
  final String topCashierName;
  final List<PaymentBreakdownItem> paymentBreakdown;
  final List<TopItem> topItems;
  final List<FlSpot> revenueSpots;

  const ReportState({
    required this.period,
    this.customStart,
    this.customEnd,
    this.isLoading = false,
    this.totalSales = 0.0,
    this.totalOrders = 0,
    this.averageOrderValue = 0.0,
    this.highestSale = 0.0,
    this.topCashierName = '—',
    this.paymentBreakdown = const [],
    this.topItems = const [],
    this.revenueSpots = const [FlSpot(0, 0)],
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
    String? topCashierName,
    List<PaymentBreakdownItem>? paymentBreakdown,
    List<TopItem>? topItems,
    List<FlSpot>? revenueSpots,
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
      topCashierName: topCashierName ?? this.topCashierName,
      paymentBreakdown: paymentBreakdown ?? this.paymentBreakdown,
      topItems: topItems ?? this.topItems,
      revenueSpots: revenueSpots ?? this.revenueSpots,
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
    if (storeId.isEmpty) return;

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

    state = state.copyWith(isLoading: true);

    final totalOrders = await isar.orderCollections
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .orderedAtBetween(start, end)
        .and()
        .isDeletedEqualTo(false)
        .count();

    if (totalOrders == 0) {
      state = state.copyWith(
        isLoading: false,
        totalOrders: 0,
        totalSales: 0.0,
        averageOrderValue: 0.0,
        topCashierName: '—',
        paymentBreakdown: const [],
        topItems: const [],
        revenueSpots: const [FlSpot(0, 0)],
      );
      return;
    }

    double totalSales = 0.0;
    double highestSale = 0.0;
    final cashierCounts = <String, int>{};
    final paymentTotals = <String, double>{};
    final itemRevenue = <String, double>{};
    final itemQty = <String, int>{};

    List<double> buckets;
    final now = DateTime.now();
    bool isHourly = false;
    bool isMonthly = false;

    final days = end.difference(start).inDays + 1;
    if (state.period == ReportPeriod.day) {
      buckets = List<double>.filled(24, 0);
      isHourly = true;
    } else if (state.period == ReportPeriod.week) {
      buckets = List<double>.filled(7, 0);
    } else if (state.period == ReportPeriod.month) {
      buckets = List<double>.filled(30, 0);
    } else if (state.period == ReportPeriod.year) {
      buckets = List<double>.filled(12, 0);
      isMonthly = true;
    } else {
      if (days <= 31) {
        buckets = List<double>.filled(days, 0);
      } else {
        buckets = List<double>.filled(12, 0);
        isMonthly = true;
      }
    }

    int offset = 0;
    const batchSize = AppConstants.reportsBatchSize;

    while (true) {
      final batch = await isar.orderCollections
          .filter()
          .storeIdEqualTo(storeId)
          .and()
          .orderedAtBetween(start, end)
          .and()
          .isDeletedEqualTo(false)
          .offset(offset)
          .limit(batchSize)
          .findAll();

      if (batch.isEmpty) break;

      for (final o in batch) {
        totalSales += o.totalAmount;
        if (o.totalAmount > highestSale) highestSale = o.totalAmount;
        cashierCounts[o.cashierName] = (cashierCounts[o.cashierName] ?? 0) + 1;
        
        final method = o.paymentMethod.toLowerCase();
        paymentTotals[method] = (paymentTotals[method] ?? 0) + o.totalAmount;

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

        if (isHourly) {
          if (o.orderedAt.year == now.year &&
              o.orderedAt.month == now.month &&
              o.orderedAt.day == now.day) {
            buckets[o.orderedAt.hour] += o.totalAmount;
          }
        } else if (isMonthly) {
          final month = o.orderedAt.month - 1;
          if (month >= 0 && month < 12) {
            buckets[month] += o.totalAmount;
          }
        } else {
          final diff = o.orderedAt.difference(start).inDays;
          if (diff >= 0 && diff < buckets.length) {
            buckets[diff] += o.totalAmount;
          }
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
              percentage: (e.value / totalSales) * 100,
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
      totalOrders: totalOrders,
      totalSales: totalSales,
      averageOrderValue: totalSales / totalOrders,
      highestSale: highestSale,
      topCashierName: topCashier,
      paymentBreakdown: breakdownItems,
      topItems: topItemList.take(5).toList(),
      revenueSpots: spots,
    );
  }
}

final reportsProvider =
    NotifierProvider<ReportsNotifier, ReportState>(() => ReportsNotifier());
