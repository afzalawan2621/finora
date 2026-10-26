import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

class AppEmailField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputAction textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool hideErrorText;

  const AppEmailField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.focusNode,
    this.hideErrorText = false,
  });

  @override
  State<AppEmailField> createState() => _AppEmailFieldState();
}

class _AppEmailFieldState extends State<AppEmailField> {
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focus,
      validator: widget.validator,
      enabled: widget.enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
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
          Icons.mail_outline_rounded,
          size: 20,
        ),
        prefixIconColor: _focus.hasFocus
            ? AppColors.primary
            : AppColors.textHint,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
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