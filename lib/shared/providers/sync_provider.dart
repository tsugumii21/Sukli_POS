import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/sync_service.dart';
import 'isar_provider.dart';
import 'supabase_provider.dart';

/// Provider for the SyncService orchestrator.
final syncServiceProvider = Provider<SyncService>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  return SyncService(isarService, supabaseService);
});

/// Tracks the result of the last sync operation.
final syncResultProvider = StateProvider<SyncResult?>((_) => null);

/// Tracks if a sync operation is currently in progress.
final isSyncingProvider = StateProvider<bool>((_) => false);
