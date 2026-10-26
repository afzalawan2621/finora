import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import 'validators.dart';
import '../../models/user_status.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/auth/app_password_strength_widget.dart';
import '../../widgets/common/app_error_overlay.dart';

/// Central helper for auth-screen validation + banner errors + flows.
class AuthHelper {
  AuthHelper._();

  // ═══════════════════════════════════════════
  //  SCREEN LIFECYCLE — BANNER CLEANUP
  // ═══════════════════════════════════════════
  /// Call in initState() — dismisses leftover banners.
  static void onScreenOpen() {
    AppErrorOverlay.dismiss();
  }

  /// Call in dispose() — dismisses leftover banners.
  static void onScreenClose() {
    AppErrorOverlay.dismiss();
  }

  // ═══════════════════════════════════════════
  //  VALIDATION — LOGIN
  // ═══════════════════════════════════════════
  static void validateLoginFields(
      BuildContext context, {
        required String email,
        required String password,
      }) {
    if (email.isEmpty || password.isEmpty) {
      _missingFields(context);
      return;
    }
    if (Validators.email(email) != null) {
      invalidEmail(context);
      return;
    }
    if (Validators.password(password) != null) {
      invalidPassword(context);
      return;
    }
  }

  // ═══════════════════════════════════════════
  //  VALIDATION — EMAIL ONLY
  // ═══════════════════════════════════════════
  static void validateEmailOnly(
      BuildContext context, {
        required String email,
      }) {
    if (email.isEmpty) {
      _missingFields(context);
      return;
    }
    if (Validators.email(email) != null) {
      invalidEmail(context);
      return;
    }
  }

  // ═══════════════════════════════════════════
  //  VALIDATION — SIGNUP
  // ═══════════════════════════════════════════
  static void validateSignupFields(
      BuildContext context, {
        required String fullName,
        required String companyName,
        required String email,
        required String phone,
        required String password,
        required String confirmPassword,
        required bool agreeToTerms,
      }) {
    if (fullName.isEmpty ||
        companyName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _missingFields(context);
      return;
    }

    if (Validators.name(fullName) != null) {
      AppErrorOverlay.error(
        context,
        heading: AppStrings.errHeadingNameRequired,
        subheading: AppStrings.errMsgNameRequired,
      );
      return;
    }

    if (companyName.length < 2) {
      AppErrorOverlay.error(
        context,
        heading: AppStrings.errHeadingCompanyRequired,
        subheading: AppStrings.errMsgCompanyRequired,
      );
      return;
    }

    if (Validators.email(email) != null) {
      invalidEmail(context);
      return;
    }

    if (Validators.phone(phone) != null) {
      AppErrorOverlay.error(
        context,
        heading: AppStrings.errHeadingPhoneRequired,
        subheading: AppStrings.errMsgPhoneRequired,
      );
      return;
    }

    if (Validators.password(password) != null) {
      invalidPassword(context);
      return;
    }

    if (password != confirmPassword) {
      AppErrorOverlay.error(
        context,
        heading: AppStrings.errHeadingPasswordMismatch,
        subheading: AppStrings.errMsgPasswordMismatch,
      );
      return;
    }

    if (!agreeToTerms) {
      AppErrorOverlay.warning(
        context,
        heading: AppStrings.errHeadingTermsNotAccepted,
        subheading: AppStrings.errMsgTermsNotAccepted,
      );
      return;
    }
  }

  // ═══════════════════════════════════════════
  //  LOGIN — FULL FLOW (returns result only)
  // ═══════════════════════════════════════════
  static Future<String> handleLoginFlow(
      BuildContext context, {
        required String email,
        required String password,
        required bool isValid,
      }) async {
    if (!isValid) {
      validateLoginFields(
        context,
        email: email,
        password: password,
      );
      return 'invalid';
    }

    final auth = context.read<AuthProvider>();
    final user = await auth.signIn(
      email: email,
      password: password,
    );

    if (!context.mounted) return 'error';

    if (user == null) {
      AppErrorOverlay.error(
        context,
        heading: AppStrings.errHeadingLoginFailed,
        subheading: auth.error ?? AppStrings.errMsgLoginFailed,
      );
      return 'error';
    }

    switch (user.status) {
      case UserStatus.approved:
        AppErrorOverlay.success(
          context,
          heading: AppStrings.sucHeadingLoginSuccess,
          subheading: AppStrings.sucMsgLoginSuccess,
        );
        return 'approved';

      case UserStatus.pending:
        AppErrorOverlay.info(
          context,
          heading: 'Pending Approval',
          subheading: AppStrings.approvalPendingMsg,
        );
        return 'pending';

      case UserStatus.rejected:
      case UserStatus.blocked:
        await auth.signOut();
        AppErrorOverlay.error(
          context,
          heading: 'Access Denied',
          subheading: 'Your account has been rejected or blocked.',
        );
        return 'rejected';
    }
  }

  // ═══════════════════════════════════════════
  //  LOGIN — RUN + NAVIGATE
  // ═══════════════════════════════════════════
  static Future<void> runLoginFlow(
      BuildContext context, {
        required String email,
        required String password,
        required bool isValid,
        required void Function(bool loading) setLoading,
      }) async {
    setLoading(true);

    final result = await handleLoginFlow(
      context,
      email: email,
      password: password,
      isValid: isValid,
    );

    if (!context.mounted) return;
    setLoading(false);

    switch (result) {
      case 'approved':
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
              (route) => false,
        );
        break;

      case 'pending':
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.waitingApproval,
              (route) => false,
        );
        break;

      case 'rejected':
      case 'error':
      case 'invalid':
      default:
        break;
    }
  }

  // ═══════════════════════════════════════════
  //  SIGNUP — RUN + NAVIGATE
  // ═══════════════════════════════════════════
  static Future<void> runSignupFlow(
      BuildContext context, {
        required String fullName,
        required String companyName,
        required String email,
        required String phone,
        required String password,
        required String confirmPassword,
        required bool agreeToTerms,
        required bool isValid,
        required void Function(bool loading) setLoading,
      }) async {
    if (!isValid || !agreeToTerms) {
      validateSignupFields(
        context,
        fullName: fullName,
        companyName: companyName,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
        agreeToTerms: agreeToTerms,
      );
      return;
    }

    setLoading(true);

    final auth = context.read<AuthProvider>();
    final user = await auth.signUp(
      fullName: fullName,
      companyName: companyName,
      email: email,
      phone: phone,
      password: password,
    );

    if (!context.mounted) return;
    setLoading(false);

    if (user == null) {
      AppErrorOverlay.error(
        context,
        heading: 'Signup Failed',
        subheading: auth.error ?? AppStrings.errMsgSomethingWrong,
      );
      return;
    }

    AppErrorOverlay.success(
      context,
      heading: AppStrings.sucHeadingAccountCreated,
      subheading: AppStrings.sucMsgAccountCreated,
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.waitingApproval,
          (route) => false,
    );
  }

  // ═══════════════════════════════════════════
  //  FORGOT PASSWORD — SEND FLOW
  // ═══════════════════════════════════════════
  static Future<String> handleForgotPasswordSend(
      BuildContext context, {
        required String email,
        required bool isValid,
      }) async {
    if (!isValid) {
      validateEmailOnly(context, email: email);
      return 'invalid';
    }

    final auth = context.read<AuthProvider>();
    final result = await auth.checkEmailAndSendReset(email);

    if (!context.mounted) return result;

    switch (result) {
      case 'not_registered':
        emailNotRegistered(context);
        break;

      case 'sent':
        AppErrorOverlay.success(
          context,
          heading: AppStrings.sucHeadingEmailSent,
          subheading: AppStrings.sucMsgEmailSent,
        );
        break;

      case 'error':
      default:
        somethingWentWrong(context);
        break;
    }

    return result;
  }

  // ═══════════════════════════════════════════
  //  WAITING APPROVAL — CHECK STATUS
  // ═══════════════════════════════════════════
  static Future<void> handleWaitingApprovalCheck(
      BuildContext context, {
        required void Function(bool loading) setLoading,
      }) async {
    setLoading(true);

    final auth = context.read<AuthProvider>();
    final status = await auth.refreshStatus();

    if (!context.mounted) return;
    setLoading(false);

    if (status == null) {
      AppErrorOverlay.error(
        context,
        heading: 'Error',
        subheading: 'Could not fetch status. Please try again.',
      );
      return;
    }

    switch (status) {
      case UserStatus.approved:
        AppErrorOverlay.success(
          context,
          heading: 'Approved!',
          subheading: AppStrings.approvalApprovedMsg,
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
              (route) => false,
        );
        break;

      case UserStatus.rejected:
        AppErrorOverlay.error(
          context,
          heading: 'Account Rejected',
          subheading: 'Your account has been rejected by admin.',
        );
        await Future.delayed(const Duration(milliseconds: 800));
        await auth.signOut();
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
              (route) => false,
        );
        break;

      case UserStatus.pending:
        AppErrorOverlay.info(
          context,
          heading: AppStrings.approvalStatusPending,
          subheading: AppStrings.approvalPendingMsg,
        );
        break;

      case UserStatus.blocked:
        AppErrorOverlay.error(
          context,
          heading: 'Account Blocked',
          subheading: 'Your account has been blocked.',
        );
        await Future.delayed(const Duration(milliseconds: 800));
        await auth.signOut();
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
              (route) => false,
        );
        break;
    }
  }

  // ═══════════════════════════════════════════
  //  WAITING APPROVAL — BACK TO LOGIN
  // ═══════════════════════════════════════════
  static Future<void> handleBackToLogin(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }

  // ═══════════════════════════════════════════
  //  PASSWORD STRENGTH — change detector
  // ═══════════════════════════════════════════
  static bool didPasswordStrengthChange({
    required PasswordStrengthResult previous,
    required PasswordStrengthResult current,
  }) {
    return previous.level != current.level ||
        previous.score != current.score;
  }

  // ═══════════════════════════════════════════
  //  COUNTDOWN TIMER
  // ═══════════════════════════════════════════
  static Timer startCountdown({
    required int startFrom,
    required void Function(int secondsLeft) onTick,
  }) {
    int seconds = startFrom;
    onTick(seconds);

    return Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds <= 1) {
        t.cancel();
        onTick(0);
      } else {
        seconds--;
        onTick(seconds);
      }
    });
  }

  // ═══════════════════════════════════════════
  //  BANNER SHORTCUTS
  // ═══════════════════════════════════════════
  static void _missingFields(BuildContext context) {
    AppErrorOverlay.warning(
      context,
      heading: AppStrings.errHeadingMissingFields,
      subheading: AppStrings.errMsgMissingFields,
    );
  }

  static void invalidEmail(BuildContext context) {
    AppErrorOverlay.error(
      context,
      heading: AppStrings.errHeadingInvalidEmail,
      subheading: AppStrings.errMsgInvalidEmail,
    );
  }

  static void invalidPassword(BuildContext context) {
    AppErrorOverlay.error(
      context,
      heading: AppStrings.errHeadingInvalidPassword,
      subheading: AppStrings.errMsgInvalidPassword,
    );
  }

  static void loginFailed(BuildContext context) {
    AppErrorOverlay.error(
      context,
      heading: AppStrings.errHeadingLoginFailed,
      subheading: AppStrings.errMsgLoginFailed,
    );
  }

  static void somethingWentWrong(BuildContext context) {
    AppErrorOverlay.error(
      context,
      heading: AppStrings.errHeadingSomethingWrong,
      subheading: AppStrings.errMsgSomethingWrong,
    );
  }

  static void emailNotRegistered(BuildContext context) {
    AppErrorOverlay.error(
      context,
      heading: AppStrings.errHeadingEmailNotRegistered,
      subheading: AppStrings.errMsgEmailNotRegistered,
    );
  }
}