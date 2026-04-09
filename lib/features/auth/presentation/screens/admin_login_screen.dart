import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_overlay.dart';

/// AdminLoginScreen — email/password login for admin users via Supabase.
class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SupabaseService.instance.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) context.go(RouteConstants.adminHome);
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid email or password. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    final avatarBg =
        isDark ? AppColors.primaryDark : AppColors.accentLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // ── Logo ─────────────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: avatarBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.admin_panel_settings_rounded,
                            color: AppColors.white, size: 32),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Title ─────────────────────────────────────────────────
                  Center(
                    child: Text(
                      'Admin Login',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DMSans',
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                  const SizedBox(height: 4),

                  Center(
                    child: Text(
                      'Sign in with your admin credentials',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        fontFamily: 'DMSans',
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Email ─────────────────────────────────────────────────
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'admin@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(Icons.email_outlined,
                        color: textSecondary, size: 20),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: AppSpacing.md),

                  // ── Password ──────────────────────────────────────────────
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: '••••••••',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    prefixIcon: Icon(Icons.lock_outline_rounded,
                        color: textSecondary, size: 20),
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
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

                  // ── Error message ─────────────────────────────────────────
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: (isDark
                                ? AppColors.errorDark
                                : AppColors.errorLight)
                            .withOpacity(0.1),
                        borderRadius: AppRadius.smallBR,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: isDark
                                  ? AppColors.errorDark
                                  : AppColors.errorLight,
                              size: 18),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.errorDark
                                    : AppColors.errorLight,
                                fontSize: 13,
                                fontFamily: 'DMSans',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).shakeX(),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // ── Login Button ──────────────────────────────────────────
                  AppPrimaryButton(
                    label: 'Sign In',
                    onPressed: _login,
                    isLoading: _isLoading,
                    icon: Icons.login_rounded,
                  ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
