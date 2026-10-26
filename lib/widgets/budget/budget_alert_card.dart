import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

enum BudgetAlertType { warning, error, info, success }

class BudgetAlertCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final BudgetAlertType type;
  final VoidCallback? onTap;

  const BudgetAlertCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    this.type = BudgetAlertType.warning,
    this.onTap,
  });

  Color get _color {
    switch (type) {
      case BudgetAlertType.warning:
        return AppColors.warning;
      case BudgetAlertType.error:
        return AppColors.error;
      case BudgetAlertType.info:
        return AppColors.info;
      case BudgetAlertType.success:
        return AppColors.success;
    }
  }

  String get _label {
    switch (type) {
      case BudgetAlertType.warning:
        return 'NEAR LIMIT';
      case BudgetAlertType.error:
        return 'EXCEEDED';
      case BudgetAlertType.info:
        return 'INFO';
      case BudgetAlertType.success:
        return 'ON TRACK';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _color.withOpacity(0.08),
              _color.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_color, _color.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          title,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: AppText(
                          _label,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: _color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    subtitle,
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}