import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Reusable premium background with gradient + soft blobs.
/// Wrap any screen's content with this for a consistent look.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool showBlobs;
  final List<Widget>? extraLayers;

  const AppBackground({
    super.key,
    required this.child,
    this.showBlobs = true,
    this.extraLayers,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ─── Gradient ───
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.08),
                  AppColors.background,
                  AppColors.accent.withOpacity(0.06),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),

        // ─── Blobs ───
        if (showBlobs) ...[
          Positioned(
            top: -160,
            left: -120,
            child: _blob(340, AppColors.primary.withOpacity(0.22)),
          ),
          Positioned(
            top: 60,
            right: -100,
            child: _blob(280, AppColors.accentLight.withOpacity(0.28)),
          ),
          Positioned(
            bottom: -140,
            right: -80,
            child: _blob(300, AppColors.primaryLight.withOpacity(0.15)),
          ),
        ],

        // ─── Extra layers (optional) ───
        if (extraLayers != null) ...extraLayers!,

        // ─── Content ───
        child,
      ],
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          radius: 0.7,
        ),
      ),
    );
  }
}