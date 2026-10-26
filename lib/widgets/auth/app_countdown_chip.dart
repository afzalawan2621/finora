import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

/// Reusable countdown chip — for resend timers.
class AppCountdownChip extends StatelessWidget {
  final int secondsLeft;
  final String prefix;

  const AppCountdownChip({
    super.key,
    required this.secondsLeft,
    this.prefix = 'Resend available in',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer_outlined,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          AppText(
            '$prefix ${secondsLeft}s',
            fontSize: 12,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}