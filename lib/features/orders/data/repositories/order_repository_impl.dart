import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/isar_collections/sync_queue_collection.dart';
import '../../domain/entities/order_state.dart';

/// Handles persisting completed orders and sync queue entries
/// in a single atomic Isar transaction.
class OrderRepositoryImpl {
  const OrderRepositoryImpl(this._isar);
  final Isar _isar;

  static const _uuid = Uuid();

  /// Saves a completed order to Isar and enqueues it for Supabase sync.
  Future<OrderCollection> saveOrder({
    required String storeId,
    required OrderState orderState,
    required String cashierId,
    required String cashierName,
    required double amountTendered,
    required String paymentMethod,
    String? paymentReference,
    double discountAmount = 0.0,
    String? discountReason,
  }) async {
    final now = DateTime.now();
    final syncId = _uuid.v4();
    final orderNumber = await _generateOrderNumber(
      now: now,
      storeId: storeId,
      cashierName: cashierName,
      cashierId: cashierId,
    );

    final itemsJson = orderState.items
        .map((item) => jsonEncode({
              'itemSyncId': item.itemSyncId,
              'itemName': item.itemName,
              'variantName': item.variantName,
              'unitPrice': item.unitPrice,
              'quantity': item.quantity,
              'modifiers': item.modifiers,
              'notes': item.notes,
              'subtotal': item.subtotal,
            }))
        .toList();

    final subtotal = orderState.total;
    final totalAmount = subtotal - discountAmount;
    final change = (amountTendered - totalAmount).clamp(0.0, double.infinity);

    final order = OrderCollection()
      ..syncId = syncId
      ..storeId = storeId
      ..orderNumber = orderNumber
      ..cashierId = cashierId
      ..cashierName = cashierName
      ..orderItemsJson = itemsJson
      ..subtotal = subtotal
      ..discountAmount = discountAmount
      ..discountReason = discountReason
      ..taxAmount = 0.0
      ..totalAmount = totalAmount
      ..amountTendered = amountTendered
      ..changeAmount = change
      ..paymentMethod = paymentMethod
      ..paymentReference = paymentReference
      ..status = 'completed'
      ..orderedAt = now
      ..createdAt = now
      ..updatedAt = now
      ..isSynced = false
      ..isDeleted = false;

    await _isar.writeTxn(() async {
      // 1. Persist the order
      await _isar.orderCollections.put(order);

      // 2. Enqueue order for Supabase sync
      await _isar.syncQueueCollections.put(
        _buildSyncEntry(
          tableName: 'orders',
          recordSyncId: syncId,
          operation: 'insert',
          payload: _orderPayload(order),
          now: now,
        ),
      );
    });

    return order;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Generates a continuous sequential order number for THIS store.
  Future<String> _generateOrderNumber({
    required DateTime now,
    required String storeId,
    required String cashierName,
    required String cashierId,
  }) async {
    final count = await _isar.orderCollections
        .filter()
        .storeIdEqualTo(storeId)
        .count();

    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final seq = (count + 1).toString().padLeft(4, '0');

    // Generate cashier suffix using initials + last 3 characters of cashier ID
    final nameParts = cashierName.trim().split(RegExp(r'\s+'));
    String initials = '';
    if (nameParts.isNotEmpty) {
      initials = nameParts.map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();
    }
    if (initials.length > 3) initials = initials.substring(0, 3);
    if (initials.isEmpty) initials = 'CS';

    final idPart = cashierId.length >= 3
        ? cashierId.substring(cashierId.length - 3).toUpperCase()
        : '000';

    final cashierSuffix = '${initials}_$idPart';

    return '${AppConstants.orderPrefix}-$dateStr-$seq-$cashierSuffix';
  }

  SyncQueueCollection _buildSyncEntry({
    required String tableName,
    required String recordSyncId,
    required String operation,
    required String payload,
    required DateTime now,
  }) {
    return SyncQueueCollection()
      ..operationId = _uuid.v4()
      ..tableName = tableName
      ..recordSyncId = recordSyncId
      ..operation = operation
      ..payloadJson = payload
      ..retryCount = 0
      ..maxRetries = AppConstants.maxSyncRetries
      ..status = 'pending'
      ..createdAt = now;
  }

  String _orderPayload(OrderCollection order) {
    return jsonEncode({
      'sync_id': order.syncId,
      'store_id': order.storeId,
      'order_number': order.orderNumber,
      'cashier_id': order.cashierId,
      'cashier_name': order.cashierName,
      'order_items_json': order.orderItemsJson,
      'subtotal': order.subtotal,
      'discount_amount': order.discountAmount,
      'discount_reason': order.discountReason,
      'tax_amount': order.taxAmount,
      'total_amount': order.totalAmount,
      'amount_tendered': order.amountTendered,
      'change_amount': order.changeAmount,
      'payment_method': order.paymentMethod,
      'payment_reference': order.paymentReference,
      'status': order.status,
      'ordered_at': order.orderedAt.toUtc().toIso8601String(),
      'created_at': order.createdAt.toUtc().toIso8601String(),
      'updated_at': order.updatedAt.toUtc().toIso8601String(),
    });
  }
}
