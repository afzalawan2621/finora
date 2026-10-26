import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'app_text_widget.dart';

/// Reusable custom animated checkbox with label.
class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final double size;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: value ? AppColors.primary : AppColors.inputBorder,
                width: 1.5,
              ),
            ),
            child: value
                ? Icon(
              Icons.check_rounded,
              size: size * 0.7,
              color: Colors.white,
            )
                : null,
          ),
          const SizedBox(width: 8),
          AppText(
            label,
            fontSize: 12.5,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}