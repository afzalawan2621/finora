import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/auth_helper.dart';
import '../../core/utils/validators.dart';
import '../../repositories/responsive_repo.dart';
import '../../routes/app_routes.dart';
import '../../widgets/auth/app_email_field.dart';
import '../../widgets/auth/app_footer_note_widget.dart';
import '../../widgets/auth/app_info_badge_widget.dart';
import '../../widgets/auth/app_password_field.dart';
import '../../widgets/common/app_background_widget.dart';
import '../../widgets/common/app_brand_logo_widget.dart';
import '../../widgets/common/app_button_widget.dart';
import '../../widgets/common/app_card_widget.dart';
import '../../widgets/common/app_checkbox_widget.dart';
import '../../widgets/common/app_or_divider_widget.dart';
import '../../widgets/common/app_section_label_widget.dart';
import '../../widgets/common/app_text_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    AuthHelper.onScreenOpen();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    AuthHelper.onScreenClose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    await AuthHelper.runLoginFlow(
      context,
      email: _emailController.text.trim(),
      password: _passwordController.text,
      isValid: _formKey.currentState?.validate() ?? false,
      setLoading: (v) => setState(() => _isLoading = v),
    );
  }

  void _handleSignup() {
    Navigator.pushNamed(context, AppRoutes.signup);
  }

  void _handleForgot() {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

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

                    // ─── Brand ───
                    AppBrandLogo(
                      name: AppStrings.appName,
                      subtitle: AppStrings.signInToAccount,
                    ),

                    SizedBox(height: r.h(4)),

                    // ─── Card ───
                    AppCard(
                      showTopAccent: true,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            AppText(
                              AppStrings.welcomeBackEmoji,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                            SizedBox(height: r.spacing(5)),
                            AppText(
                              AppStrings.signInContinueDashboard,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),

                            SizedBox(height: r.spacing(14)),

                            AppInfoBadge(
                              text: AppStrings.bankLevelSecurity,
                              icon: Icons.verified_user_rounded,
                            ),

                            SizedBox(height: r.spacing(20)),

                            AppSectionLabel(
                              label: AppStrings.loginDetails,
                            ),
                            SizedBox(height: r.spacing(12)),

                            AppEmailField(
                              label: AppStrings.email,
                              hint: AppStrings.emailHint,
                              controller: _emailController,
                              validator: (v) => Validators.email(v),
                              hideErrorText: true,
                            ),

                            SizedBox(height: r.spacing(14)),

                            AppPasswordField(
                              label: AppStrings.password,
                              hint: AppStrings.passwordHint,
                              controller: _passwordController,
                              validator: (v) =>
                                  Validators.password(v),
                              hideErrorText: true,
                            ),

                            SizedBox(height: r.spacing(12)),

                            Row(
                              children: [
                                AppCheckbox(
                                  value: _rememberMe,
                                  onChanged: (v) => setState(
                                          () => _rememberMe = v),
                                  label: AppStrings.rememberMe,
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _handleForgot,
                                  behavior:
                                  HitTestBehavior.opaque,
                                  child: AppText(
                                    AppStrings.forgotPassword,
                                    fontSize: 12.5,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: r.spacing(22)),

                            AppButton(
                              label: AppStrings.login,
                              onPressed: _handleLogin,
                              isLoading: _isLoading,
                              icon: Icons.login_rounded,
                            ),

                            SizedBox(height: r.spacing(18)),

                            AppOrDivider(text: AppStrings.orText),

                            SizedBox(height: r.spacing(14)),

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                AppText(
                                  AppStrings.dontHaveAccount,
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 5),
                                GestureDetector(
                                  onTap: _handleSignup,
                                  behavior:
                                  HitTestBehavior.opaque,
                                  child: AppText(
                                    AppStrings.signup,
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: r.spacing(16)),

                    AppFooterNote(
                      text: AppStrings.endToEndEncrypted,
                    ),

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