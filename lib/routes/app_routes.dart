class AppRoutes {
  AppRoutes._();

  // ─────────── Root ───────────
  static const String splash = '/';

  // ─────────── Auth ───────────
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String signup = '/signup';
  static const String waitingApproval = '/waiting-approval';

  // ─────────── Main (bottom nav + drawer) ───────────
  static const String dashboard = '/dashboard';
  static const String expenses = '/expenses';
  static const String income = '/income';
  static const String budget = '/budget';
  static const String more = '/more';

  // ─────────── Drawer — Finance ───────────
  static const String reports = '/more/reports';
  static const String receivables = '/more/receivables';
  static const String payables = '/more/payables';
  static const String loansEmi = '/more/loans-emi';

  // ─────────── Drawer — Manage ───────────
  static const String subscriptions = '/more/subscriptions';
  static const String departments = '/more/departments';
  static const String accounts = '/more/accounts';
  static const String calendar = '/more/calendar';

  // ─────────── Drawer — System ───────────
  static const String settings = '/more/settings';
}