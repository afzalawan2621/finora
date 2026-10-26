import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'app_text_widget.dart';

/// Reusable section label with accent gradient bar.
/// e.g. "LOGIN DETAILS"
class AppSectionLabel extends StatelessWidget {
  final String label;

  const AppSectionLabel({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        AppText(
          label,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: 1.4,
        ),
      ],
    );
  }
}