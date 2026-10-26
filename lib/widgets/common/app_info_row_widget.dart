import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'app_text_widget.dart';

/// Reusable info row with icon, label, and value.
/// Perfect for showing user details, metadata, etc.
class AppInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double fontSize;

  const AppInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ─── Icon container ───
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: AppColors.inputBorder.withOpacity(0.6),
            ),
          ),
          child: Icon(
            icon,
            size: 15,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        // ─── Label + Value ───
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                label,
                fontSize: 10.5,
                color: AppColors.textHint,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              const SizedBox(height: 2),
              AppText(
                value,
                fontSize: fontSize,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}