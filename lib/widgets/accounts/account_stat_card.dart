import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class AccountStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const AccountStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.inputBorder.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withOpacity(0.18),
                  accent.withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: accent.withOpacity(0.15),
              ),
            ),
            child: Icon(icon, color: accent, size: 15),
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