import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'app_text_widget.dart';

/// Reusable "OR" divider.
class AppOrDivider extends StatelessWidget {
  final String text;

  const AppOrDivider({
    super.key,
    this.text = 'OR',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xFFE2E8F0),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: AppText(
            text,
            fontSize: 10,
            color: AppColors.textHint,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const Expanded(
          child: Divider(
            color: Color(0xFFE2E8F0),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}