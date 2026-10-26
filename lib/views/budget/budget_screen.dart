import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/budget_model.dart';
import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';
import '../../repositories/responsive_repo.dart';
import '../../routes/app_routes.dart';
import '../../widgets/budget/budget_alert_card.dart';
import '../../widgets/budget/budget_category_card.dart';
import '../../widgets/budget/budget_mini_stat_card.dart';
import '../../widgets/budget/budget_summary_card.dart';
import '../../widgets/common/app_text_widget.dart';
import '../../widgets/dashboard/app_bottom_nav_widget.dart';
import '../../widgets/dashboard/app_drawer_widget.dart';
import 'add_budget_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int _bottomNavIndex = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBudget();
      _loadExpenses();
    });
  }

  Future<void> _loadBudget() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    final monthKey = _formatMonthKey(DateTime.now());
    await context
        .read<BudgetProvider>()
        .fetchBudget(auth.user!.ownerId, monthKey);
  }

  Future<void> _loadExpenses() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    await context
        .read<ExpenseProvider>()
        .fetchExpenses(auth.user!.ownerId);
  }

  String _formatMonthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  String _formatPKR(double amount) {
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return 'PKR $buffer';
  }

  Future<void> _handleEditBudget() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
    );
    if (result == true && mounted) {
      await _loadBudget();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const AppText(
            'Budget saved!',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveRepo(context);
    final auth = context.watch<AuthProvider>();
    final budgetProv = context.watch<BudgetProvider>();
    final expenseProv = context.watch<ExpenseProvider>();
    final user = auth.user;

    final budget = budgetProv.currentBudget;
    final expenses = expenseProv.expenses;

    // Calculate per-category totals
    final categoryExpenses = <String, double>{};
    for (final e in expenses) {
      if (_isThisMonth(e.date)) {
        final current = categoryExpenses[e.category] ?? 0.0;
        categoryExpenses[e.category] = current + (e.amount as double);
      }
    }

    final totalSpent = categoryExpenses.values.fold<double>(0.0, (a, b) => a + b);
    final totalBudget = (budget?.totalBudget ?? 0.0) as double;
    final remaining = totalBudget - totalSpent;
    final progress = totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;

    // Alerts
    final alerts = <_AlertItem>[];
    if (budget != null) {
      for (final entry in budget.categoryLimits.entries) {
        final spent = categoryExpenses[entry.key] ?? 0.0;
        final limit = (entry.value as num).toDouble(); // ✅ FIX
        final pct = limit > 0 ? spent / limit : 0.0;    // ✅ FIX
        if (pct >= 1.0) {
          alerts.add(_AlertItem(
            category: entry.key,
            pct: pct,
            type: BudgetAlertType.error,
          ));
        } else if (pct >= 0.85) {
          alerts.add(_AlertItem(
            category: entry.key,
            pct: pct,
            type: BudgetAlertType.warning,
          ));
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: AppRoutes.budget),
      appBar: _buildAppBar(user?.fullName ?? 'Owner'),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadBudget();
          await _loadExpenses();
        },
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
              // Month filter
              _buildMonthFilter(),
              SizedBox(height: r.spacing(14)),

              // Summary card
              BudgetSummaryCard(
                totalBudget: _formatPKR(totalBudget),
                totalSpent: _formatPKR(totalSpent),
                remaining: _formatPKR(remaining.abs()),
                progressPercent: progress,
                isOverBudget: remaining < 0,
                monthLabel: budget?.monthKey ?? 'Not set',
              ),

              SizedBox(height: r.spacing(14)),

              // Mini stats
              Row(
                children: [
                  Expanded(
                    child: BudgetMiniStatCard(
                      label: 'Categories',
                      value: '${budget?.categoryLimits.length ?? 0}',
                      icon: Icons.category_outlined,
                      accent: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BudgetMiniStatCard(
                      label: 'Spent',
                      value: _formatPKR(totalSpent),
                      icon: Icons.receipt_long_rounded,
                      accent: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BudgetMiniStatCard(
                      label: 'Alerts',
                      value: '${alerts.length}',
                      icon: Icons.warning_amber_rounded,
                      accent: AppColors.error,
                    ),
                  ),
                ],
              ),

              SizedBox(height: r.spacing(20)),

              // Alerts section
              if (alerts.isNotEmpty) ...[
                _buildSectionLabel('ALERTS'),
                SizedBox(height: r.spacing(10)),
                ...alerts.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: BudgetAlertCard(
                    title: _capitalize(a.category),
                    subtitle: '${(a.pct * 100).toStringAsFixed(0)}% used',
                    category: a.category,
                    icon: Icons.warning_amber_rounded,
                    type: a.type,
                    onTap: () {},
                  ),
                )),
                SizedBox(height: r.spacing(12)),
              ],

              // Categories
              if (budget == null || budget.categoryLimits.isEmpty)
                _buildEmptyState()
              else ...[
                _buildSectionLabel('CATEGORY BUDGETS'),
                SizedBox(height: r.spacing(10)),
                ...budget.categoryLimits.entries.map((entry) {
                  final spent = categoryExpenses[entry.key] ?? 0.0;
                  final limit = (entry.value as num).toDouble(); // ✅ FIX
                  final pct = limit > 0 ? spent / limit : 0.0;    // ✅ FIX
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildCategoryRow(
                      category: _capitalize(entry.key),
                      spent: spent,
                      limit: limit,
                      pct: pct,
                    ),
                  );
                }),
              ],

              SizedBox(height: r.spacing(90)),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: (i) => setState(() => _bottomNavIndex = i),
      ),
    );
  }

  bool _isThisMonth(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month;
  }

  String _capitalize(String s) =>
      s[0].toUpperCase() + s.substring(1);

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pie_chart_outline_rounded,
              size: 42,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          const AppText(
            'No budget set',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 6),
          const AppText(
            'Tap "Set Budget" below to define your monthly budget.',
            fontSize: 13,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
            height: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow({
    required String category,
    required double spent,
    required double limit,
    required double pct,
  }) {
    Color color;
    if (pct >= 1.0) {
      color = AppColors.error;
    } else if (pct >= 0.85) {
      color = AppColors.warning;
    } else if (pct >= 0.6) {
      color = const Color(0xFFEAB308);
    } else {
      color = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.inputBorder.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  category,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _formatPKR(spent),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${_formatPKR(limit)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 8,
              color: AppColors.inputBorder.withOpacity(0.3),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pct.clamp(0.0, 1.0).toDouble(),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          AppText(
            '${(pct * 100).toStringAsFixed(0)}% used',
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ],
      ),
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

  Widget _buildMonthFilter() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return Container(
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
              '${months[now.month - 1]} ${now.year}',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
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
                'Manage',
                fontSize: 11.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              AppText(
                'Budget',
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

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _handleEditBudget,
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                AppText(
                  'Set Budget',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertItem {
  final String category;
  final double pct;
  final BudgetAlertType type;
  _AlertItem({
    required this.category,
    required this.pct,
    required this.type,
  });
}