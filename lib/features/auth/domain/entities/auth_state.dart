import '../../../../shared/isar_collections/user_collection.dart';

/// AuthState holds the current authentication state for Sukli POS.
class AuthState {
  final UserCollection? selectedCashier;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.selectedCashier,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    UserCollection? selectedCashier,
    bool? isAuthenticated,
    String? error,
    bool clearError = false,
    bool clearCashier = false,
  }) {
    return AuthState(
      selectedCashier:
          clearCashier ? null : selectedCashier ?? this.selectedCashier,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: clearError ? null : error ?? this.error,
    );
  }

  static const initial = AuthState(
    selectedCashier: null,
    isAuthenticated: false,
    error: null,
  );
}
