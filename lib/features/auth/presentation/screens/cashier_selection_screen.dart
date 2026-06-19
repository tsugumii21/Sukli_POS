import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_layout.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../../../../shared/providers/active_role_provider.dart';
import '../../../../core/services/supabase_service.dart';
import '../providers/admin_auth_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/cashier_card.dart';
import 'package:sukli_pos/core/theme/app_text_styles.dart';

/// CashierSelectionScreen — shows a 2-column grid of active cashiers.
/// Redesigned with Plus Jakarta Sans and Inter for a high-end fintech aesthetic.
class CashierSelectionScreen extends ConsumerStatefulWidget {
  const CashierSelectionScreen({super.key});

  @override
  ConsumerState<CashierSelectionScreen> createState() =>
      _CashierSelectionScreenState();
}

class _CashierSelectionScreenState
    extends ConsumerState<CashierSelectionScreen> {
  List<UserCollection> _cashiers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCashiers();
  }

  Future<void> _loadCashiers() async {
    final cashiers = await ref.read(authProvider.notifier).loadCashiers();
    if (mounted) {
      setState(() {
        _cashiers = cashiers;
        _isLoading = false;
      });
    }
  }

  void _onCashierTapped(UserCollection cashier) {
    HapticFeedback.lightImpact();
    ref.read(authProvider.notifier).selectCashier(cashier);

    if (cashier.pinHash != null) {
      context.push(RouteConstants.cashierPin);
    } else {
      // No PIN set — go straight in
      ref.read(authProvider.notifier).verifyPin('').then((_) {
        if (mounted) context.go(RouteConstants.cashierHome);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final adminAuth = ref.watch(adminAuthProvider);
    final isAdminLoggedIn = adminAuth.value != null ||
        SupabaseService.instance.currentUser != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isAdminLoggedIn) {
          ref.read(activeRoleProvider.notifier).setRole(ActiveRole.admin);
          context.go(RouteConstants.adminHome);
        } else {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteConstants.welcome);
          }
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    if (isAdminLoggedIn) ...[
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(RouteConstants.adminHome);
                          }
                        },
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: textSecondary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ] else ...[
                      // Logo in a modern rounded box
                      Container(
                        width: 48, height: 48,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.cardLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/images/sukli_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],
                    Text(
                      'Sukli',
                      style: AppTextStyles.h3(context).copyWith(color: textPrimary),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
  
              const SizedBox(height: AppSpacing.md),
  
              // ── Title ──────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Cashier',
                        style: AppTextStyles.h2(context).copyWith(color: textPrimary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose your profile to start selling',
                      style: AppTextStyles.body(context).copyWith(
                        color: isDark ? AppColors.textSecondaryDark : textSecondary.withValues(alpha:0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0),
  
              const SizedBox(height: AppSpacing.xl),
  
              // ── Cashier Grid ───────────────────────────────────────────────
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppColors.accentDark : AppColors.accentLight,
                          ),
                        ),
                      )
                    : _cashiers.isEmpty
                        ? Center(
                            child: Text(
                              'No active cashiers found.',
                              style: AppTextStyles.bodyMedium(context).copyWith(color: textSecondary),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                        gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveLayout.gridColumns(context),
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisSpacing: AppSpacing.md,
                              childAspectRatio: ResponsiveLayout.adaptiveAspectRatio(context, phoneRatio: 0.85),
                            ),
                            itemCount: _cashiers.length,
                            itemBuilder: (context, index) {
                              final cashier = _cashiers[index];
                              return CashierCard(
                                cashier: cashier,
                                onTap: () => _onCashierTapped(cashier),
                              )
                                  .animate()
                                  .fadeIn(
                                    duration: 600.ms,
                                    delay: Duration(milliseconds: 100 * index),
                                  )
                                  .scaleXY(
                                    begin: 0.95,
                                    end: 1.0,
                                    duration: 600.ms,
                                    curve: Curves.easeOutBack,
                                    delay: Duration(milliseconds: 100 * index),
                                  );
                            },
                          ),
              ),
  
              const SizedBox(height: AppSpacing.lg),
              
              Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (isAdminLoggedIn) {
                      context.push(RouteConstants.switchToAdmin);
                    } else {
                      context.push(RouteConstants.adminLogin);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAdminLoggedIn
                            ? Icons.arrow_back_rounded
                            : Icons.admin_panel_settings_outlined,
                        size: 16,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAdminLoggedIn ? 'Back to Admin' : 'Switch to Admin',
                        style: AppTextStyles.body(context).copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
              
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
