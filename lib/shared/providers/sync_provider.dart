import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/services/sync_service.dart';

part 'sync_provider.g.dart';

/// Provider for the SyncService singleton.
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService.instance;
});

/// Stream of connectivity status.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Whether the device is currently online.
final isOnlineProvider = Provider<bool>((ref) {
  final results = ref.watch(connectivityProvider).value;
  if (results == null || results.isEmpty) return false;
  return !results.contains(ConnectivityResult.none);
});

/// Tracks the result of the last sync operation.
@riverpod
class LastSyncResult extends _$LastSyncResult {
  @override
  SyncResult? build() => null;

  void set(SyncResult result) => state = result;
}

/// Tracks if a sync operation is currently in progress.
@riverpod
class IsSyncing extends _$IsSyncing {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}
