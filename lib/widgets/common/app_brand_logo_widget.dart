import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'app_text_widget.dart';

/// Reusable brand logo + name + subtitle row.
class AppBrandLogo extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData icon;
  final double logoSize;

  const AppBrandLogo({
    super.key,
    required this.name,
    required this.subtitle,
    this.icon = Icons.account_balance_wallet_rounded,
    this.logoSize = 54,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: logoSize * 0.5,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              name,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
            const SizedBox(height: 2),
            AppText(
              subtitle,
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ],
    );
  }
}