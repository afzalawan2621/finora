import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/expense_model.dart';
import '../../models/income_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';
import '../../repositories/responsive_repo.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_text_widget.dart';
import '../../widgets/dashboard/app_alert_tile_widget.dart';
import '../../widgets/dashboard/app_bottom_nav_widget.dart';
import '../../widgets/dashboard/app_chart_card_widget.dart';
import '../../widgets/dashboard/app_drawer_widget.dart';
import '../../widgets/dashboard/app_stat_card_widget.dart';
import '../../widgets/dashboard/app_transaction_tile_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    final ownerId = auth.user!.ownerId;
    await Future.wait([
      context.read<ExpenseProvider>().fetchExpenses(ownerId),
      context.read<IncomeProvider>().fetchIncomes(ownerId),
      // Budget is loaded monthly in its own screen, but we can fetch current month here if needed
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

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveRepo(context);
    final auth = context.watch<AuthProvider>();
    final expenseProv = context.watch<ExpenseProvider>();
    final incomeProv = context.watch<IncomeProvider>();
    final user = auth.user;

    // ─── Real Data ───
    final totalIncome = incomeProv.totalAmount;
    final totalExpenses = expenseProv.totalAmount;
    final netProfit = totalIncome - totalExpenses;

    final recentExpenses = expenseProv.expenses;
    final recentIncomes = incomeProv.incomes;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: AppRoutes.dashboard),
      appBar: _buildAppBar(r, user?.fullName ?? 'Owner'),
      body: RefreshIndicator(
        onRefresh: () async => _loadAllData(),
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
              _buildMonthFilter(r),
              SizedBox(height: r.spacing(16)),

              // Stat Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  AppStatCard(
                    label: 'Total Income',
                    value: _formatPKR(totalIncome),
                    icon: Icons.trending_up_rounded,
                    accent: AppColors.success,
                    trend: '+0%',
                    trendUp: true,
                  ),
                  AppStatCard(
                    label: 'Total Expenses',
                    value: _formatPKR(totalExpenses),
                    icon: Icons.trending_down_rounded,
                    accent: AppColors.error,
                    trend: '+0%',
                    trendUp: false,
                  ),
                  AppStatCard(
                    label: 'Net Profit',
                    value: _formatPKR(netProfit),
                    icon: Icons.savings_rounded,
                    accent: AppColors.primary,
                    trend: '+0%',
                    trendUp: true,
                    isPrimary: true,
                  ),
                  AppStatCard(
                    label: 'Cash Balance',
                    value: _formatPKR(netProfit),
                    icon: Icons.account_balance_wallet_rounded,
                    accent: AppColors.accent,
                  ),
                ],
              ),

              SizedBox(height: r.spacing(20)),

              // Chart 1: Income vs Expense (Dummy data for trend, real data for labels)
              AppChartCard(
                icon: Icons.bar_chart_rounded,
                title: 'Income vs Expenses',
                subtitle: 'Last 6 months overview',
                onSeeMore: () {},
                child: SizedBox(
                  height: 200,
                  child: _buildIncomeExpenseChart(incomeProv, expenseProv),
                ),
              ),

              SizedBox(height: r.spacing(16)),

              // Chart 2: Expense Pie
              AppChartCard(
                icon: Icons.pie_chart_outline_rounded,
                title: 'Expense Distribution',
                subtitle: 'By category',
                onSeeMore: () {},
                child: SizedBox(
                  height: 220,
                  child: _buildExpensePieChart(expenseProv),
                ),
              ),

              SizedBox(height: r.spacing(16)),

              // Recent Transactions (mix of income + expenses)
              AppChartCard(
                icon: Icons.history_rounded,
                title: 'Recent Transactions',
                subtitle: 'Last 5 activities',
                onSeeMore: () {},
                child: _buildRecentTransactions(
                    recentExpenses, recentIncomes),
              ),

              SizedBox(height: r.spacing(20)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: (i) => setState(() => _bottomNavIndex = i),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  APPBAR
  // ═══════════════════════════════════════════
  PreferredSizeWidget _buildAppBar(
      ResponsiveRepo r, String name) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Good morning 👋',
                fontSize: 11.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              AppText(
                name,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.inputBorder,
                  ),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              Positioned(
                top: 9,
                right: 11,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.background,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
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

  Widget _buildMonthFilter(ResponsiveRepo r) {
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 22,
            color: AppColors.textHint,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  CHARTS (Real Data)
  // ═══════════════════════════════════════════
  Widget _buildIncomeExpenseChart(
      IncomeProvider incomeProv, ExpenseProvider expenseProv) {
    // Note: Real 6-month trend ke liye humein har month ka data filter karna padega.
    // Abhi ke liye hum current month ka total use kar rahe hain (simplified).

    final incomeValues = [incomeProv.thisMonthAmount / 1000, 0.0, 0.0, 0.0, 0.0, 0.0];
    final expenseValues = [expenseProv.thisMonthAmount / 1000, 0.0, 0.0, 0.0, 0.0, 0.0];
    final months = ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];

    // If data is too small, show dummy for visual
    final maxY = (incomeValues[0] > expenseValues[0] ? incomeValues[0] : expenseValues[0]) * 1.2;
    final finalMaxY = maxY > 10 ? maxY : 30.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: finalMaxY,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: AppText(
                      months[value.toInt()],
                      fontSize: 10,
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: finalMaxY / 3,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.inputBorder.withOpacity(0.4),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(months.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: incomeValues[i],
                gradient: const LinearGradient(
                  colors: [
                    AppColors.success,
                    Color(0xFF34D399),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 9,
                borderRadius: BorderRadius.circular(5),
              ),
              BarChartRodData(
                toY: expenseValues[i],
                gradient: const LinearGradient(
                  colors: [
                    AppColors.error,
                    Color(0xFFF87171),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 9,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildExpensePieChart(ExpenseProvider expenseProv) {
    // Calculate category totals
    final categoryTotals = <String, double>{};
    for (final e in expenseProv.expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0.0) + e.amount;
    }

    // Convert to PieData
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.warning,
      AppColors.success,
      AppColors.info,
      AppColors.error,
      const Color(0xFF8B5CF6),
    ];

    final data = <_PieData>[];
    int colorIndex = 0;
    categoryTotals.forEach((key, value) {
      if (value > 0) {
        data.add(_PieData(_capitalize(key), value, colors[colorIndex % colors.length]));
        colorIndex++;
      }
    });

    if (data.isEmpty) {
      return const Center(
        child: AppText(
          'No expenses to show',
          color: AppColors.textHint,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    // Calculate total for percentage
    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);

    return Row(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 42,
                  sections: data.map((d) {
                    return PieChartSectionData(
                      value: d.value,
                      color: d.color,
                      radius: 24,
                      showTitle: false,
                    );
                  }).toList(),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    _formatPKR(total).replaceAll('PKR ', ''),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  const AppText(
                    'Total',
                    fontSize: 10,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: data.take(5).map((d) {
              final pct = (d.value / total) * 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: d.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: d.color.withOpacity(0.5),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        d.label,
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppText(
                      '${pct.toStringAsFixed(0)}%',
                      fontSize: 11.5,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);

  Widget _buildRecentTransactions(
      List<ExpenseModel> expenses, List<IncomeModel> incomes) {
    // Combine and sort
    final allTransactions = <_TransactionItem>[];

    for (var e in expenses) {
      allTransactions.add(_TransactionItem(
        title: e.title,
        subtitle: '${_capitalize(e.category)} • ${_formatDate(e.date)}',
        amount: _formatPKR(e.amount),
        icon: Icons.trending_down_rounded,
        isIncome: false,
        date: e.date,
      ));
    }

    for (var i in incomes) {
      allTransactions.add(_TransactionItem(
        title: i.clientName,
        subtitle: 'Income • ${_formatDate(i.date)}',
        amount: _formatPKR(i.amount),
        icon: Icons.trending_up_rounded,
        isIncome: true,
        date: i.date,
      ));
    }

    // Sort by date descending
    allTransactions.sort((a, b) => b.date.compareTo(a.date));

    // Take first 5
    final recent = allTransactions.take(5).toList();

    if (recent.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: AppText(
            'No transactions yet',
            color: AppColors.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      children: recent.map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppTransactionTile(
          title: t.title,
          subtitle: t.subtitle,
          amount: t.amount,
          icon: t.icon,
          isIncome: t.isIncome,
        ),
      )).toList(),
    );
  }

  String _formatDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}

class _PieData {
  final String label;
  final double value;
  final Color color;
  _PieData(this.label, this.value, this.color);
}

class _TransactionItem {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final bool isIncome;
  final DateTime date;

  _TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.isIncome,
    required this.date,
  });
}