import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Reusable premium card with optional top gradient accent line.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool showTopAccent;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.showTopAccent = false,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            if (showTopAccent)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
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
            Padding(
              padding: padding ?? const EdgeInsets.all(22),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}