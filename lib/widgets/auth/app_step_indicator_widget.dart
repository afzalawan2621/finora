import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

/// Reusable step indicator for multi-step flows.
class AppStepIndicator extends StatelessWidget {
  final int currentStep; // 0-based
  final List<String> labels;

  const AppStepIndicator({
    super.key,
    required this.currentStep,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length * 2 - 1, (i) {
        // Even index = step dot
        if (i.isEven) {
          final stepIndex = i ~/ 2;
          final isActive = stepIndex <= currentStep;
          final isCurrent = stepIndex == currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 30 : 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: isActive
                      ? AppColors.primaryGradient
                      : null,
                  color: isActive ? null : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isCurrent
                      ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: isActive
                      ? Icon(
                    stepIndex < currentStep
                        ? Icons.check_rounded
                        : null,
                    size: 12,
                    color: Colors.white,
                  )
                      : AppText(
                    '${stepIndex + 1}',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHint,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              AppText(
                labels[stepIndex],
                fontSize: 10,
                color: isCurrent
                    ? AppColors.primary
                    : AppColors.textHint,
                fontWeight: isCurrent
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ],
          );
        }

        // Odd index = connector line
        final lineIndex = i ~/ 2;
        final isActive = lineIndex < currentStep;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              decoration: BoxDecoration(
                gradient: isActive ? AppColors.primaryGradient : null,
                color: isActive ? null : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        );
      }),
    );
  }
}