import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

/// Checklist of password requirements — animated ticks.
class AppPasswordRequirements extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecial;

  const AppPasswordRequirements({
    super.key,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.inputBorder.withOpacity(0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Password Requirements',
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 10),
          // Row 1
          Row(
            children: [
              Expanded(
                child: _reqItem('8+ characters', hasMinLength),
              ),
              Expanded(
                child: _reqItem('Uppercase (A-Z)', hasUppercase),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Row 2
          Row(
            children: [
              Expanded(
                child: _reqItem('Lowercase (a-z)', hasLowercase),
              ),
              Expanded(
                child: _reqItem('Number (0-9)', hasNumber),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Row 3
          Row(
            children: [
              Expanded(
                child: _reqItem('Special (!@#\$%)', hasSpecial),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reqItem(String label, bool isMet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMet
                ? AppColors.success.withOpacity(0.15)
                : Colors.transparent,
            border: Border.all(
              color: isMet ? AppColors.success : const Color(0xFFCBD5E1),
              width: 1.4,
            ),
          ),
          child: isMet
              ? const Icon(
            Icons.check_rounded,
            size: 10,
            color: AppColors.success,
          )
              : null,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: AppText(
            label,
            fontSize: 11.5,
            color: isMet ? AppColors.textPrimary : AppColors.textHint,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}