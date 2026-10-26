import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import 'app_text_widget.dart';

enum AppButtonType { primary, secondary, outline, text, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool isFullWidth;
  final double? height;
  final double? width;
  final double? borderRadius;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.isFullWidth = true,
    this.height,
    this.width,
    this.borderRadius,
  });

  bool get _isEnabled => !isDisabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final h = height ?? 54;
    final radius = borderRadius ?? 14;

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: h,
      child: _build(context, radius),
    );
  }

  Widget _build(BuildContext context, double radius) {
    if (type == AppButtonType.primary) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: _isEnabled ? 1 : 0.55,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: _isEnabled
                ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.32),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.primary.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isEnabled ? onPressed : null,
              borderRadius: BorderRadius.circular(radius),
              splashColor: Colors.white.withOpacity(0.15),
              highlightColor: Colors.white.withOpacity(0.08),
              child: Center(child: _child()),
            ),
          ),
        ),
      );
    }

    if (type == AppButtonType.outline) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: _isEnabled ? 1 : 0.55,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 1.4,
                ),
              ),
              child: Center(child: _child()),
            ),
          ),
        ),
      );
    }

    // secondary, danger, text
    return ElevatedButton(
      onPressed: _isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _bg,
        foregroundColor: _fg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      child: _child(),
    );
  }

  Color get _bg {
    switch (type) {
      case AppButtonType.secondary:
        return AppColors.accent;
      case AppButtonType.danger:
        return AppColors.error;
      case AppButtonType.text:
      case AppButtonType.outline:
        return Colors.transparent;
      default:
        return AppColors.primary;
    }
  }

  Color get _fg {
    switch (type) {
      case AppButtonType.outline:
      case AppButtonType.text:
        return AppColors.primary;
      default:
        return AppColors.textOnPrimary;
    }
  }

  Widget _child() {
    // ─── Loading state ───
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation<Color>(_fg),
        ),
      );
    }

    // ─── Icon + Label ───
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: _fg),
          const SizedBox(width: 9),
          AppText(
            label,
            style: TextStyles.button,
            color: _fg,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ],
      );
    }

    // ─── Label only ───
    return AppText(
      label,
      style: TextStyles.button,
      color: _fg,
      fontWeight: FontWeight.w700,
      fontSize: 15,
      letterSpacing: 0.3,
    );
  }
}