import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import 'package:isar_community/isar.dart';
import '../../../../shared/providers/store_provider.dart';

/// DashboardData holds all the metrics and lists needed for the Cashier Home Screen.
class DashboardData {
  final double todaySales;
  final int todayOrders;
  final List<MenuItemCollection> favorites;
  final List<OrderCollection> recentOrders;

  DashboardData({
    required this.todaySales,
    required this.todayOrders,
    required this.favorites,
    required this.recentOrders,
  });
}

/// DashboardNotifier manages the state of the Cashier Dashboard.
class DashboardNotifier extends Notifier<AsyncValue<DashboardData>> {
  @override
  AsyncValue<DashboardData> build() {
    final storeId = ref.watch(currentStoreIdProvider);
    if (storeId.isEmpty) return const AsyncValue.loading();

    _init();
    return const AsyncValue.loading();
  }

  IsarService get _isar => IsarService.instance;

  void _init() {
    Future.microtask(() => refreshData());
    final sub1 = _isar.isar.orderCollections.watchLazy().listen((_) => refreshData());
    final sub2 = _isar.isar.menuItemCollections.watchLazy().listen((_) => refreshData());
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

      // 2. Favorites
      final favorites = await _isar.isar.menuItemCollections
          .filter()
          .storeIdEqualTo(storeId)
          .and()
          .isFavoriteEqualTo(true)
          .and()
          .isAvailableEqualTo(true)
          .and()
          .isDeletedEqualTo(false)
          .sortBySortOrder()
          .findAll();

      // 3. Recent orders
      final recent = await _isar.isar.orderCollections
          .filter()
          .storeIdEqualTo(storeId)
          .sortByOrderNumberDesc()
          .limit(10)
          .findAll();

      state = AsyncValue.data(DashboardData(
        todaySales: salesTotal,
        todayOrders: completedAndPartialRefundCount,
        favorites: favorites,
        recentOrders: recent,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for the Dashboard data.
final dashboardProvider =
    NotifierProvider<DashboardNotifier, AsyncValue<DashboardData>>(
  DashboardNotifier.new,
);
