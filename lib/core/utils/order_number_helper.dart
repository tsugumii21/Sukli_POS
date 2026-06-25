class OrderNumberHelper {
  /// Returns a short human-readable display version of an order number
  /// Input:  "ORD-20260506-0042-5FT6"
  /// Output: "#0042-5FT6" (if isAdmin is true) or "#0042" (if isAdmin is false)
  static String toShort(String orderNumber, {bool isAdmin = false}) {
    final parts = orderNumber.split('-');
    if (parts.length >= 4) {
      return isAdmin ? '#${parts[2]}-${parts[3]}' : '#${parts[2]}';
    } else if (parts.length == 3) {
      return '#${parts[2]}';
    }
    // Fallback — take last 4 characters
    if (orderNumber.length > 4) {
      return '#${orderNumber.substring(orderNumber.length - 4)}';
    }
    return '#$orderNumber';
  }

  /// Returns the full order number for receipts and admin detail views
  static String toFull(String orderNumber) => orderNumber;
}
