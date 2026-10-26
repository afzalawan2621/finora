import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

/// Reusable back-link chip (soft primary background).
class AppBackChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;

  const AppBackChip({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.arrow_back_ios_new_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.primary),
            const SizedBox(width: 6),
            AppText(
              label,
              fontSize: 12.5,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
  }
}