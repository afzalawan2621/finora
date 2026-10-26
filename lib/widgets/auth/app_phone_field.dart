import 'package:flutter/material.dart';

import '../../core/utils/pk_phone_formatter.dart';
import 'app_floating_field.dart';

/// Phone number field with built-in +92 formatter.
class AppPhoneField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool hideErrorText;

  const AppPhoneField({
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
      keyboardType: TextInputType.phone,
      prefixIcon: Icons.phone_outlined,
      inputFormatters: [PkPhoneFormatter()],
    );
  }
}