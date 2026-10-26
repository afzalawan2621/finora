import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../repositories/responsive_repo.dart';
import '../../common/app_button_widget.dart';
import '../app_back_chip.dart';
import '../app_countdown_chip.dart';
import '../app_info_badge_widget.dart';
import '../app_success_strip.dart';



class ForgotPasswordSentWidget extends StatelessWidget {
  final String email;
  final int secondsLeft;
  final bool isLoading;
  final VoidCallback onResend;
  final VoidCallback onBackToLogin;

  const ForgotPasswordSentWidget({
    super.key,
    required this.email,
    required this.secondsLeft,
    required this.isLoading,
    required this.onResend,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveRepo(context);
    final canResend = secondsLeft == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSuccessStrip(
          title: AppStrings.emailSent,
          subtitle: email,
        ),

        SizedBox(height: r.spacing(14)),

        AppInfoBadge(
          text: AppStrings.resetLinkExpiryNote,
          icon: Icons.info_outline_rounded,
          type: AppBadgeType.info,
        ),

        SizedBox(height: r.spacing(18)),

        if (!canResend) ...[
          AppCountdownChip(secondsLeft: secondsLeft),
          SizedBox(height: r.spacing(14)),
        ],

        AppButton(
          label: AppStrings.resendLink,
          onPressed: canResend ? onResend : null,
          isLoading: isLoading,
          isDisabled: !canResend,
          icon: Icons.refresh_rounded,
        ),

        SizedBox(height: r.spacing(12)),

        Center(
          child: AppBackChip(
            label: AppStrings.backToLogin,
            onTap: onBackToLogin,
          ),
        ),
      ],
    );
  }
}