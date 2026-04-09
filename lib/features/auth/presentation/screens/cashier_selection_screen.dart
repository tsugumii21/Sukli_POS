import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../providers/auth_provider.dart';
import '../widgets/cashier_card.dart';

/// CashierSelectionScreen — shows a 2-column grid of active cashiers.
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

    return Scaffold(
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryDark
                          : AppColors.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '₱',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontFamily: 'DMSerifDisplay',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Sukli POS',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DMSans',
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            // ── Title ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Cashier',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DMSans',
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            // ── Cashier Grid ───────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark
                              ? AppColors.accentDark
                              : AppColors.accentLight,
                        ),
                      ),
                    )
                  : _cashiers.isEmpty
                      ? Center(
                          child: Text(
                            'No active cashiers found.',
                            style: TextStyle(
                              color: textSecondary,
                              fontFamily: 'DMSans',
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.sm,
                            mainAxisSpacing: AppSpacing.sm,
                            childAspectRatio: 0.85,
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
                                  duration: 400.ms,
                                  delay: Duration(milliseconds: 150 * index),
                                )
                                .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 400.ms,
                                  delay: Duration(milliseconds: 150 * index),
                                );
                          },
                        ),
            ),

            // ── Admin Login Button ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextButton(
                onPressed: () => context.push(RouteConstants.adminLogin),
                child: Text(
                  'Admin Login',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    fontFamily: 'DMSans',
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
