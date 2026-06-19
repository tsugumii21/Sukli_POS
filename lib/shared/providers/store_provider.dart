import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../isar_collections/store_collection.dart';
import 'isar_provider.dart';

/// Loads the current store from Isar.
/// This is the single source of truth for the active store identity.
final currentStoreProvider = StreamProvider<StoreCollection?>((ref) {
  final isar = ref.watch(isarProvider);

  return isar.storeCollections
      .filter()
      .isDeletedEqualTo(false)
      .isActiveEqualTo(true)
      .watch(fireImmediately: true)
      .map((list) => list.isEmpty ? null : list.first);
});

/// Convenience provider — returns the current storeId string or an empty string.
/// This makes it easy to inject into Isar queries.
final currentStoreIdProvider = Provider<String>((ref) {
  final storeAsync = ref.watch(currentStoreProvider);
  return storeAsync.value?.syncId ?? '';
});
