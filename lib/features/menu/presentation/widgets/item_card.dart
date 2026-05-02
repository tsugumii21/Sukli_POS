import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/isar_collections/menu_item_collection.dart';

/// ItemCard — Displays a single menu item in the grid.
/// Shows image, name, price, and availability. Unavailable items are dimmed.
class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final MenuItemCollection item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final isUnavailable = !item.isAvailable;

    // Parse variants to show price range
    final variants = _parseVariants(item.variantsJson);
    final hasVariants = variants.isNotEmpty;

    return GestureDetector(
      onTap: isUnavailable ? null : onTap,
      child: Opacity(
        opacity: isUnavailable ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Item Image / Placeholder ────────────────────────────
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
                              ),
                            )
                          : _buildPlaceholder(isDark),
                    ),

                    const SizedBox(height: 12),

                    // ── Item Name ────────────────────────────────────────────
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),

                    const Spacer(),

                    // ── Price ────────────────────────────────────────────────
                    Text(
                      hasVariants
                          ? 'from ${CurrencyFormatter.format(item.basePrice)}'
                          : CurrencyFormatter.format(item.basePrice),
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF8B4049),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Unavailable Overlay ─────────────────────────────────────
              if (isUnavailable)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Unavailable',
                      style: GoogleFonts.inter(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              // ── Variant badge ───────────────────────────────────────────
              if (hasVariants && !isUnavailable)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4049).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${variants.length} sizes',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8B4049),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Center(
      child: Icon(
        Icons.restaurant_menu_rounded,
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.1),
        size: 36,
      ),
    );
  }

  List<Map<String, dynamic>> _parseVariants(List<String> json) {
    try {
      return json
          .map((v) => jsonDecode(v) as Map<String, dynamic>)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
