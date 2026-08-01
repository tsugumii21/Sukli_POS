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

  /// Returns a clean short order sequence for receipt header (e.g. "#0043-JD_123" or "#0043")
  static String toReceiptShort(String orderNumber) {
    final parts = orderNumber.split('-');
    if (parts.length >= 3) {
      return '#${parts.sublist(2).join('-')}';
    }
    return orderNumber.startsWith('#') ? orderNumber : '#$orderNumber';
  }

  /// Returns the full order number for receipts and admin detail views
  static String toFull(String orderNumber) => orderNumber;
}
