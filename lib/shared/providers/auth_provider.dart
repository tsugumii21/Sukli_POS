import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../core/services/isar_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/pin_helper.dart';
import '../isar_collections/user_collection.dart';

enum AppAuthStatus { loading, unauthenticated, cashierAuthenticated, adminAuthenticated }

class AppAuthState extends Equatable {
  final AppAuthStatus status;
  final UserCollection? currentUser;
  final String? errorMessage;

  const AppAuthState({
    this.status = AppAuthStatus.loading,
    this.currentUser,
    this.errorMessage,
  });

  AppAuthState copyWith({
    AppAuthStatus? status,
    UserCollection? currentUser,
    String? errorMessage,
  }) {
    return AppAuthState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, currentUser, errorMessage];
}

class AppAuthNotifier extends StateNotifier<AppAuthState> {
  final IsarService _isarService;
  final SupabaseService _supabaseService;

  AppAuthNotifier(this._isarService, this._supabaseService) : super(const AppAuthState()) {
    _init();
  }

  Future<void> _init() async {
    // Basic check: if Supabase has a session, we might be an Admin
    final user = _supabaseService.currentUser;
    if (user != null) {
      final isarUser = await _isarService.isar.userCollections
          .filter()
          .emailEqualTo(user.email!)
          .findFirst();
      
      if (isarUser != null && isarUser.role == 'admin') {
        state = state.copyWith(status: AppAuthStatus.adminAuthenticated, currentUser: isarUser);
        return;
      }
    }
    state = state.copyWith(status: AppAuthStatus.unauthenticated);
  }

  Future<bool> loginAsCashier(String cashierSyncId, String pin) async {
    state = state.copyWith(status: AppAuthStatus.loading);
    try {
      final user = await _isarService.isar.userCollections
          .filter()
          .syncIdEqualTo(cashierSyncId)
          .findFirst();

      if (user != null && PinHelper.verifyPin(pin, user.pinHash!)) {
        state = state.copyWith(status: AppAuthStatus.cashierAuthenticated, currentUser: user);
        return true;
      }
      state = state.copyWith(status: AppAuthStatus.unauthenticated, errorMessage: 'Invalid PIN');
      return false;
    } catch (e) {
      state = state.copyWith(status: AppAuthStatus.unauthenticated, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> loginAsAdmin(String email, String password) async {
    state = state.copyWith(status: AppAuthStatus.loading);
    try {
      await _supabaseService.signInWithEmail(email, password);
      final isarUser = await _isarService.isar.userCollections
          .filter()
          .emailEqualTo(email)
          .findFirst();

      if (isarUser != null && isarUser.role == 'admin') {
        state = state.copyWith(status: AppAuthStatus.adminAuthenticated, currentUser: isarUser);
        return true;
      }
      throw 'User not found in local records or not an admin';
    } catch (e) {
      state = state.copyWith(status: AppAuthStatus.unauthenticated, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _supabaseService.signOut();
    state = const AppAuthState(status: AppAuthStatus.unauthenticated);
  }
}

final appAuthProvider = StateNotifierProvider<AppAuthNotifier, AppAuthState>(
  (ref) => AppAuthNotifier(
    ref.watch(isarServiceProvider),
    ref.watch(supabaseServiceProvider),
  ),
);
