import 'package:flutter/material.dart';

import 'app_floating_field.dart';

/// Company name field with business icon.
class AppCompanyField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool hideErrorText;

  const AppCompanyField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.enabled = true,
    this.hideErrorText = true,
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
      prefixIcon: Icons.business_outlined,
    );
  }
}