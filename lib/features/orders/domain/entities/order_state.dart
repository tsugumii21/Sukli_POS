import 'cart_item.dart';

/// OrderState holds the cashier's in-progress order.
/// Immutable — replaced on every cart mutation via the OrderNotifier.
class OrderState {
  final List<CartItem> items;

  const OrderState({this.items = const []});

  /// Total of all line-item subtotals.
  double get total => items.fold<double>(0, (sum, item) => sum + item.subtotal);

  /// Total number of individual items (accounting for quantity).
  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Whether the cart has any items.
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  /// Factory for a fresh, empty order.
  static const OrderState empty = OrderState();

  OrderState copyWith({List<CartItem>? items}) {
    return OrderState(items: items ?? this.items);
  }
}
