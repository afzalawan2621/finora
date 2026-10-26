import 'package:finance_app/views/auth/forgot_view.dart';
import 'package:finance_app/views/auth/login_view.dart';
import 'package:finance_app/views/auth/signup_view.dart';
import 'package:finance_app/views/dashboard/dashboard_view.dart';
import 'package:finance_app/views/reports/reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/budget_provider.dart';      // ← Import
import 'providers/expense_provider.dart';     // ← Import
import 'providers/income_provider.dart';      // ← Import
import 'routes/app_routes.dart';
import 'services/firebase_service.dart';
import 'views/accounts/accounts_screen.dart';
import 'views/auth/waiting_approval_screen.dart';
import 'views/budget/budget_screen.dart';
import 'views/common/coming_soon_screen.dart';
import 'views/expenses/expenses_screen.dart';
import 'views/income/income_screen.dart';
import 'views/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService.initialize(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FinoraApp());
}

class FinoraApp extends StatelessWidget {
  const FinoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ─── Core Providers ───
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // ─── Data Providers ───
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: MaterialApp(
        title: 'Finora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.splash,
        routes: {
          // ═══════════ Root ═══════════
          AppRoutes.splash: (_) => const SplashScreen(),

          // ═══════════ Auth ═══════════
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
          AppRoutes.signup: (_) => const SignupScreen(),
          AppRoutes.waitingApproval: (_) => const WaitingApprovalScreen(),

          // ═══════════ Main ═══════════
          AppRoutes.dashboard: (_) => const DashboardScreen(),
          AppRoutes.expenses: (_) => const ExpensesScreen(),
          AppRoutes.income: (_) => const IncomeScreen(),
          AppRoutes.budget: (_) => const BudgetScreen(),

          // ═══════════ Accounts ═══════════
          AppRoutes.accounts: (_) => const AccountsScreen(),

          // ═══════════ Coming Soon ═══════════
          AppRoutes.more: (_) => const ComingSoonScreen(
            title: 'More',
            icon: Icons.more_horiz_rounded,
          ),
          
          AppRoutes.reports: (_) => const ReportsScreen(),

          AppRoutes.receivables: (_) => const ComingSoonScreen(
            title: 'Receivables',
            icon: Icons.call_received_rounded,
          ),
          AppRoutes.payables: (_) => const ComingSoonScreen(
            title: 'Payables',
            icon: Icons.call_made_rounded,
          ),
          AppRoutes.loansEmi: (_) => const ComingSoonScreen(
            title: 'Loans & EMI',
            icon: Icons.account_balance_rounded,
          ),
          AppRoutes.subscriptions: (_) => const ComingSoonScreen(
            title: 'Subscriptions',
            icon: Icons.cloud_rounded,
          ),
          AppRoutes.departments: (_) => const ComingSoonScreen(
            title: 'Departments',
            icon: Icons.groups_rounded,
          ),
          AppRoutes.calendar: (_) => const ComingSoonScreen(
            title: 'Calendar',
            icon: Icons.calendar_month_rounded,
          ),
          AppRoutes.settings: (_) => const ComingSoonScreen(
            title: 'Settings',
            icon: Icons.settings_rounded,
          ),
        },
      ),
    );
  }
}