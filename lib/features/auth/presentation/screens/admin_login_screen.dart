import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/isar_collections/category_collection.dart';
import '../../../../shared/isar_collections/store_collection.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/admin_auth_provider.dart';
import 'package:sukli_pos/core/theme/app_text_styles.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    try {
      final success = await ref.read(adminAuthProvider.notifier).signIn(
            _emailController.text,
            _passwordController.text,
          );

      if (success && mounted) {
        final isar = IsarService.instance.isar;
        
        // Direct query to Isar for the active store to avoid Riverpod async provider lags
        final activeStore = await isar.storeCollections
            .filter()
            .isDeletedEqualTo(false)
            .isActiveEqualTo(true)
            .findFirst();
        final storeId = activeStore?.syncId ?? '';

        final cashierCount = await isar.userCollections
            .filter()
            .storeIdEqualTo(storeId)
            .and()
            .roleEqualTo('cashier')
            .isDeletedEqualTo(false)
            .count();
        final categoryCount = await isar.categoryCollections
            .filter()
            .storeIdEqualTo(storeId)
            .and()
            .isDeletedEqualTo(false)
            .count();

        if (!mounted) return;

        if (cashierCount == 0 || categoryCount == 0) {
          context.go(RouteConstants.setupWizard);
        } else {
          context.go(RouteConstants.adminHome);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
        backgroundColor: AppColors.errorLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Invalid login credentials. Please try again.',
                style: AppTextStyles.bodyMedium(context).copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(adminAuthProvider);
    final isLoading = authState.isLoading;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── TOP HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(RouteConstants.welcome);
                      }
                    },
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: AppRadius.mediumBR,
                        border: Border.all(
                            color: textSecondary.withValues(alpha: 0.2)),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // ── LOGO & TITLE ──
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: AppRadius.largeBR,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Image.asset(
                'assets/images/sukli_logo.png',
                fit: BoxFit.contain,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

            const SizedBox(height: AppSpacing.lg),

            Text(
              'Admin Portal',
              style: AppTextStyles.h2(context).copyWith(color: textPrimary),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: AppSpacing.xs),

            Text(
              'Sign in to manage your store',
              style: AppTextStyles.bodyMedium(context).copyWith(color: textSecondary),
            ).animate().fadeIn(delay: 200.ms),

            const Spacer(flex: 2),

            // ── BOTTOM SHEET FORM ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl + AppSpacing.xs, AppSpacing.xl, 0),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'Email address',
                        controller: _emailController,
                        focusNode: _emailFocus,
                        prefixIcon: Icon(Icons.mail_outline_rounded,
                            color: textSecondary, size: 22),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),

                      AppTextField(
                        label: 'Password',
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        prefixIcon: Icon(Icons.lock_outline_rounded,
                            color: textSecondary, size: 22),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      AppPrimaryButton(
                        label: 'Sign In',
                        onPressed: isLoading ? null : _login,
                        isLoading: isLoading,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have a store? ",
                            style: AppTextStyles.bodyMedium(context).copyWith(color: textSecondary),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.push(RouteConstants.signup);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs + 4),
                              child: Text(
                                'Sign Up',
                                style: AppTextStyles.body(context).copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),



                      // Extra padding for safe area
                      SizedBox(
                          height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
                    ],
                  ),
                ),
              ).animate().slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic),
            ),
          ],
        ),
      ),
    );
  }
}
