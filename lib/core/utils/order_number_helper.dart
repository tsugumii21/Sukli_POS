class OrderNumberHelper {
  /// Returns a short human-readable display version of an order number
  /// Input:  "ORD-20260506-0042-5FT6", cashierName: "John Doe"
  /// Output: "#0042 • John Doe" (or "#0042" if cashierName is null/empty)
  static String toShort(String orderNumber, {String? cashierName, bool isAdmin = false}) {
    String numPart = orderNumber;
    final parts = orderNumber.split('-');
    if (parts.length >= 3) {
      numPart = parts[2];
    } else if (orderNumber.length > 4) {
      numPart = orderNumber.substring(orderNumber.length - 4);
    }

    final seq = '#$numPart';
    if (cashierName != null && cashierName.trim().isNotEmpty) {
      return '$seq • ${cashierName.trim()}';
    }
    return seq;
  }

  /// Returns the full order number for receipts and admin detail views
  static String toFull(String orderNumber) => orderNumber;
}
