import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class AppStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String? trend;
  final bool trendUp;
  final bool isPrimary;
  final VoidCallback? onTap;

  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.trend,
    this.trendUp = true,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
            colors: [accent, accent.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isPrimary
                ? Colors.white.withOpacity(0.15)
                : accent.withOpacity(0.1),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(isPrimary ? 0.35 : 0.08),
              blurRadius: isPrimary ? 28 : 20,
              offset: const Offset(0, 12),
            ),
            if (!isPrimary)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // ─── Decorative orbs ───
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPrimary
                        ? Colors.white.withOpacity(0.1)
                        : accent.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -30,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPrimary
                        ? Colors.white.withOpacity(0.06)
                        : accent.withOpacity(0.04),
                  ),
                ),
              ),
              // ─── Content ───
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isPrimary
                                ? Colors.white.withOpacity(0.22)
                                : accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: isPrimary
                                ? Border.all(
                              color: Colors.white
                                  .withOpacity(0.3),
                              width: 1,
                            )
                                : null,
                          ),
                          child: Icon(
                            icon,
                            color: isPrimary ? Colors.white : accent,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        if (trend != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isPrimary
                                  ? Colors.white.withOpacity(0.2)
                                  : (trendUp
                                  ? AppColors.success
                                  : AppColors.error)
                                  .withOpacity(0.1),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  trendUp
                                      ? Icons.trending_up_rounded
                                      : Icons.trending_down_rounded,
                                  size: 12,
                                  color: isPrimary
                                      ? Colors.white
                                      : (trendUp
                                      ? AppColors.success
                                      : AppColors.error),
                                ),
                                const SizedBox(width: 3),
                                AppText(
                                  trend!,
                                  fontSize: 10.5,
                                  color: isPrimary
                                      ? Colors.white
                                      : (trendUp
                                      ? AppColors.success
                                      : AppColors.error),
                                  fontWeight: FontWeight.w800,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppText(
                      value,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isPrimary
                          ? Colors.white
                          : AppColors.textPrimary,
                      letterSpacing: -0.4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      label,
                      fontSize: 11.5,
                      color: isPrimary
                          ? Colors.white.withOpacity(0.85)
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}