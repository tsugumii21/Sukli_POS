import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// AppTextField — themed text input widget for Sukli POS.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.isReadOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.maxLines = 1,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool isReadOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fillColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final focusedBorderColor =
        isDark ? AppColors.accentDark : AppColors.accentLight;
    final errorBorderColor =
        isDark ? AppColors.errorDark : AppColors.errorLight;
    final hintColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final labelColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Opacity(
      opacity: isReadOnly ? 0.6 : 1.0,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: isReadOnly,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        maxLines: obscureText ? 1 : maxLines,
        focusNode: focusNode,
        autofocus: autofocus,
        style: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          fontSize: 15,
          fontFamily: 'DMSans',
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          hintStyle: TextStyle(
            color: hintColor,
            fontSize: 14,
            fontFamily: 'DMSans',
          ),
          labelStyle: TextStyle(
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'DMSans',
          ),
          floatingLabelStyle: TextStyle(
            color: focusedBorderColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'DMSans',
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.mediumBR,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.mediumBR,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.mediumBR,
            borderSide:
                BorderSide(color: focusedBorderColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.mediumBR,
            borderSide: BorderSide(color: errorBorderColor, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.mediumBR,
            borderSide: BorderSide(color: errorBorderColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
