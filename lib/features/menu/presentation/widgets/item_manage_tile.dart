import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/item_provider.dart';

/// ItemManageTile — list row for the admin item management screen.
/// Shows image thumbnail, name, price, availability switch, favorite star,
/// and edit/delete action buttons.
class ItemManageTile extends ConsumerWidget {
  const ItemManageTile({
    super.key,
    required this.item,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
    this.animationIndex = 0,
  });

  final MenuItemCollection item;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int animationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final _maroon = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.largeBR,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onEdit();
          },
          borderRadius: AppRadius.largeBR,
          splashColor: _maroon.withValues(alpha: 0.06),
          highlightColor: _maroon.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                // ── Thumbnail ─────────────────────────────────────────
                _Thumbnail(imageUrl: item.imageUrl),
                const SizedBox(width: AppSpacing.sm),

                // ── Info ──────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppTextStyles.bodySemiBold(context)
                            .copyWith(color: textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            CurrencyFormatter.format(item.basePrice),
                            style:
                                AppTextStyles.captionMedium(context).copyWith(
                              color: _maroon,
                            ),
                          ),
                          if (categoryName.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: _CategoryChip(
                                label: categoryName,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Favorite star ─────────────────────────────────────
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    item.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 22,
                    color: item.isFavorite
                        ? const Color(0xFFD4A574)
                        : textSecondary.withValues(alpha: 0.4),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(itemProvider.notifier).toggleFavorite(item);
                  },
                ),

                // ── Available switch ──────────────────────────────────
                Switch.adaptive(
                  value: item.isAvailable,
                  onChanged: (_) {
                    HapticFeedback.lightImpact();
                    ref.read(itemProvider.notifier).toggleAvailability(item);
                  },
                  activeThumbColor: _maroon,
                  activeTrackColor: _maroon.withValues(alpha: 0.3),
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.withValues(alpha: 0.15),
                ),

                // ── Edit button ───────────────────────────────────────
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.edit_outlined,
                      size: 20, color: textSecondary.withValues(alpha: 0.7)),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onEdit();
                  },
                ),

                // ── Delete button ─────────────────────────────────────
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 20, color: AppColors.errorLight),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onDelete();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: (animationIndex * 40).clamp(0, 400)))
        .fadeIn(duration: AppDuration.medium)
        .slideY(begin: 0.08, end: 0, duration: AppDuration.medium, curve: AppCurve.standard);
  }
}

// ── Thumbnail ─────────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imageUrl, this.width = 60, this.height = 60});
  final String? imageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? AppColors.surfaceDark : AppColors.cardLight,
      ),
      child: Icon(
        Icons.restaurant_menu_rounded,
        size: width > 100 ? 48 : 28,
        color: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.1),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: Center(
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Category Chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardLight.withValues(alpha: 0.15)
              : AppColors.cardLight,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: AppTextStyles.caption(context).copyWith(
            color:
                isDark ? AppColors.textSecondaryDark : const Color(0xFF6B4B3E),
          ),
        ),
      );
}

// ── Grid Tile ─────────────────────────────────────────────────────────────────

class ItemManageGridTile extends ConsumerWidget {
  const ItemManageGridTile({
    super.key,
    required this.item,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
    this.animationIndex = 0,
  });

  final MenuItemCollection item;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int animationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onEdit();
          },
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image area — fixed height
              Container(
                height: 95,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
                        ),
                      )
                    : _buildPlaceholder(isDark),
              ),

              // Content area
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Item name
                    Text(
                      item.name,
                      style: AppTextStyles.bodySemiBold(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Price
                    Text(
                      CurrencyFormatter.format(item.basePrice),
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: isDark ? AppColors.accentDark : AppColors.accentLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Category name
                    Text(
                      categoryName.isNotEmpty ? categoryName : 'Uncategorized',
                      style: AppTextStyles.caption(context).copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Bottom row — star + toggle + delete
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.xs, AppSpacing.sm, AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Star button
                    SizedBox(
                      width: 28, height: 28,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(maxWidth: 28, maxHeight: 28),
                        icon: Icon(
                          item.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 18,
                          color: item.isFavorite
                              ? AppColors.warningLight
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(itemProvider.notifier).toggleFavorite(item);
                        },
                      ),
                    ),

                    // Available toggle
                    SizedBox(
                      width: 38,
                      height: 24,
                      child: Transform.scale(
                        scale: 0.70,
                        alignment: Alignment.center,
                        child: Switch.adaptive(
                          value: item.isAvailable,
                          onChanged: (_) {
                            HapticFeedback.lightImpact();
                            ref.read(itemProvider.notifier).toggleAvailability(item);
                          },
                          activeThumbColor: Colors.white,
                          activeTrackColor: isDark ? AppColors.accentDark : AppColors.accentLight,
                        ),
                      ),
                    ),

                    // Delete button
                    SizedBox(
                      width: 28, height: 28,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(maxWidth: 28, maxHeight: 28),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.errorLight,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onDelete();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
    .animate(delay: Duration(milliseconds: (animationIndex * 40).clamp(0, 400)))
    .fadeIn(duration: AppDuration.medium)
    .slideY(begin: 0.08, end: 0, duration: AppDuration.medium, curve: AppCurve.standard);
  }

  Widget _buildPlaceholder(bool isDark) {
    return Center(
      child: Icon(
        Icons.restaurant_rounded,
        size: 32,
        color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withValues(alpha: 0.3),
      ),
    );
  }
}

