import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/auth_helper.dart';
import '../../repositories/responsive_repo.dart';
import '../../widgets/auth/app_footer_note_widget.dart';
import '../../widgets/auth/app_step_indicator_widget.dart';
import '../../widgets/auth/app_top_bar_widget.dart';
import '../../widgets/auth/forgot/forgot_password_form_widget.dart';
import '../../widgets/auth/forgot/forgot_password_sent_widget.dart';
import '../../widgets/common/app_background_widget.dart';
import '../../widgets/common/app_card_widget.dart';
import '../../widgets/common/app_text_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isSent = false;

  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ─── Send handler ───
  Future<void> _handleSend() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final result = await AuthHelper.handleForgotPasswordSend(
      context,
      email: _emailController.text.trim(),
      isValid: _formKey.currentState?.validate() ?? false,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == 'sent') {
      setState(() => _isSent = true);
      _timer?.cancel();
      _timer = AuthHelper.startCountdown(
        startFrom: 60,
        onTick: (seconds) {
          if (mounted) setState(() => _secondsLeft = seconds);
        },
      );
    }
  }

  void _goBack() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveRepo(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: r.horizontalPadding,
                vertical: r.verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: r.h(1)),

                    // ─── Top bar ───
                    AppTopBar(onBack: _goBack),

                    SizedBox(height: r.h(4)),

                    // ─── Steps Indicator ───
                    AppStepIndicator(
                      currentStep: _isSent ? 1 : 0,
                      labels: const ['Email', 'Verify', 'Reset'],
                    ),

                    SizedBox(height: r.h(5)),

                    // ─── Title ───
                    AppText(
                      _isSent
                          ? AppStrings.resetLinkSentTitle
                          : AppStrings.forgotPasswordTitle,
                      fontSize: r.font(26),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),

                    SizedBox(height: r.spacing(8)),

                    AppText(
                      _isSent
                          ? AppStrings.resetLinkSentSubtitle
                          : AppStrings.forgotPasswordSubtitle,
                      fontSize: r.font(13.5),
                      color: AppColors.textSecondary,
                      height: 1.55,
                    ),

                    SizedBox(height: r.h(4)),

                    // ─── Card ───
                    AppCard(
                      showTopAccent: true,
                      padding: EdgeInsets.all(r.spacing(24)),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        child: _isSent
                            ? ForgotPasswordSentWidget(
                          email: _emailController.text,
                          secondsLeft: _secondsLeft,
                          isLoading: _isLoading,
                          onResend: _handleSend,
                          onBackToLogin: _goBack,
                        )
                            : ForgotPasswordFormWidget(
                          formKey: _formKey,
                          emailController: _emailController,
                          isLoading: _isLoading,
                          onSend: _handleSend,
                        ),
                      ),
                    ),

                    SizedBox(height: r.spacing(18)),

                    // ─── Footer ───
                    AppFooterNote(text: AppStrings.endToEndEncrypted),

                    SizedBox(height: r.h(2)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}