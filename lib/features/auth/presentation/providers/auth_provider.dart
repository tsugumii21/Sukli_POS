import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../core/utils/pin_helper.dart';
import '../../../../shared/isar_collections/store_collection.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../../../../shared/providers/isar_provider.dart';
import '../../domain/entities/auth_state.dart';

/// AuthNotifier manages in-session auth state for Sukli POS.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState.initial;

  IsarService get _isar => ref.read(isarServiceProvider);

  // ── Select cashier (before PIN entry) ──────────────────────────────────────
  void selectCashier(UserCollection cashier) {
    state = state.copyWith(
      selectedCashier: cashier,
      clearError: true,
    );
  }

  void clearSelection() {
    state = const AuthState(selectedCashier: null, previousCashier: null, isAuthenticated: false, error: null);
  }

  // ── Switch cashier (preserves previous cashier for back button) ───────────
  void switchCashier() {
    state = AuthState(
      selectedCashier: null,
      previousCashier: state.selectedCashier ?? state.previousCashier,
      isAuthenticated: false,
      error: null,
    );
  }

  // ── Restore previous cashier session on Back ─────────────────────────────
  bool restorePreviousCashier() {
    final prev = state.previousCashier;
    if (prev != null) {
      state = AuthState(
        selectedCashier: prev,
        previousCashier: null,
        isAuthenticated: true,
        error: null,
      );
      return true;
    }
    return false;
  }

  // ── Validate PIN against Isar hash ──────────────────────────────────────────
  Future<bool> verifyPin(String pin) async {
    final cashier = state.selectedCashier;
    if (cashier == null) return false;

    if (cashier.pinHash == null) {
      // No PIN set — auto-authenticated
      state = state.copyWith(isAuthenticated: true, clearError: true);
      return true;
    }

    final isValid = PinHelper.verifyPin(pin, cashier.pinHash!);
    if (isValid) {
      state = state.copyWith(isAuthenticated: true, clearError: true);
    } else {
      state = state.copyWith(
        error: 'Incorrect PIN. Please try again.',
        isAuthenticated: false,
      );
    }
    return isValid;
  }

  // ── Reset error state (e.g. after shake animation) ────────────────────────
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  void logout() {
    state = AuthState.initial;
  }

  // ── Load active cashiers from Isar ─────────────────────────────────────────
  Future<List<UserCollection>> loadCashiers() async {
    final store = await _isar.isar.storeCollections
        .filter()
        .isDeletedEqualTo(false)
        .findFirst();

    if (store == null) return [];

    return _isar.isar.userCollections
        .filter()
        .storeIdEqualTo(store.syncId)
        .and()
        .roleEqualTo('cashier')
        .and()
        .statusEqualTo('active')
        .and()
        .isDeletedEqualTo(false)
        .findAll();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
