import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class ShimmerOrderList extends StatelessWidget {
  final int itemCount;
  const ShimmerOrderList({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.surfaceDark : AppColors.cardLight,
      highlightColor: isDark ? AppColors.cardDark : AppColors.primaryLightVariant,
      child: ListView.builder(
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

class ShimmerMenuGrid extends StatelessWidget {
  final int itemCount;
  const ShimmerMenuGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.surfaceDark : AppColors.cardLight,
      highlightColor: isDark ? AppColors.cardDark : AppColors.primaryLightVariant,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
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
