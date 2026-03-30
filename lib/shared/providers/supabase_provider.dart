import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';

/// Provider exposing the SupabaseService singleton.
final supabaseServiceProvider = Provider<SupabaseService>((ref) => SupabaseService());

/// Convenience provider for the SupabaseClient.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => ref.watch(supabaseServiceProvider).client,
);

/// Auth state stream provider from Supabase.
final authStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(supabaseServiceProvider).authStateChanges,
);

/// Current Supabase User provider.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(supabaseServiceProvider).currentUser;
});
