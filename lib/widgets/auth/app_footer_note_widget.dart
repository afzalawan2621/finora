import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

/// Reusable footer note with icon + text.
class AppFooterNote extends StatelessWidget {
  final String text;
  final IconData icon;

  const AppFooterNote({
    super.key,
    required this.text,
    this.icon = Icons.lock_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 12, color: AppColors.textHint),
        const SizedBox(width: 6),
        AppText(
          text,
          fontSize: 11,
          color: AppColors.textHint,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
}