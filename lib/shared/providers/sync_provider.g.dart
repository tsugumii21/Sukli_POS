// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks the result of the last sync operation.

@ProviderFor(LastSyncResult)
final lastSyncResultProvider = LastSyncResultProvider._();

/// Tracks the result of the last sync operation.
final class LastSyncResultProvider
    extends $NotifierProvider<LastSyncResult, SyncResult?> {
  /// Tracks the result of the last sync operation.
  LastSyncResultProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'lastSyncResultProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lastSyncResultHash();

  @$internal
  @override
  LastSyncResult create() => LastSyncResult();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncResult?>(value),
    );
  }
}

String _$lastSyncResultHash() => r'007581b5850d6d399b6355534f2857a351dc068b';

/// Tracks the result of the last sync operation.

abstract class _$LastSyncResult extends $Notifier<SyncResult?> {
  SyncResult? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SyncResult?, SyncResult?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SyncResult?, SyncResult?>, SyncResult?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Tracks if a sync operation is currently in progress.

@ProviderFor(IsSyncing)
final isSyncingProvider = IsSyncingProvider._();

/// Tracks if a sync operation is currently in progress.
final class IsSyncingProvider extends $NotifierProvider<IsSyncing, bool> {
  /// Tracks if a sync operation is currently in progress.
  IsSyncingProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isSyncingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isSyncingHash();

  @$internal
  @override
  IsSyncing create() => IsSyncing();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isSyncingHash() => r'94a8f5d36de0b5b64c2ca64b5ae5926c95944a2a';

/// Tracks if a sync operation is currently in progress.

abstract class _$IsSyncing extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
