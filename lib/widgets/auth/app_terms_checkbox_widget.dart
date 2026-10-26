import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../common/app_checkbox_widget.dart';

/// Reusable terms & conditions checkbox with rich text.
class AppTermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double fontSize;

  const AppTermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.fontSize = 12.5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2, right: 10),
          child: AppCheckbox(
            value: value,
            onChanged: onChanged,
            label: '',
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
              children: const [
                TextSpan(text: AppStrings.agreeToTerms),
                TextSpan(
                  text: AppStrings.termsAndConditions,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: AppStrings.and),
                TextSpan(
                  text: AppStrings.privacyPolicy,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}