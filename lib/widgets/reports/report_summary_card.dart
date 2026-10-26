import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class ReportSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String? trend;
  final bool trendUp;

  const ReportSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.trend,
    this.trendUp = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.12),
            accent.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: accent, size: 16),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (trendUp
                        ? AppColors.success
                        : AppColors.error)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 10,
                        color: trendUp
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 2),
                      AppText(
                        trend!,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: trendUp
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          AppText(
            value,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          AppText(
            label,
            fontSize: 10.5,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}