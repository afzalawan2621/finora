import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_status.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_background_widget.dart';
import '../../widgets/common/app_text_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Small delay for branding
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final user = await auth.autoLogin();

    if (!mounted) return;

    // ─── No logged-in user → Login ───
    if (user == null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
            (route) => false,
      );
      return;
    }

    // ─── User logged in → route by status ───
    switch (user.status) {
      case UserStatus.approved:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
              (route) => false,
        );
        break;
      case UserStatus.pending:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.waitingApproval,
              (route) => false,
        );
        break;
      case UserStatus.rejected:
      case UserStatus.blocked:
        await auth.signOut();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
              (route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const AppText(
                AppStrings.appName,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
              const SizedBox(height: 6),
              const AppText(
                AppStrings.appTagline,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}