import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../providers/users_provider.dart';

/// UserTile — displays a single user row with avatar, name, email,
/// role chip, active toggle, and edit tap callback.
class UserTile extends ConsumerWidget {
  const UserTile({
    super.key,
    required this.user,
    required this.onTap,
    this.animationIndex = 0,
  });

  final UserCollection user;
  final VoidCallback onTap;
  final int animationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;

    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final isCashier = user.role == 'cashier';
    
    final primaryColor = isDark ? AppColors.accentDark : AppColors.secondaryLight;
    final secondaryColor = isDark ? AppColors.accentDarkLight : AppColors.accentLight;

    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.largeBR,
        boxShadow: AppShadow.level1,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.largeBR,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: AppRadius.largeBR,
          splashColor: primaryColor.withValues(alpha: 0.06),
          highlightColor: primaryColor.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                // ── Avatar ────────────────────────────────────────────────
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCashier
                        ? primaryColor.withValues(alpha: 0.1)
                        : secondaryColor.withValues(alpha: 0.12),
                    border: Border.all(
                      color: isCashier
                          ? primaryColor.withValues(alpha: 0.2)
                          : secondaryColor.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: hasAvatar
                        ? (user.avatarUrl!.startsWith('http')
                            ? Image.network(user.avatarUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildInitial(context, initial, isCashier, primaryColor, secondaryColor))
                            : Image.file(File(user.avatarUrl!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildInitial(context, initial, isCashier, primaryColor, secondaryColor)))
                        : _buildInitial(context, initial, isCashier, primaryColor, secondaryColor),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // ── Name + email ──────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppTextStyles.bodySemiBold(context).copyWith(
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email.contains('@cashier.local') ? 'Cashier Account' : user.email,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppTextStyles.captionSecondary(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // ── Role chip ─────────────────────────────────────────────
                _RoleChip(role: user.role),
                const SizedBox(width: AppSpacing.sm),

                // ── Active toggle ─────────────────────────────────────────
                _ActiveToggle(user: user),
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

  Widget _buildInitial(BuildContext context, String initial, bool isCashier, Color primaryColor, Color secondaryColor) {
    return Center(
      child: Text(
        initial,
        style: AppTextStyles.bodyLarge(context).copyWith(
          color: isCashier ? primaryColor : secondaryColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ── Role Chip ─────────────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = role == 'admin';

    final primaryColor = isDark ? AppColors.accentDark : AppColors.secondaryLight;

    final bg = isAdmin
        ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.1)
        : (isDark
            ? AppColors.cardLight.withValues(alpha: 0.15)
            : AppColors.cardLight);

    final textColor = isAdmin
        ? primaryColor
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.pillBR,
        border: Border.all(
          color: isAdmin
              ? primaryColor.withValues(alpha: 0.3)
              : AppColors.cardLight.withValues(alpha: isDark ? 0.2 : 0.5),
          width: 1,
        ),
      ),
      child: Text(
        isAdmin ? 'Co-Admin' : 'Cashier',
        style: AppTextStyles.label(context).copyWith(
          color: textColor,
        ),
      ),
    );
  }
}

// ── Active Toggle ─────────────────────────────────────────────────────────────

class _ActiveToggle extends ConsumerWidget {
  const _ActiveToggle({required this.user});
  final UserCollection user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = user.status == 'active';
    final activeColor = isDark ? AppColors.accentDark : AppColors.secondaryLight;

    return Switch.adaptive(
      value: isActive,
      onChanged: (_) {
        HapticFeedback.lightImpact();
        ref.read(usersProvider.notifier).toggleStatus(user);
      },
      activeThumbColor: activeColor,
      activeTrackColor: activeColor.withValues(alpha: 0.3),
      inactiveThumbColor: isDark ? AppColors.textDisabledDark : Colors.grey.shade400,
      inactiveTrackColor: (isDark ? AppColors.borderDark : Colors.grey).withValues(alpha: 0.15),
    );
  }
}
