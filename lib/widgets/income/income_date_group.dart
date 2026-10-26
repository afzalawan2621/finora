import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class IncomeDateGroup extends StatelessWidget {
  final String label;
  final String total;
  final int count;

  const IncomeDateGroup({
    super.key,
    required this.label,
    required this.total,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.success, Color(0xFF34D399)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          AppText(
            label,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText(
              '$count',
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.inputBorder.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 8),
          AppText(
            total,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: -0.2,
          ),
        ],
      ),
    );
  }
}