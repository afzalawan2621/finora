import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class IncomeClientTile extends StatelessWidget {
  final String clientName;
  final String projectName;
  final String amount;
  final IconData icon;
  final Color accent;
  final String status; // 'Paid', 'Partial', 'Pending'
  final VoidCallback? onTap;

  const IncomeClientTile({
    super.key,
    required this.clientName,
    required this.projectName,
    required this.amount,
    required this.icon,
    required this.accent,
    required this.status,
    this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case 'Paid':
        return AppColors.success;
      case 'Partial':
        return AppColors.info;
      case 'Pending':
        return AppColors.warning;
      default:
        return AppColors.textHint;
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.inputBorder.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withOpacity(0.2),
                    accent.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: accent.withOpacity(0.15),
                ),
              ),
              child: Icon(icon, color: accent, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    clientName,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: AppText(
                          projectName,
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: AppText(
                          status,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  amount,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    AppText(
                      'View',
                      fontSize: 10,
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 9,
                      color: AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}