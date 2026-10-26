import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';
import '../../repositories/responsive_repo.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_text_widget.dart';
import '../../widgets/dashboard/app_drawer_widget.dart';
import '../../widgets/reports/report_summary_card.dart';
import '../../widgets/reports/report_type_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    final ownerId = auth.user!.ownerId;
    await Future.wait([
      context.read<ExpenseProvider>().fetchExpenses(ownerId),
      context.read<IncomeProvider>().fetchIncomes(ownerId),
    ]);
  }

  String _formatPKR(double amount) {
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return 'PKR $buffer';
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select Month',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveRepo(context);
    final auth = context.watch<AuthProvider>();
    final expenseProv = context.watch<ExpenseProvider>();
    final incomeProv = context.watch<IncomeProvider>();
    final user = auth.user;

    // ─── Real Data for summary ───
    final totalIncome = incomeProv.totalAmount;
    final totalExpenses = expenseProv.totalAmount;
    final netProfit = totalIncome - totalExpenses;
    final cashFlow = netProfit; // Simplified

    // ─── Report Types ───
    final reportTypes = [
      _ReportItem(
        title: 'Income Report',
        subtitle: 'Total income, paid, pending, and overdue',
        icon: Icons.trending_up_rounded,
        color: AppColors.success,
      ),
      _ReportItem(
        title: 'Expense Report',
        subtitle: 'Category-wise expenses breakdown',
        icon: Icons.trending_down_rounded,
        color: AppColors.error,
      ),
      _ReportItem(
        title: 'Profit & Loss',
        subtitle: 'Revenue, expenses, and net profit analysis',
        icon: Icons.assessment_rounded,
        color: AppColors.primary,
      ),
      _ReportItem(
        title: 'Cash Flow',
        subtitle: 'Opening balance, income, expenses, closing',
        icon: Icons.account_balance_wallet_rounded,
        color: AppColors.accent,
      ),
      _ReportItem(
        title: 'Client Report',
        subtitle: 'Client-wise contract, paid and due amounts',
        icon: Icons.people_alt_rounded,
        color: AppColors.info,
      ),
      _ReportItem(
        title: 'Department Salary',
        subtitle: 'Department-wise employee salary breakdown',
        icon: Icons.groups_rounded,
        color: AppColors.warning,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: AppRoutes.reports),
      appBar: _buildAppBar(user?.fullName ?? 'Owner'),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: r.horizontalPadding,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Filter
              GestureDetector(
                onTap: _pickMonth,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.inputBorder.withOpacity(0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.15),
                              AppColors.primary.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppText(
                          _formatMonthYear(_selectedDate),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: AppColors.textHint,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: r.spacing(16)),

              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: ReportSummaryCard(
                      label: 'Income',
                      value: _formatPKR(totalIncome),
                      icon: Icons.trending_up_rounded,
                      accent: AppColors.success,
                      trend: '+0%',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ReportSummaryCard(
                      label: 'Expenses',
                      value: _formatPKR(totalExpenses),
                      icon: Icons.trending_down_rounded,
                      accent: AppColors.error,
                      trend: '+0%',
                      trendUp: false,
                    ),
                  ),
                ],
              ),

              SizedBox(height: r.spacing(12)),

              Row(
                children: [
                  Expanded(
                    child: ReportSummaryCard(
                      label: 'Net Profit',
                      value: _formatPKR(netProfit),
                      icon: Icons.savings_rounded,
                      accent: AppColors.primary,
                      trend: '+0%',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ReportSummaryCard(
                      label: 'Cash Flow',
                      value: _formatPKR(cashFlow),
                      icon: Icons.account_balance_wallet_rounded,
                      accent: AppColors.accent,
                    ),
                  ),
                ],
              ),

              SizedBox(height: r.spacing(20)),

              _buildSectionLabel('AVAILABLE REPORTS'),
              SizedBox(height: r.spacing(12)),

              // Report Types List
              ...reportTypes.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ReportTypeCard(
                  title: r.title,
                  subtitle: r.subtitle,
                  icon: r.icon,
                  accent: r.color,
                  onTap: () {
                    _showComingSoon(context, r.title);
                  },
                ),
              )),

              SizedBox(height: r.spacing(20)),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String name) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: const [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Finance',
                fontSize: 11.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              AppText(
                'Reports',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AppText(
              name.substring(0, 1).toUpperCase(),
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        AppText(
          label,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: 1.4,
        ),
      ],
    );
  }

  String _formatMonthYear(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(
          '$title report — coming soon!',
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _ReportItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  _ReportItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}