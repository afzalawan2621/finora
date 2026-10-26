import 'package:flutter/material.dart';

import 'app_floating_field.dart';

/// Full Name field with person icon + word capitalization.
class AppNameField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool hideErrorText;
  final IconData? icon;

  const AppNameField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.enabled = true,
    this.hideErrorText = true,
    this.icon = Icons.person_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return AppFloatingField(
      label: label,
      hint: hint,
      controller: controller,
      validator: validator,
      enabled: enabled,
      hideErrorText: hideErrorText,
      textCapitalization: TextCapitalization.words,
      prefixIcon: icon,
    );
  }
}