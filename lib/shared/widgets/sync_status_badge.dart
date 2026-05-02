import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// SyncStatusBadge — Modern connectivity indicator with a pulsing status dot.
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({
    super.key,
    required this.isOnline,
    required this.isSyncing,
  });

  final bool isOnline;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if (!isOnline) {
      statusColor = const Color(0xFFC2445B); // Error/Offline
      statusText = 'Offline';
    } else if (isSyncing) {
      statusColor = const Color(0xFFD4A574); // Warning/Syncing
      statusText = 'Syncing...';
    } else {
      statusColor = const Color(0xFF7B9971); // Success/Synced
      statusText = 'Synced';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing Dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.8, end: 1.2, duration: 800.ms, curve: Curves.easeInOut)
              .boxShadow(begin: const BoxShadow(blurRadius: 0), end: BoxShadow(blurRadius: 4, color: statusColor.withValues(alpha: 0.4))),

          const SizedBox(width: 8),

          Text(
            statusText,
            style: GoogleFonts.inter(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
