import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class AppChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onSeeMore;
  final IconData? icon;

  const AppChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.onSeeMore,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.inputBorder.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Top accent line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                      AppColors.accentLight,
                    ],
                  ),
                ),
              ),
            ),
            // Soft background accent
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary
                                    .withOpacity(0.15),
                                AppColors.primary
                                    .withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            icon,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            AppText(
                              title,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 3),
                              AppText(
                                subtitle!,
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (trailing != null) trailing!,
                      if (onSeeMore != null)
                        GestureDetector(
                          onTap: onSeeMore,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary
                                      .withOpacity(0.08),
                                  AppColors.primary
                                      .withOpacity(0.04),
                                ],
                              ),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppText(
                                  'See more',
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 9,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}