import '../../../../shared/isar_collections/user_collection.dart';

/// AuthState holds the current authentication state for Sukli POS.
class AuthState {
  final UserCollection? selectedCashier;
  final UserCollection? previousCashier;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.selectedCashier,
    this.previousCashier,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    UserCollection? selectedCashier,
    UserCollection? previousCashier,
    bool? isAuthenticated,
    String? error,
    bool clearError = false,
    bool clearCashier = false,
    bool clearPrevious = false,
  }) {
    return AuthState(
      selectedCashier:
          clearCashier ? null : selectedCashier ?? this.selectedCashier,
      previousCashier:
          clearPrevious ? null : previousCashier ?? this.previousCashier,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: clearError ? null : error ?? this.error,
    );
  }

  static const initial = AuthState(
    selectedCashier: null,
    previousCashier: null,
    isAuthenticated: false,
    error: null,
  );
}
