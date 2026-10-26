import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

enum PasswordStrength { empty, weak, fair, good, strong, excellent }

class PasswordStrengthResult {
  final PasswordStrength level;
  final int score; // 0-5
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecial;

  const PasswordStrengthResult({
    required this.level,
    required this.score,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecial,
  });

  static PasswordStrengthResult evaluate(String password) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial =
    RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\[\]\\/;`~+=]').hasMatch(password);

    int score = 0;
    if (hasMinLength) score++;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasNumber) score++;
    if (hasSpecial) score++;

    PasswordStrength level;
    if (password.isEmpty) {
      level = PasswordStrength.empty;
    } else if (score <= 1) {
      level = PasswordStrength.weak;
    } else if (score == 2) {
      level = PasswordStrength.fair;
    } else if (score == 3) {
      level = PasswordStrength.good;
    } else if (score == 4) {
      level = PasswordStrength.strong;
    } else {
      level = PasswordStrength.excellent;
    }

    return PasswordStrengthResult(
      level: level,
      score: score,
      hasMinLength: hasMinLength,
      hasUppercase: hasUppercase,
      hasLowercase: hasLowercase,
      hasNumber: hasNumber,
      hasSpecial: hasSpecial,
    );
  }

  String get label {
    switch (level) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.excellent:
        return 'Excellent';
    }
  }

  Color get color {
    switch (level) {
      case PasswordStrength.empty:
        return AppColors.divider;
      case PasswordStrength.weak:
        return AppColors.error;
      case PasswordStrength.fair:
        return const Color(0xFFF59E0B);
      case PasswordStrength.good:
        return const Color(0xFFEAB308);
      case PasswordStrength.strong:
        return const Color(0xFF84CC16);
      case PasswordStrength.excellent:
        return AppColors.success;
    }
  }

  /// Filled bars out of 5
  int get filledBars {
    switch (level) {
      case PasswordStrength.empty:
        return 0;
      case PasswordStrength.weak:
        return 1;
      case PasswordStrength.fair:
        return 2;
      case PasswordStrength.good:
        return 3;
      case PasswordStrength.strong:
        return 4;
      case PasswordStrength.excellent:
        return 5;
    }
  }
}

/// Horizontal 5-bar strength meter + label.
class AppPasswordStrengthBar extends StatelessWidget {
  final PasswordStrengthResult result;

  const AppPasswordStrengthBar({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    if (result.level == PasswordStrength.empty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        // 5 bars
        Row(
          children: List.generate(5, (i) {
            final isFilled = i < result.filledBars;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 4 ? 4 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 5,
                  decoration: BoxDecoration(
                    color: isFilled
                        ? result.color
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        // Label
        AppText(
          result.label,
          fontSize: 11.5,
          color: result.color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ],
    );
  }
}