import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class AppTransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final bool isIncome;

  const AppTransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final color =
    isIncome ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.inputBorder.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.18),
                  color.withOpacity(0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: color.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          // Title + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                AppText(
                  subtitle,
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
          // Amount
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isIncome
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 12,
                  color: color,
                ),
                const SizedBox(width: 4),
                AppText(
                  amount,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}