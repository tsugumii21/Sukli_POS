import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core theme imports
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

// Constants imports
import '../../../../core/constants/route_constants.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() =>
      _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  // 6 separate controllers for each digit
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String _otpCode = '';

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    // Only allow digits
    if (value.isNotEmpty && !RegExp(r'^\d$').hasMatch(value)) {
      _controllers[index].clear();
      return;
    }

    if (value.isNotEmpty) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last digit entered — auto submit
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    }

    // Build OTP string
    setState(() {
      _otpCode = _controllers.map((c) => c.text).join();
      _errorMessage = null;
    });
  }

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      // Move to previous field on backspace when empty
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  Future<void> _verifyOtp() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit code.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: code,
        type: OtpType.signup,
      );

      if (response.user != null) {
        if (mounted) {
          context.go(RouteConstants.adminLogin);
        }
      } else {
        setState(() => _errorMessage = 'Verification failed. Please try again.');
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message.contains('expired')
            ? 'Code has expired. Please request a new one.'
            : e.message.contains('invalid')
                ? 'Incorrect code. Please check and try again.'
                : 'Verification failed: ${e.message}';
        // Clear OTP fields on error
        for (final c in _controllers) { c.clear(); }
        _focusNodes[0].requestFocus();
      });
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() { _isResending = true; _errorMessage = null; });
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New code sent to ${widget.email}',
              style: AppTextStyles.body(context)
                .copyWith(color: Colors.white)),
            backgroundColor: AppColors.successLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mediumBR),
          ),
        );
        // Clear fields for new code
        for (final c in _controllers) { c.clear(); }
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to resend code. Try again.');
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              SizedBox(height: AppSpacing.xl),

              // Icon
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: AppColors.accentLight.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mark_email_unread_rounded,
                  size: 44,
                  color: AppColors.accentLight),
              )
              .animate()
              .scale(duration: const Duration(milliseconds: 350), curve: Curves.elasticOut)
              .fadeIn(),

              SizedBox(height: AppSpacing.lg),

              // Title
              Text('Check your email',
                style: AppTextStyles.h1(context),
                textAlign: TextAlign.center,
              )
              .animate(delay: 150.ms)
              .fadeIn().slideY(begin: 0.2),

              SizedBox(height: AppSpacing.sm),

              // Subtitle
              Text(
                'We sent a 6-digit verification code to',
                style: AppTextStyles.bodySecondary(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                widget.email,
                style: AppTextStyles.bodySemiBold(context).copyWith(
                  color: AppColors.accentLight),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppSpacing.xl),

              // OTP input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) => _onKeyPressed(index, event),
                      child: SizedBox(
                        width: 48, height: 56,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly],
                          style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: _controllers[index].text.isNotEmpty
                              ? AppColors.accentLight.withValues(alpha: 0.08)
                              : AppColors.cardLight,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.mediumBR,
                              borderSide: BorderSide(
                                color: AppColors.primaryLight, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.mediumBR,
                              borderSide: BorderSide(
                                color: AppColors.primaryLight, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.mediumBR,
                              borderSide: BorderSide(
                                color: AppColors.accentLight, width: 2.5),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (val) => _onDigitEntered(index, val),
                        ),
                      ),
                    ),
                  );
                }),
              )
              .animate(delay: 200.ms)
              .fadeIn().slideY(begin: 0.1),

              SizedBox(height: AppSpacing.lg),

              // Error message
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight.withValues(alpha: 0.08),
                    borderRadius: AppRadius.mediumBR,
                    border: Border.all(
                      color: AppColors.errorLight.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    Icon(Icons.error_outline_rounded,
                      size: 16, color: AppColors.errorLight),
                    SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(_errorMessage!,
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColors.errorLight))),
                  ]),
                )
                .animate().fadeIn().slideY(begin: 0.1),

              SizedBox(height: AppSpacing.xl),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_isLoading || _otpCode.length < 6)
                    ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLight,
                    disabledBackgroundColor:
                      AppColors.accentLight.withValues(alpha: 0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.pillBR),
                  ),
                  child: _isLoading
                    ? SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                    : Text('Verify Account',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              )
              .animate(delay: 300.ms).fadeIn(),

              SizedBox(height: AppSpacing.md),

              // Resend code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Didn't receive the code? ",
                    style: AppTextStyles.captionSecondary(context)),
                  GestureDetector(
                    onTap: _isResending ? null : _resendCode,
                    child: _isResending
                      ? SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentLight))
                      : Text('Resend',
                          style: AppTextStyles.captionMedium(context).copyWith(
                            color: AppColors.accentLight,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.accentLight)),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.lg),

              // Info box
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warningLight.withValues(alpha: 0.10),
                  borderRadius: AppRadius.mediumBR,
                  border: Border.all(
                    color: AppColors.warningLight.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.warningLight),
                    SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Check your spam folder if you don\'t see the email. The code is valid for 24 hours.',
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColors.warningLight),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
