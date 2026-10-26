import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/text_styles.dart';
import 'app_text_widget.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool isObscure;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool readOnly;
  final bool enabled;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefixWidget;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final String? initialValue;
  final bool isRequired;
  final EdgeInsets? contentPadding;
  final Color? fillColor;

  /// Hide the default red error text under the field.
  /// Set to true when using AppErrorOverlay for showing errors.
  final bool hideErrorText;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.isObscure = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.readOnly = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixWidget,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.initialValue,
    this.isRequired = false,
    this.contentPadding,
    this.fillColor,
    this.hideErrorText = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword || widget.isObscure;
  }

  void _toggleObscure() {
    setState(() => _obscure = !_obscure);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              AppText(
                widget.label!,
                style: TextStyles.label,
              ),
              if (widget.isRequired)
                AppText(
                  ' *',
                  style: TextStyles.label,
                  color: AppColors.error,
                ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _obscure,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          style: TextStyles.bodyMd,
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: widget.fillColor ?? AppColors.surface,
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(
                  horizontal: AppSizes.lg,
                  vertical: AppSizes.lg,
                ),
            prefixIcon: widget.prefixWidget ??
                (widget.prefixIcon != null
                    ? Icon(
                  widget.prefixIcon,
                  color: AppColors.textSecondary,
                  size: AppSizes.iconLg,
                )
                    : null),
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: AppSizes.iconLg,
              ),
              onPressed: _toggleObscure,
            )
                : widget.suffixIcon,
            counterText: '',

            // ─── Hide error text & border when hideErrorText = true ───
            errorStyle: widget.hideErrorText
                ? const TextStyle(
              fontSize: 0,
              height: 0,
              color: Colors.transparent,
            )
                : null,
            errorBorder: widget.hideErrorText
                ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            )
                : null,
            focusedErrorBorder: widget.hideErrorText
                ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            )
                : null,
          ),
        ),
      ],
    );
  }
}