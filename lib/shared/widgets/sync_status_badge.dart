import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/sync_provider.dart';

/// Enum representing the current sync state of the device.
enum _SyncStatus { synced, syncing, pending, offline }

/// SyncStatusBadge — small pill badge showing real-time sync and connectivity status.
class SyncStatusBadge extends ConsumerWidget {
  const SyncStatusBadge({super.key, this.pendingCount = 0});

  final int pendingCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSyncing = ref.watch(isSyncingProvider);
    final isOnline = ref.watch(isOnlineProvider);

    final _SyncStatus status;
    if (!isOnline) {
      status = _SyncStatus.offline;
    } else if (isSyncing) {
      status = _SyncStatus.syncing;
    } else if (pendingCount > 0) {
      status = _SyncStatus.pending;
    } else {
      status = _SyncStatus.synced;
    }

    final (dotColor, label) = switch (status) {
      _SyncStatus.synced  => (AppColors.successLight, 'Synced'),
      _SyncStatus.syncing => (AppColors.warningLight, 'Syncing...'),
      _SyncStatus.pending => (AppColors.warningLight, '$pendingCount pending'),
      _SyncStatus.offline => (AppColors.errorLight, 'Offline'),
    };

    final bg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    Widget dot = Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
    );

    // Pulsing animation when syncing
    if (status == _SyncStatus.syncing) {
      dot = dot
          .animate(onPlay: (c) => c.repeat())
          .scaleXY(begin: 1, end: 1.5, duration: 600.ms)
          .then()
          .scaleXY(begin: 1.5, end: 1, duration: 600.ms);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.pillBR,
        boxShadow: AppShadow.level1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'DMSans',
            ),
          ),
        ],
      ),
    );
  }
}
