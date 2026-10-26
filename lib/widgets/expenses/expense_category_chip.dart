import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class ExpenseCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const ExpenseCategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.inputBorder.withOpacity(0.6),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 0,
              offset: const Offset(0, 0),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            AppText(
              label,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.25)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppText(
                  '$count',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? Colors.white
                      : AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}