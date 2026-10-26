import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Generic modern floating-label text field.
/// Use as base for Name, Phone, and other custom fields.
class AppFloatingField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool hideErrorText;
  final int? maxLength;
  final bool isPassword;

  const AppFloatingField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.focusNode,
    this.hideErrorText = true,
    this.maxLength,
    this.isPassword = false,
  });

  @override
  State<AppFloatingField> createState() => _AppFloatingFieldState();
}

class _AppFloatingFieldState extends State<AppFloatingField> {
  late FocusNode _focus;
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(() => setState(() {}));
    _obscure = widget.isPassword;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  void _toggleObscure() => setState(() => _obscure = !_obscure);

  @override
  Widget build(BuildContext context) {
    final isFocused = _focus.hasFocus;

    return TextFormField(
      controller: widget.controller,
      focusNode: _focus,
      validator: widget.validator,
      enabled: widget.enabled,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      autocorrect: false,
      style: TextStyles.bodyMd.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: TextStyle(
          color: isFocused
              ? AppColors.primary
              : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
        labelStyle: TextStyle(
          color: isFocused
              ? AppColors.primary
              : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: AppColors.textHint,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 20)
            : null,
        prefixIconColor:
        isFocused ? AppColors.primary : AppColors.textHint,
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
          ),
          color: AppColors.textHint,
          onPressed: _toggleObscure,
          splashRadius: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        )
            : widget.suffixIcon,
        filled: true,
        fillColor: isFocused
            ? AppColors.primary.withOpacity(0.04)
            : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        counterText: '',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.inputBorder,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.4,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.6,
          ),
        ),
        errorStyle: widget.hideErrorText
            ? const TextStyle(
          fontSize: 0,
          height: 0,
          color: Colors.transparent,
        )
            : null,
      ),
    );
  }
}