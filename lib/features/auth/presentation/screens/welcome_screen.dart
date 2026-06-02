import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:sukli_pos/core/theme/app_text_styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // ── BRANDING ──
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/images/sukli_logo.png',
                    fit: BoxFit.contain,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 400.ms),
              ),

              const SizedBox(height: 32),

              Text(
                'Sukli',
                textAlign: TextAlign.center,
                style: AppTextStyles.h2(context).copyWith(color: textPrimary),
              )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 8),

              Text(
                'Point of Sale for everyday retail.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(context).copyWith(color: textSecondary),
              ).animate(delay: 200.ms).fadeIn(duration: 500.ms),

              const Spacer(flex: 2),

              // ── VALUE PROPS ──
              ...[
                (
                  Icons.wifi_off_outlined,
                  'Works offline',
                  'No internet? No problem.'
                ),
                (
                  Icons.cloud_sync_outlined,
                  'Auto cloud sync',
                  'Your data is always backed up.'
                ),
                (
                  Icons.people_outline,
                  'Multi-cashier',
                  'Manage your whole team easily.'
                ),
              ].asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(e.value.$1, color: accent, size: 24),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.value.$2,
                              style: AppTextStyles.body(context).copyWith(color: textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              e.value.$3,
                              style: AppTextStyles.body(context).copyWith(color: textSecondary.withValues(alpha:0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: Duration(milliseconds: 300 + (e.key * 100)))
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.1, end: 0);
              }),

              const Spacer(flex: 3),

              // ── ACTIONS ──
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push(RouteConstants.signup),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: isDark ? AppColors.primaryDark : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Set Up My Store',
                    style: AppTextStyles.bodySemiBold(context).copyWith(
                      color: isDark ? AppColors.primaryDark : Colors.white,
                    ),
                  ),
                ),
              ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push(RouteConstants.adminLogin),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'I already have an account',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySemiBold(context).copyWith(color: accent),
                  ),
                ),
              ).animate(delay: 700.ms).fadeIn(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
