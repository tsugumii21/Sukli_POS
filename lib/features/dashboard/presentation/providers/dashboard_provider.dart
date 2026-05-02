import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import 'package:isar_community/isar.dart';

/// DashboardData holds all the metrics and lists needed for the Cashier Home Screen.
class DashboardData {
  final double todaySales;
  final int todayOrders;
  final List<MenuItemCollection> favorites;
  final List<MenuItemCollection> lowStockItems;
  final List<OrderCollection> recentOrders;

  DashboardData({
    required this.todaySales,
    required this.todayOrders,
    required this.favorites,
    required this.lowStockItems,
    required this.recentOrders,
  });
}

/// DashboardNotifier manages the state of the Cashier Dashboard.
/// Migrated to Notifier for consistency with the modern Riverpod API used in this project.
class DashboardNotifier extends Notifier<AsyncValue<DashboardData>> {
  @override
  AsyncValue<DashboardData> build() {
    _init();
    return const AsyncValue.loading();
  }

  IsarService get _isar => IsarService.instance;

  void _init() {
    // Initial refresh
    Future.microtask(() => refreshData());
    
    // Watch for changes in orders and items
    _isar.isar.orderCollections.watchLazy().listen((_) => refreshData());
    _isar.isar.menuItemCollections.watchLazy().listen((_) => refreshData());
  }

  Future<void> refreshData() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // 1. Today's Totals
      final todayOrders = await _isar.isar.orderCollections
          .filter()
          .orderedAtBetween(startOfDay, endOfDay)
          .and()
          .statusEqualTo('completed')
          .findAll();

      final salesTotal = todayOrders.fold<double>(0, (sum, order) => sum + order.totalAmount);

      // 2. Favorites
      final favorites = await _isar.isar.menuItemCollections
          .filter()
          .isFavoriteEqualTo(true)
          .and()
          .isAvailableEqualTo(true)
          .and()
          .isDeletedEqualTo(false)
          .sortBySortOrder()
          .findAll();

      // 3. Low Stock alert
      final items = await _isar.isar.menuItemCollections
          .filter()
          .trackInventoryEqualTo(true)
          .and()
          .isDeletedEqualTo(false)
          .findAll();
      
      final lowStock = items.where((item) {
        final current = item.stockQuantity ?? 0;
        final threshold = item.lowStockThreshold ?? 5.0;
        return current <= threshold;
      }).toList();

      // 4. Recent
      final recent = await _isar.isar.orderCollections
          .where()
          .sortByOrderedAtDesc()
          .limit(5)
          .findAll();

      state = AsyncValue.data(DashboardData(
        todaySales: salesTotal,
        todayOrders: todayOrders.length,
        favorites: favorites,
        lowStockItems: lowStock,
        recentOrders: recent,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for the Dashboard data.
final dashboardProvider = NotifierProvider<DashboardNotifier, AsyncValue<DashboardData>>(
  DashboardNotifier.new,
);
