import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/errors/app_exception.dart' as app_ex;

/// AdminAuthNotifier manages Supabase admin authentication state.
/// Uses AsyncNotifier so the UI can reactively show loading/error/data states.
class AdminAuthNotifier extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() {
    // Return the currently authenticated Supabase user (if any)
    return SupabaseService.instance.currentUser;
  }

  /// Signs in with email and password via Supabase Auth.
  /// Returns true on success, throws [AuthException] on failure.
  Future<bool> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      final response = await SupabaseService.instance
          .signInWithEmail(email.trim(), password);

      final user = response.user;
      if (user != null) {
        // Fetch remote store and cashier data for this admin
        await SyncService.instance.pullStoreData(email);
      }
      state = AsyncData(user);

      // Start background sync as soon as admin is authenticated
      SyncService.instance.startPeriodicSync();

      return user != null;
    } on app_ex.AuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    } catch (e, st) {
      final error = app_ex.AuthException('Sign in failed: $e');
      state = AsyncError(error, st);
      rethrow;
    }
  }

  /// Signs out of Supabase and stops background sync.
  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      SyncService.instance.stopPeriodicSync();
      await SupabaseService.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_active_role');
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final adminAuthProvider = AsyncNotifierProvider<AdminAuthNotifier, User?>(
  AdminAuthNotifier.new,
);
