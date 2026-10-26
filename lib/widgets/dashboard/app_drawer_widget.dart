import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../common/app_text_widget.dart';

class AppDrawer extends StatelessWidget {
  final String? currentRoute;

  const AppDrawer({
    super.key,
    this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final active = currentRoute ?? AppRoutes.dashboard;

    return Drawer(
      backgroundColor: AppColors.background,
      width: 300,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ═══════ Header ═══════
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: AppText(
                                (user?.fullName ?? 'F')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  user?.fullName ?? 'Owner',
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                AppText(
                                  user?.email ?? 'owner@finora.app',
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.85),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(width: 5),
                                AppText(
                                  'ADMIN',
                                  fontSize: 9.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ═══════ Menu ═══════
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _item(context, Icons.dashboard_rounded,
                      'Dashboard', AppRoutes.dashboard,
                      isActive: active == AppRoutes.dashboard),
                  _item(context, Icons.receipt_long_rounded,
                      'Expenses', AppRoutes.expenses,
                      isActive: active == AppRoutes.expenses),
                  _item(context, Icons.attach_money_rounded,
                      'Income', AppRoutes.income,
                      isActive: active == AppRoutes.income),
                  _item(context, Icons.pie_chart_rounded,
                      'Budget', AppRoutes.budget,
                      isActive: active == AppRoutes.budget),

                  _divider('FINANCE'),

                  _item(context, Icons.assessment_rounded,
                      'Reports', AppRoutes.reports,
                      isActive: active == AppRoutes.reports),
                  _item(context, Icons.call_received_rounded,
                      'Receivables', AppRoutes.receivables,
                      isActive: active == AppRoutes.receivables),
                  _item(context, Icons.call_made_rounded,
                      'Payables', AppRoutes.payables,
                      isActive: active == AppRoutes.payables),
                  _item(context, Icons.account_balance_rounded,
                      'Loans & EMI', AppRoutes.loansEmi,
                      isActive: active == AppRoutes.loansEmi),

                  _divider('MANAGE'),

                  _item(context, Icons.cloud_rounded,
                      'Subscriptions', AppRoutes.subscriptions,
                      isActive: active == AppRoutes.subscriptions),
                  _item(context, Icons.groups_rounded,
                      'Departments', AppRoutes.departments,
                      isActive: active == AppRoutes.departments),
                  // Accounts — Admin only
                  if (auth.isAdmin)
                    _item(context, Icons.account_balance_wallet_rounded,
                        'Accounts', AppRoutes.accounts,
                        isActive: active == AppRoutes.accounts),

                  _item(context, Icons.calendar_month_rounded,
                      'Calendar', AppRoutes.calendar,
                      isActive: active == AppRoutes.calendar),

                  _divider('SYSTEM'),

                  _item(context, Icons.settings_rounded,
                      'Settings', AppRoutes.settings,
                      isActive: active == AppRoutes.settings),

                  const SizedBox(height: 8),
                  _logoutTile(context, auth),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const AppText(
                    'Finora v1.0',
                    fontSize: 11,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
      BuildContext context,
      IconData icon,
      String label,
      String route, {
        bool isActive = false,
      }) {
    final color =
    isActive ? AppColors.primary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isActive
            ? AppColors.primary.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            Navigator.pop(context); // Close drawer
            if (!isActive) {
              // For dashboard, reset stack
              if (route == AppRoutes.dashboard) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  route,
                      (r) => false,
                );
              } else {
                Navigator.pushNamed(context, route);
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 17, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText(
                    label,
                    fontSize: 13.5,
                    fontWeight: isActive
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: color,
                  ),
                ),
                if (isActive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider(String label) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 8,
        left: 12,
      ),
      child: AppText(
        label,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.textHint,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _logoutTile(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            await auth.signOut();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
                  (route) => false,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error.withOpacity(0.15),
                        AppColors.error.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 17,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                const AppText(
                  'Logout',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}