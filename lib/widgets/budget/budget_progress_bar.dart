import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class BudgetProgressBar extends StatelessWidget {
  final String category;
  final String spent;
  final String limit;
  final double progress;
  final Color accent;

  const BudgetProgressBar({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    required this.progress,
    required this.accent,
  });

  Color get _barColor {
    if (progress >= 1.0) return AppColors.error;
    if (progress >= 0.85) return AppColors.warning;
    if (progress >= 0.6) return const Color(0xFFEAB308);
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category + amounts
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(accent == AppColors.warning
                    ? Icons.bolt_rounded
                    : Icons.receipt_long_rounded,
                    color: accent, size: 15),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(
                  category,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: spent,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: ' / $limit',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.inputBorder.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _barColor,
                        _barColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Percentage
          Row(
            children: [
              AppText(
                '${(progress * 100).toStringAsFixed(0)}%',
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: _barColor,
              ),
              const SizedBox(width: 6),
              if (progress >= 1.0)
                AppText(
                  'Over budget',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                )
              else if (progress >= 0.85)
                AppText(
                  'Near limit',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
            ],
          ),
        ],
      ),
    );
  }
}