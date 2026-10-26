import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../repositories/responsive_repo.dart';
import '../../common/app_button_widget.dart';
import '../../common/app_section_label_widget.dart';
import '../app_email_field.dart';
import '../app_info_badge_widget.dart';

class ForgotPasswordFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSend;

  const ForgotPasswordFormWidget({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveRepo(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionLabel(label: AppStrings.resetDetails),

          SizedBox(height: r.spacing(12)),

          AppEmailField(
            label: AppStrings.email,
            hint: AppStrings.emailHint,
            controller: emailController,
            validator: (v) => Validators.email(v),
            hideErrorText: true,
          ),

          SizedBox(height: r.spacing(22)),

          AppButton(
            label: AppStrings.sendResetLink,
            onPressed: onSend,
            isLoading: isLoading,
            icon: Icons.send_rounded,
          ),

          SizedBox(height: r.spacing(14)),

          AppInfoBadge(
            text: AppStrings.resetLinkInfo,
            icon: Icons.info_outline_rounded,
            type: AppBadgeType.info,
          ),
        ],
      ),
    );
  }
}