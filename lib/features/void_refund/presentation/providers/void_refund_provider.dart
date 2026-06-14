
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/services/isar_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../../../../shared/providers/store_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tab enum
// ─────────────────────────────────────────────────────────────────────────────

enum VoidRefundTab { voidOrders, refunds, history }

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

// No RefundMeta needed since we have direct fields on OrderCollection now.

/// Immutable state for the Void & Refund screen.
class VoidRefundState {
  const VoidRefundState({
    this.tab = VoidRefundTab.voidOrders,
    this.voidableOrders = const [],
    this.refundableOrders = const [],
    this.historyOrders = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final VoidRefundTab tab;

  /// Orders with status == 'completed' (can be voided or refunded).
  final List<OrderCollection> voidableOrders;

  /// Orders with status == 'completed' (eligible for refund).
  final List<OrderCollection> refundableOrders;

  /// Orders that are already voided or refunded.
  final List<OrderCollection> historyOrders;

  final bool isLoading;
  final String? errorMessage;

  VoidRefundState copyWith({
    VoidRefundTab? tab,
    List<OrderCollection>? voidableOrders,
    List<OrderCollection>? refundableOrders,
    List<OrderCollection>? historyOrders,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      VoidRefundState(
        tab: tab ?? this.tab,
        voidableOrders: voidableOrders ?? this.voidableOrders,
        refundableOrders: refundableOrders ?? this.refundableOrders,
        historyOrders: historyOrders ?? this.historyOrders,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class VoidRefundNotifier extends Notifier<VoidRefundState> {
  @override
  VoidRefundState build() {
    _load();
    _watchOrders();
    return const VoidRefundState(isLoading: true);
  }

  IsarService get _isar => IsarService.instance;
  SyncService get _sync => SyncService.instance;

  void _watchOrders() {
    _isar.isar.orderCollections.watchLazy().listen((_) => _load());
  }

  Future<void> _load() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      // All non-deleted orders sorted newest-first
      final all = await _isar.isar.orderCollections
          .filter()
          .storeIdEqualTo(storeId)
          .and()
          .isDeletedEqualTo(false)
          .sortByOrderedAtDesc()
          .findAll();

      final voidable = all.where((o) => o.status == 'completed').toList();
      final refundable = all.where((o) => o.status == 'completed').toList();
      final history = all
          .where((o) => o.status == 'voided' || o.status == 'refunded')
          .toList();

      state = state.copyWith(
        voidableOrders: voidable,
        refundableOrders: refundable,
        historyOrders: history,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load orders: $e',
      );
    }
  }

  // ── Tab switching ───────────────────────────────────────────────────────────

  void selectTab(VoidRefundTab tab) {
    state = state.copyWith(tab: tab);
  }

  // ── Admin resolution ────────────────────────────────────────────────────────

  /// Resolves the currently logged-in admin user from Isar by matching
  /// the Supabase Auth UID. Returns null if no admin is found.
  Future<UserCollection?> _resolveAdmin() async {
    try {
      final supabaseUser = SupabaseService.instance.currentUser;
      if (supabaseUser == null) return null;

      final storeId = ref.read(currentStoreIdProvider);
      final admins = await _isar.isar.userCollections
          .filter()
          .storeIdEqualTo(storeId)
          .and()
          .roleEqualTo(SupabaseConstants.roleAdmin)
          .and()
          .isDeletedEqualTo(false)
          .findAll();

      // Match by email since admin email is the same as Supabase auth email
      return admins.firstWhere(
        (a) => a.email == supabaseUser.email,
        orElse: () => admins.first,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Void order ──────────────────────────────────────────────────────────────

  /// Marks an order as voided. Records the currently logged-in admin.
  Future<bool> voidOrder({
    required OrderCollection order,
    required String reason,
  }) async {
    try {
      final admin = await _resolveAdmin();
      final now = DateTime.now();
      await _isar.isar.writeTxn(() async {
        order.status = SupabaseConstants.orderStatusVoided;
        order.voidReason = reason;
        order.voidedById = admin?.syncId;
        order.voidedByName = admin?.name;
        order.voidedAt = now;
        order.updatedAt = now;
        order.isSynced = false;
        await _isar.isar.orderCollections.put(order);
      });

      await _sync.addToQueue(
        tableName: SupabaseConstants.ordersTable,
        recordSyncId: order.syncId,
        operation: 'update',
        payload: {
          SupabaseConstants.syncId: order.syncId,
          SupabaseConstants.orderStatus: SupabaseConstants.orderStatusVoided,
          'void_reason': reason,
          'voided_by_id': admin?.syncId,
          'voided_by_name': admin?.name,
          'voided_at': now.toIso8601String(),
          SupabaseConstants.updatedAt: now.toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Void failed: $e');
      return false;
    }
  }

  // ── Refund order ─────────────────────────────────────────────────────────────

  /// Marks an order as refunded. Records the currently logged-in admin.
  Future<bool> refundOrder({
    required OrderCollection order,
    required String reason,
    required double refundAmount,
    required bool isPartial,
  }) async {
    try {
      final admin = await _resolveAdmin();
      final now = DateTime.now();

      await _isar.isar.writeTxn(() async {
        order.status = SupabaseConstants.orderStatusRefunded;
        order.refundReason = reason;
        order.refundAmount = refundAmount;
        order.isPartialRefund = isPartial;
        order.refundedById = admin?.syncId;
        order.refundedByName = admin?.name;
        order.refundedAt = now;
        order.updatedAt = now;
        order.isSynced = false;
        await _isar.isar.orderCollections.put(order);
      });

      await _sync.addToQueue(
        tableName: SupabaseConstants.ordersTable,
        recordSyncId: order.syncId,
        operation: 'update',
        payload: {
          SupabaseConstants.syncId: order.syncId,
          SupabaseConstants.orderStatus: SupabaseConstants.orderStatusRefunded,
          'refund_reason': reason,
          'refund_amount': refundAmount,
          'is_partial_refund': isPartial,
          'refunded_by_id': admin?.syncId,
          'refunded_by_name': admin?.name,
          'refunded_at': now.toIso8601String(),
          SupabaseConstants.updatedAt: now.toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Refund failed: $e');
      return false;
    }
  }

  /// Clears any stored error message.
  void clearError() => state = state.copyWith(clearError: true);
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final voidRefundProvider =
    NotifierProvider<VoidRefundNotifier, VoidRefundState>(
  VoidRefundNotifier.new,
);
