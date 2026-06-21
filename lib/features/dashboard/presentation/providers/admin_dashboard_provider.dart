import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/isar_collections/sync_queue_collection.dart';
import '../../../../shared/providers/store_provider.dart';

/// AdminDashboardData holds all metrics and lists for the Admin Dashboard.
class AdminDashboardData {
  final double totalSalesToday;
  final int ordersToday;
  final int pendingSyncCount;
  final List<OrderCollection> recentOrders;

  AdminDashboardData({
    required this.totalSalesToday,
    required this.ordersToday,
    required this.pendingSyncCount,
    required this.recentOrders,
  });
}

/// AdminDashboardNotifier manages state for the Admin Dashboard screen.
class AdminDashboardNotifier extends Notifier<AsyncValue<AdminDashboardData>> {
  @override
  AsyncValue<AdminDashboardData> build() {
    final storeId = ref.watch(currentStoreIdProvider);
    if (storeId.isEmpty) return const AsyncValue.loading();

    _init();
    return const AsyncValue.loading();
  }

  IsarService get _isar => IsarService.instance;

  void _init() {
    Future.microtask(() => refreshData());
    final sub1 = _isar.isar.orderCollections.watchLazy().listen((_) => refreshData());
    final sub2 = _isar.isar.syncQueueCollections.watchLazy().listen((_) => refreshData());
    ref.onDispose(() {
      sub1.cancel();
      sub2.cancel();
    });
  }

  Future<void> refreshData() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final storeId = ref.read(currentStoreIdProvider);
      if (storeId.isEmpty) return;

      // 1. Today's Totals (Completed and Refunded)
      final todayOrders = await _isar.isar.orderCollections
          .filter()
          .storeIdEqualTo(storeId)
          .and()
          .orderedAtBetween(startOfDay, endOfDay)
          .and()
          .group((q) => q.statusEqualTo('completed').or().statusEqualTo('refunded'))
          .findAll();

      double salesTotal = 0.0;
      int completedAndPartialRefundCount = 0;

      for (final order in todayOrders) {
        if (order.status == 'completed') {
          salesTotal += order.totalAmount;
          completedAndPartialRefundCount++;
        } else if (order.status == 'refunded') {
          final refundAmt = order.refundAmount ?? order.totalAmount;
          final netAmount = order.totalAmount - refundAmt;
          salesTotal += netAmount;
          if (netAmount > 0.0) {
            completedAndPartialRefundCount++;
          }
        }
      }

      // 2. Pending sync queue items
      final pendingItems = await _isar.isar.syncQueueCollections
          .filter()
          .statusEqualTo('pending')
          .findAll();

      // 3. Recent 6 orders (any status)
      final recentOrders = await _isar.isar.orderCollections
          .filter()
          .storeIdEqualTo(storeId)
          .sortByOrderNumberDesc()
          .limit(6)
          .findAll();

      state = AsyncValue.data(AdminDashboardData(
        totalSalesToday: salesTotal,
        ordersToday: completedAndPartialRefundCount,
        pendingSyncCount: pendingItems.length,
        recentOrders: recentOrders,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for the Admin Dashboard data.
final adminDashboardProvider =
    NotifierProvider<AdminDashboardNotifier, AsyncValue<AdminDashboardData>>(
  AdminDashboardNotifier.new,
);
