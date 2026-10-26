import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

class AppPasswordField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool isRequired;
  final bool enabled;
  final TextInputAction textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool hideErrorText;

  const AppPasswordField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.isRequired = false,
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.focusNode,
    this.hideErrorText = false,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  late bool _obscure;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _obscure = true;
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  void _toggleObscure() => setState(() => _obscure = !_obscure);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focus,
      validator: widget.validator,
      obscureText: _obscure,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
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
          color: _focus.hasFocus
              ? AppColors.primary
              : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
        labelStyle: TextStyle(
          color: _focus.hasFocus
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
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          size: 20,
        ),
        prefixIconColor: _focus.hasFocus
            ? AppColors.primary
            : AppColors.textHint,
        suffixIcon: IconButton(
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
        ),
        filled: true,
        fillColor: _focus.hasFocus
            ? AppColors.primary.withOpacity(0.04)
            : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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