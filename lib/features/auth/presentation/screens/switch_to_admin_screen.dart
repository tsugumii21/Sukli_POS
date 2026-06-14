import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/isar_collections/user_collection.dart';
import '../../../../shared/providers/store_provider.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_auth_provider.dart';
import 'package:sukli_pos/core/theme/app_text_styles.dart';

class SwitchToAdminScreen extends ConsumerStatefulWidget {
  const SwitchToAdminScreen({super.key});

  @override
  ConsumerState<SwitchToAdminScreen> createState() => _SwitchToAdminScreenState();
}

class _SwitchToAdminScreenState extends ConsumerState<SwitchToAdminScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final adminEmail = SupabaseService.instance.currentUser?.email;
    if (adminEmail != null) {
      _emailCtrl.text = adminEmail;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInAsAdmin() async {
    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your admin email and password.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      // Sign in with Supabase — verifies the password is correct
      final response = await SupabaseService.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (response.user == null) {
        setState(() => _errorMessage = 'Invalid email or password.');
        return;
      }

      // Verify this Supabase user is an admin in Isar
      final isar = IsarService.instance.isar;
      final storeId = ref.read(currentStoreIdProvider);
      final adminUser = await isar.userCollections
          .filter()
          .emailEqualTo(_emailCtrl.text.trim())
          .roleEqualTo('admin')
          .storeIdEqualTo(storeId)
          .isDeletedEqualTo(false)
          .findFirst();

      if (adminUser == null) {
        // Not an admin for this store
        await SupabaseService.instance.client.auth.signOut();
        setState(() => _errorMessage = 'This account is not an admin for this store.');
        return;
      }

      // Update auth provider to admin state
      // Do NOT log out cashier session — just elevate to admin
      await ref.read(adminAuthProvider.notifier)
          .signIn(_emailCtrl.text.trim(), _passwordCtrl.text);

      if (mounted) context.go(RouteConstants.adminHome);

    } catch (e) {
      setState(() => _errorMessage = 'Incorrect password. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCashierName = ref.watch(authProvider).selectedCashier?.name ?? 'Cashier';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final borderCol = isDark ? AppColors.borderDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: bg,
      
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── TOP SECTION (maroon gradient, same as welcome screen) ──
            Container(
              height: MediaQuery.of(context).size.height * 0.38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [AppColors.accentDark, AppColors.secondaryDark]
                      : [AppColors.accentLight, const Color(0xFF8B3A44)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  // Back button top-left
                  Positioned(
                    top: 48, left: 16,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  // Center content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        // Admin icon
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text('Admin Access',
                          style: GoogleFonts.dmSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Enter your admin password to continue',
                          style: AppTextStyles.body(context).copyWith(color: Colors.white.withValues(alpha:0.80),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // ── BOTTOM SECTION ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    
                    // Currently logged in cashier info card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: AppRadius.mediumBR,
                        border: Border.all(
                          color: borderCol,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: accent.withValues(alpha: 0.12),
                            child: Text(
                              // First letter of cashier name
                              currentCashierName.isNotEmpty
                                ? currentCashierName[0].toUpperCase()
                                : 'C',
                              style: AppTextStyles.bodyLarge(context).copyWith(
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Signed in as',
                                style: AppTextStyles.label(context).copyWith(color: textSecondary),
                              ),
                              Text(currentCashierName,
                                style: AppTextStyles.bodySemiBold(context).copyWith(color: textPrimary),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successLight
                                .withValues(alpha: 0.12),
                              borderRadius: AppRadius.pillBR,
                            ),
                            child: Text('Cashier',
                              style: AppTextStyles.label(context).copyWith(color: AppColors.successLight),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Admin email label
                    Text('ADMIN EMAIL',
                      style: AppTextStyles.label(context).copyWith(color: textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    
                    if (SupabaseService.instance.currentUser?.email != null) ...[
                      // Show email as read-only text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                          borderRadius: AppRadius.mediumBR,
                          border: Border.all(color: borderCol),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.email_outlined, color: textSecondary, size: 22),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              SupabaseService.instance.currentUser!.email!,
                              style: AppTextStyles.body(context).copyWith(color: textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Admin email field fallback
                      AppTextField(
                        hint: 'admin@email.com',
                        controller: _emailCtrl,
                        prefixIcon: Icon(Icons.email_outlined, color: textSecondary, size: 22),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Admin password label
                    Text('ADMIN PASSWORD',
                      style: AppTextStyles.label(context).copyWith(color: textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    
                    // Admin password field
                    AppTextField(
                      hint: 'Enter admin password',
                      controller: _passwordCtrl,
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: textSecondary, size: 22),
                      obscureText: _obscurePassword,
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
                    ),
                    
                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight.withValues(alpha: 0.08),
                          borderRadius: AppRadius.mediumBR,
                          border: Border.all(
                            color: AppColors.errorLight.withValues(alpha: 0.25)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline_rounded,
                            size: 16, color: AppColors.errorLight),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(_errorMessage!,
                              style: AppTextStyles.body(context).copyWith(color: AppColors.errorLight))),
                        ]),
                      ),
                    ],
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Sign In as Admin button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _signInAsAdmin,
                        icon: _isLoading
                          ? SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: isDark ? AppColors.primaryDark : Colors.white))
                          : Icon(Icons.admin_panel_settings_rounded,
                              size: 18, color: isDark ? AppColors.primaryDark : Colors.white),
                        label: Text(
                          _isLoading ? 'Verifying...' : 'Sign In as Admin',
                          style: AppTextStyles.bodySemiBold(context).copyWith(
                            color: isDark ? AppColors.primaryDark : Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: isDark ? AppColors.primaryDark : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.pillBR),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Cancel — go back to cashier
                    Center(
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Text('Cancel — stay as cashier',
                          style: AppTextStyles.body(context).copyWith(color: textSecondary),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
