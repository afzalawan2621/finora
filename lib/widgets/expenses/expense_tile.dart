import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class ExpenseTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color accent;
  final String? status;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ExpenseTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.accent,
    this.status,
    this.onTap,
    this.onLongPress,
  });

  Color get _statusColor {
    switch (status) {
      case 'Paid':
        return AppColors.success;
      case 'Pending':
        return AppColors.warning;
      case 'Overdue':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
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
            // Icon
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

            // Info
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: AppText(
                          subtitle,
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (status != null) ...[
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
                            status!,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Amount
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
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 9,
                      color: AppColors.primary,
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