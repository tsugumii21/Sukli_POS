import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../core/services/isar_service.dart';

/// Provider exposing the initialized IsarService singleton.
final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

/// Convenience provider for the Isar instance.
final isarProvider = Provider<Isar>((ref) => ref.watch(isarServiceProvider).isar);
