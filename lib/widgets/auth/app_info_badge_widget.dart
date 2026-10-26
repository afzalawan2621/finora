import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

enum AppBadgeType { success, info, warning, error }

/// Reusable inline badge — for "Bank-level security" etc.
class AppInfoBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final AppBadgeType type;

  const AppInfoBadge({
    super.key,
    required this.text,
    required this.icon,
    this.type = AppBadgeType.success,
  });

  Color get _color {
    switch (type) {
      case AppBadgeType.success:
        return AppColors.success;
      case AppBadgeType.info:
        return AppColors.info;
      case AppBadgeType.warning:
        return AppColors.warning;
      case AppBadgeType.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: _color),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(
              text,
              fontSize: 11.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}