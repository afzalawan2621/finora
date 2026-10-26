import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

/// Reusable green success strip with check icon + title + subtitle.
class AppSuccessStrip extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? color;

  const AppSuccessStrip({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.check_rounded,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.success;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 3),
                AppText(
                  subtitle,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}