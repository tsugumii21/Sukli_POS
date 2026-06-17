import 'package:flutter/widgets.dart';

/// Responsive layout utilities for adapting UI across phone and tablet screens.
/// All breakpoints and max widths are defined here as single source of truth.
class ResponsiveLayout {
  ResponsiveLayout._();

  // ── Breakpoints ──────────────────────────────────────────────────────────
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 900;

  // ── Max content width ────────────────────────────────────────────────────
  /// The maximum width the main scrollable body content should occupy.
  /// On tablets, content is centered and capped at this width.
  static const double maxContentWidth = 560;

  // ── Device type helpers ──────────────────────────────────────────────────
  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < phoneMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= phoneMaxWidth;

  // ── Adaptive grid column count ───────────────────────────────────────────
  /// Returns 2 on phones, 3 on small tablets, 4 on large tablets.
  static int gridColumns(BuildContext context, {double itemMinWidth = 160}) {
    final width = MediaQuery.sizeOf(context).width;
    return (width / itemMinWidth).floor().clamp(2, 4);
  }

  /// Returns an appropriate childAspectRatio based on screen width.
  /// On wider screens cards should be slightly more compact vertically.
  static double adaptiveAspectRatio(
    BuildContext context, {
    required double phoneRatio,
    double? tabletRatio,
  }) {
    if (isPhone(context)) return phoneRatio;
    return tabletRatio ?? phoneRatio * 1.1;
  }

  // ── Content wrapper ──────────────────────────────────────────────────────
  /// Wraps child in a centered ConstrainedBox so content doesn't stretch
  /// beyond [maxContentWidth] on wide screens. On phones this is a no-op.
  static Widget constrainedBody({required Widget child}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );
  }
}
