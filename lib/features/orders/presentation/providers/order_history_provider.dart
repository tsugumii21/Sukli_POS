import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/services/sync_service.dart';

import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/providers/isar_provider.dart';
import '../../../../shared/providers/store_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filter model
// ─────────────────────────────────────────────────────────────────────────────

class OrderFilter {
  final String searchQuery;
  final String? paymentMethod; // null = all
  final String? status; // null = all
  final DateTime? startDate;
  final DateTime? endDate;

  const OrderFilter({
    this.searchQuery = '',
    this.paymentMethod,
    this.status,
    this.startDate,
    this.endDate,
  });

  bool get isActive =>
      searchQuery.isNotEmpty ||
      paymentMethod != null ||
      status != null ||
      startDate != null ||
      endDate != null;

  OrderFilter copyWith({
    String? searchQuery,
    Object? paymentMethod = _sentinel,
    Object? status = _sentinel,
    Object? startDate = _sentinel,
    Object? endDate = _sentinel,
  }) {
    return OrderFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      paymentMethod: paymentMethod == _sentinel
          ? this.paymentMethod
          : paymentMethod as String?,
      status: status == _sentinel ? this.status : status as String?,
      startDate:
          startDate == _sentinel ? this.startDate : startDate as DateTime?,
      endDate: endDate == _sentinel ? this.endDate : endDate as DateTime?,
    );
  }

  static const _sentinel = Object();
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class OrderHistoryState {
  final List<OrderCollection> orders;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final OrderFilter filter;
  final String? errorMessage;

  const OrderHistoryState({
    this.orders = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.filter = const OrderFilter(),
    this.errorMessage,
  });

  OrderHistoryState copyWith({
    List<OrderCollection>? orders,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    OrderFilter? filter,
    String? errorMessage,
  }) {
    return OrderHistoryState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class OrderHistoryNotifier extends Notifier<OrderHistoryState> {
  static const _pageSize = 20;

  @override
  OrderHistoryState build() {
    final storeId = ref.watch(currentStoreIdProvider);
    if (storeId.isEmpty) return const OrderHistoryState(isLoading: false);

    Future.microtask(() => loadFirstPage());
    return const OrderHistoryState(isLoading: true);
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    try {
      await SyncService.instance.syncAll();
    } catch (_) {}
    await loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId.isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      orders: [],
      currentPage: 0,
      hasMore: true,
    );

    try {
      final orders = await _fetchPage(offset: 0, storeId: storeId);
      state = state.copyWith(
        isLoading: false,
        orders: orders,
        currentPage: 1,
        hasMore: orders.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load orders: $e',
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    final storeId = ref.read(currentStoreIdProvider);
    if (storeId.isEmpty) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final offset = state.currentPage * _pageSize;
      final newOrders = await _fetchPage(offset: offset, storeId: storeId);

      state = state.copyWith(
        isLoadingMore: false,
        orders: [...state.orders, ...newOrders],
        currentPage: state.currentPage + 1,
        hasMore: newOrders.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Failed to load more orders: $e',
      );
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(filter: state.filter.copyWith(searchQuery: query));
    loadFirstPage();
  }

  void applyFilter(OrderFilter newFilter) {
    state = state.copyWith(
      filter: newFilter.copyWith(searchQuery: state.filter.searchQuery),
    );
    loadFirstPage();
  }

  void clearFilter() {
    state = state.copyWith(
      filter: OrderFilter(searchQuery: state.filter.searchQuery),
    );
    loadFirstPage();
  }

  /// Returns ALL matching orders (ignoring pagination limits) for exporting.
  Future<List<OrderCollection>> fetchAllForExport() async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId.isEmpty) return [];

    final db = ref.read(isarProvider);
    final cashierId = ref.read(authProvider).selectedCashier?.syncId;
    final f = state.filter;

    var query = db.orderCollections
        .filter()
        .storeIdEqualTo(storeId)
        .isDeletedEqualTo(false);

    if (cashierId != null && cashierId.isNotEmpty) {
      query = query.cashierIdEqualTo(cashierId);
    }

    if (f.searchQuery.isNotEmpty) {
      query = query.orderNumberContains(f.searchQuery, caseSensitive: false);
    }

    if (f.paymentMethod != null) {
      query = query.paymentMethodEqualTo(f.paymentMethod!);
    }

    if (f.status != null) {
      query = query.statusEqualTo(f.status!);
    }

    if (f.startDate != null) {
      query = query.orderedAtGreaterThan(f.startDate!.subtract(const Duration(milliseconds: 1)));
    }
    
    if (f.endDate != null) {
      final endInclusive = DateTime(
        f.endDate!.year,
        f.endDate!.month,
        f.endDate!.day,
        23,
        59,
        59,
      );
      query = query.orderedAtLessThan(endInclusive.add(const Duration(milliseconds: 1)));
    }

    return query.sortByOrderedAtDesc().findAll();
  }

  /// Exports a given list of orders to an Excel file.
  /// Returns the saved file path on success, null on failure.
  Future<String?> exportToExcel(
    List<OrderCollection> orders, {
    String sheetLabel = 'Orders',
  }) async {
    try {
      final excel = Excel.createExcel();
      const sheetName = 'Orders';

      // Rename the auto-generated "Sheet1"
      if (excel.tables.keys.contains('Sheet1')) {
        excel.rename('Sheet1', sheetName);
      }

      // Header row
      excel.appendRow(sheetName, [
        TextCellValue('Order #'),
        TextCellValue('Date & Time'),
        TextCellValue('Cashier'),
        TextCellValue('Item Count'),
        TextCellValue('Subtotal'),
        TextCellValue('Discount'),
        TextCellValue('Total'),
        TextCellValue('Tendered'),
        TextCellValue('Change'),
        TextCellValue('Payment'),
        TextCellValue('Status'),
      ]);

      final fmt = DateFormat('yyyy-MM-dd HH:mm');
      for (final o in orders) {
        excel.appendRow(sheetName, [
          TextCellValue(o.orderNumber),
          TextCellValue(fmt.format(o.orderedAt)),
          TextCellValue(o.cashierName),
          IntCellValue(o.orderItemsJson.length),
          DoubleCellValue(o.subtotal),
          DoubleCellValue(o.discountAmount),
          DoubleCellValue(o.totalAmount),
          DoubleCellValue(o.amountTendered),
          DoubleCellValue(o.changeAmount),
          TextCellValue(o.paymentMethod),
          TextCellValue(o.status),
        ]);
      }

      final bytes = excel.save();
      if (bytes == null) return null;

      // Prefer external storage so the user can find it easily; fall back to
      // app-documents directory which is always available.
      Directory? dir = await getExternalStorageDirectory();
      dir ??= await getApplicationDocumentsDirectory();

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file =
          File('${dir.path}/sukli_orders_${sheetLabel}_$timestamp.xlsx');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  Future<List<OrderCollection>> _fetchPage({
    required int offset,
    required String storeId,
  }) async {
    final db = ref.read(isarProvider);
    final cashierId = ref.read(authProvider).selectedCashier?.syncId;
    final f = state.filter;

    var query = db.orderCollections
        .filter()
        .storeIdEqualTo(storeId)
        .isDeletedEqualTo(false);

    if (cashierId != null && cashierId.isNotEmpty) {
      query = query.cashierIdEqualTo(cashierId);
    }

    if (f.searchQuery.isNotEmpty) {
      query = query.orderNumberContains(f.searchQuery, caseSensitive: false);
    }

    if (f.paymentMethod != null) {
      query = query.paymentMethodEqualTo(f.paymentMethod!);
    }

    if (f.status != null) {
      query = query.statusEqualTo(f.status!);
    }

    if (f.startDate != null) {
      query = query.orderedAtGreaterThan(f.startDate!.subtract(const Duration(milliseconds: 1)));
    }
    
    if (f.endDate != null) {
      final endInclusive = DateTime(
        f.endDate!.year,
        f.endDate!.month,
        f.endDate!.day,
        23,
        59,
        59,
      );
      query = query.orderedAtLessThan(endInclusive.add(const Duration(milliseconds: 1)));
    }

    return query
        .sortByOrderedAtDesc()
        .offset(offset)
        .limit(_pageSize)
        .findAll();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: build ordered list for a preset date range (used by export action)
// ─────────────────────────────────────────────────────────────────────────────

/// Returns a subset of [all] matching [start..end] (both inclusive date-wise).
List<OrderCollection> filterByDateRange(
  List<OrderCollection> all,
  DateTime start,
  DateTime end,
) {
  final endInclusive = DateTime(end.year, end.month, end.day, 23, 59, 59);
  return all
      .where((o) =>
          !o.orderedAt.isBefore(start) && !o.orderedAt.isAfter(endInclusive))
      .toList();
}

/// Provider
final orderHistoryProvider =
    NotifierProvider<OrderHistoryNotifier, OrderHistoryState>(
  OrderHistoryNotifier.new,
);
