import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/auth_helper.dart';
import '../../core/utils/validators.dart';
import '../../repositories/responsive_repo.dart';
import '../../routes/app_routes.dart';
import '../../widgets/auth/app_company_field.dart';
import '../../widgets/auth/app_email_field.dart';
import '../../widgets/auth/app_footer_note_widget.dart';
import '../../widgets/auth/app_name_field.dart';
import '../../widgets/auth/app_password_field.dart';
import '../../widgets/auth/app_password_requirements_widget.dart';
import '../../widgets/auth/app_password_strength_widget.dart';
import '../../widgets/auth/app_phone_field.dart';
import '../../widgets/auth/app_terms_checkbox_widget.dart';
import '../../widgets/auth/app_top_bar_widget.dart';
import '../../widgets/common/app_background_widget.dart';
import '../../widgets/common/app_button_widget.dart';
import '../../widgets/common/app_card_widget.dart';
import '../../widgets/common/app_section_label_widget.dart';
import '../../widgets/common/app_text_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _agreeToTerms = false;

  PasswordStrengthResult _strength =
  PasswordStrengthResult.evaluate('');

  @override
  void initState() {
    super.initState();
    AuthHelper.onScreenOpen();
    _passwordController.addListener(_onPasswordChange);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChange);
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    AuthHelper.onScreenClose();
    super.dispose();
  }

  void _onPasswordChange() {
    final result =
    PasswordStrengthResult.evaluate(_passwordController.text);

    if (AuthHelper.didPasswordStrengthChange(
      previous: _strength,
      current: result,
    )) {
      setState(() => _strength = result);
    }
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();

    await AuthHelper.runSignupFlow(
      context,
      fullName: _nameController.text.trim(),
      companyName: _companyController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      agreeToTerms: _agreeToTerms,
      isValid: _formKey.currentState?.validate() ?? false,
      setLoading: (v) => setState(() => _isLoading = v),
    );
  }

  void _goToLogin() => Navigator.pop(context);

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
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: r.h(1)),

                    // ─── Top bar ───
                    AppTopBar(onBack: _goToLogin),

                    SizedBox(height: r.h(5)),

                    // ─── Title (card ke bahar) ───
                    AppText(
                      AppStrings.signupTitle,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                    SizedBox(height: r.spacing(8)),
                    AppText(
                      AppStrings.signupSubtitle,
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),

                    SizedBox(height: r.h(3)),

                    // ─── Card ───
                    AppCard(
                      showTopAccent: true,
                      padding: EdgeInsets.all(r.spacing(24)),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            // ─── PERSONAL INFORMATION ───
                            AppSectionLabel(
                              label: AppStrings.personalInformation,
                            ),
                            SizedBox(height: r.spacing(12)),

                            AppNameField(
                              label: AppStrings.fullName,
                              hint: AppStrings.fullNameHint,
                              controller: _nameController,
                              validator: (v) => Validators.name(v),
                            ),

                            SizedBox(height: r.spacing(14)),

                            AppCompanyField(
                              label: AppStrings.companyName,
                              hint: AppStrings.companyNameHint,
                              controller: _companyController,
                              validator: (v) => Validators.required(
                                v,
                                field: AppStrings.companyName,
                              ),
                            ),

                            SizedBox(height: r.spacing(14)),

                            AppEmailField(
                              label: AppStrings.email,
                              hint: AppStrings.emailHint,
                              controller: _emailController,
                              validator: (v) =>
                                  Validators.email(v),
                              hideErrorText: true,
                            ),

                            SizedBox(height: r.spacing(14)),

                            AppPhoneField(
                              label: AppStrings.phone,
                              hint: '+92 300 1234567',
                              controller: _phoneController,
                              validator: (v) => Validators.phone(v),
                            ),

                            SizedBox(height: r.spacing(22)),

                            // ─── SECURITY ───
                            AppSectionLabel(
                              label: AppStrings.security,
                            ),
                            SizedBox(height: r.spacing(12)),

                            AppPasswordField(
                              label: AppStrings.password,
                              hint: AppStrings.passwordHint,
                              controller: _passwordController,
                              validator: (v) =>
                                  Validators.password(v),
                              hideErrorText: true,
                            ),

                            AppPasswordStrengthBar(result: _strength),

                            SizedBox(height: r.spacing(12)),

                            AppPasswordField(
                              label: AppStrings.confirmPassword,
                              hint: AppStrings.confirmPasswordHint,
                              controller: _confirmPasswordController,
                              validator: (v) =>
                                  Validators.confirmPassword(
                                    v,
                                    _passwordController.text,
                                  ),
                              hideErrorText: true,
                            ),

                            SizedBox(height: r.spacing(14)),

                            AppPasswordRequirements(
                              hasMinLength: _strength.hasMinLength,
                              hasUppercase: _strength.hasUppercase,
                              hasLowercase: _strength.hasLowercase,
                              hasNumber: _strength.hasNumber,
                              hasSpecial: _strength.hasSpecial,
                            ),

                            SizedBox(height: r.spacing(18)),

                            AppTermsCheckbox(
                              value: _agreeToTerms,
                              onChanged: (v) => setState(
                                      () => _agreeToTerms = v),
                              fontSize: r.font(12.5),
                            ),

                            SizedBox(height: r.spacing(22)),

                            AppButton(
                              label: AppStrings.signup,
                              onPressed: _handleSignup,
                              isLoading: _isLoading,
                              icon: Icons.person_add_alt_1_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: r.spacing(18)),

                    // ─── Login link ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          AppStrings.alreadyHaveAccount,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: _goToLogin,
                          behavior: HitTestBehavior.opaque,
                          child: AppText(
                            AppStrings.signIn,
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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