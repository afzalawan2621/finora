import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../common/app_text_widget.dart';

/// Reusable top bar with back button + secure badge.
class AppTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final bool showSecureBadge;

  const AppTopBar({
    super.key,
    required this.onBack,
    this.showSecureBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ─── Back button ───
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.inputBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        const Spacer(),
        // ─── Secure badge ───
        if (showSecureBadge)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success.withOpacity(0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 13,
                  color: AppColors.success,
                ),
                const SizedBox(width: 5),
                AppText(
                  AppStrings.authSecurity,
                  fontSize: 11,
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),
      ],
    );
  }
}