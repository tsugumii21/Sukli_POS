import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/sync_service.dart';

/// Provider for the SyncService singleton.
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService.instance;
});

/// Stream of connectivity status.
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Whether the device is currently online.
final isOnlineProvider = Provider<bool>((ref) {
  final conn = ref.watch(connectivityProvider).valueOrNull;
  return conn != null && conn != ConnectivityResult.none;
});

/// Tracks the result of the last sync operation.
final syncResultProvider = StateProvider<SyncResult?>((_) => null);

/// Tracks if a sync operation is currently in progress.
final isSyncingProvider = StateProvider<bool>((_) => false);
