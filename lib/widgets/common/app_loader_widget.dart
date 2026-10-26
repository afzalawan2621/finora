import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const AppLoader({
    super.key,
    this.size = 32,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class AppFullScreenLoader extends StatelessWidget {
  const AppFullScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AppLoader(size: AppSizes.xxxl),
      ),
    );
  }
}