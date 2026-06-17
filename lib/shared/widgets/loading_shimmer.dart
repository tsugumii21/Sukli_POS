import 'package:flutter/material.dart';
import '../../core/utils/responsive_layout.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Standard shimmer box that can be sized and shaped arbitrarily.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.surfaceDark : AppColors.cardLight;
    final highlightColor = isDark ? AppColors.surfaceDarkElevated : AppColors.primaryLightVariant;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? AppRadius.smallBR,
        ),
      ),
    );
  }
}

/// Shimmer loader for order lists, user lists, and logs.
class ShimmerOrderList extends StatelessWidget {
  const ShimmerOrderList({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.surfaceDark : AppColors.cardLight;
    final highlightColor = isDark ? AppColors.surfaceDarkElevated : AppColors.primaryLightVariant;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.mediumBR,
          ),
        ),
      ),
    );
  }
}

/// Shimmer loader for menu grids.
class ShimmerMenuGrid extends StatelessWidget {
  const ShimmerMenuGrid({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.surfaceDark : AppColors.cardLight;
    final highlightColor = isDark ? AppColors.surfaceDarkElevated : AppColors.primaryLightVariant;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveLayout.gridColumns(context),
          childAspectRatio: ResponsiveLayout.adaptiveAspectRatio(context, phoneRatio: 0.70),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
        itemCount: itemCount,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.mediumBR,
          ),
        ),
      ),
    );
  }
}

/// Shimmer loader for forms or detail views.
class ShimmerDetailsLoader extends StatelessWidget {
  const ShimmerDetailsLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 150, height: 24),
          const SizedBox(height: AppSpacing.md),
          const ShimmerBox(width: double.infinity, height: 180),
          const SizedBox(height: AppSpacing.lg),
          const ShimmerBox(width: 100, height: 24),
          const SizedBox(height: AppSpacing.md),
          const ShimmerBox(width: double.infinity, height: 60),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerBox(width: double.infinity, height: 60),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerBox(width: double.infinity, height: 60),
        ],
      ),
    );
  }
}
