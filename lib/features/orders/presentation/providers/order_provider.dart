import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order_state.dart';

/// OrderNotifier manages the in-progress cart for the current cashier session.
class OrderNotifier extends Notifier<OrderState> {
  @override
  OrderState build() => OrderState.empty;

  /// Adds an item to the cart. If an identical item (same cartKey) exists,
  /// increments its quantity instead of duplicating.
  void addItem(CartItem item) {
    final existing = state.items.indexWhere((e) => e.cartKey == item.cartKey);

    if (existing != -1) {
      final updated = List<CartItem>.from(state.items);
      updated[existing] = updated[existing].copyWith(
        quantity: updated[existing].quantity + item.quantity,
      );
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  /// Removes an item by its cartKey entirely from the cart.
  void removeItem(String cartKey) {
    state = state.copyWith(
      items: state.items.where((e) => e.cartKey != cartKey).toList(),
    );
  }

  /// Updates the quantity for a specific cart item. Removes if quantity <= 0.
  void updateQuantity(String cartKey, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(cartKey);
      return;
    }
    state = state.copyWith(
      items: state.items.map((e) {
        if (e.cartKey == cartKey) return e.copyWith(quantity: newQuantity);
        return e;
      }).toList(),
    );
  }

  /// Updates the notes for a specific cart item.
  void updateNotes(String cartKey, String? notes) {
    state = state.copyWith(
      items: state.items.map((e) {
        if (e.cartKey == cartKey) return e.copyWith(notes: notes);
        return e;
      }).toList(),
    );
  }

  /// Clears the entire cart (e.g. after successful checkout).
  void clearCart() {
    state = OrderState.empty;
  }
}

/// Provider for the active order/cart.
final orderProvider = NotifierProvider<OrderNotifier, OrderState>(
  OrderNotifier.new,
);
