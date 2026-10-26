import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../repositories/responsive_repo.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_text_widget.dart';
import '../../widgets/dashboard/app_bottom_nav_widget.dart';
import '../../widgets/dashboard/app_drawer_widget.dart';
import '../../widgets/expenses/category_picker_sheet.dart';
import '../../widgets/expenses/expense_category_chip.dart';
import '../../widgets/expenses/expense_date_group.dart';
import '../../widgets/expenses/expense_mini_stat_card.dart';
import '../../widgets/expenses/expense_summary_card.dart';
import '../../widgets/expenses/expense_tile.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  int _bottomNavIndex = 1;
  int _selectedCategory = 0;
  bool _isSearchActive = false;
  final _searchController = TextEditingController();

  final List<_ExpCategory2> _categories = [
    _ExpCategory2('All', Icons.apps_rounded, 0),
    _ExpCategory2('Salaries', Icons.groups_rounded, 0),
    _ExpCategory2('Rent', Icons.home_work_outlined, 0),
    _ExpCategory2('Bills', Icons.receipt_outlined, 0),
    _ExpCategory2('Groceries', Icons.shopping_cart_outlined, 0),
    _ExpCategory2('EMI', Icons.credit_card_rounded, 0),
    _ExpCategory2('Loans', Icons.account_balance_rounded, 0),
    _ExpCategory2('Hosting', Icons.cloud_outlined, 0),
    _ExpCategory2('Maintenance', Icons.build_outlined, 0),
    _ExpCategory2('Dialer', Icons.phone_android_rounded, 0),
    _ExpCategory2('Other', Icons.more_horiz_rounded, 0),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadExpenses() {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<ExpenseProvider>().fetchExpenses(auth.user!.ownerId);
    }
  }

  // ═══════════════════════════════════════════
  //  FAB FLOW — Category Picker → Add Screen
  // ═══════════════════════════════════════════
  Future<void> _handleAddExpense() async {
    // 1. Show category picker bottom sheet
    final ExpenseCategory? picked =
    await showModalBottomSheet<ExpenseCategory>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const CategoryPickerSheet(),
    );

    if (picked == null || !mounted) return;

    // 2. Navigate to Add Expense screen with category
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(category: picked),
      ),
    );

    // 3. Success snackbar
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const AppText(
            'Expense added successfully!',
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

  // ═══════════════════════════════════════════
  //  DELETE EXPENSE
  // ═══════════════════════════════════════════
  Future<void> _handleDeleteExpense(ExpenseModel expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const AppText(
          'Delete Expense?',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        content: const AppText(
          'Are you sure you want to delete this expense? This action cannot be undone.',
          fontSize: 13.5,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const AppText(
              'Cancel',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const AppText(
              'Delete',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success =
    await context.read<ExpenseProvider>().deleteExpense(expense);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const AppText(
            'Expense deleted!',
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(
            context.read<ExpenseProvider>().error ?? 'Failed to delete',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ═══════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveRepo(context);
    final auth = context.watch<AuthProvider>();
    final expenseProv = context.watch<ExpenseProvider>();
    final user = auth.user;

    final allExpenses = expenseProv.expenses;
    final filteredExpenses = _getFilteredExpenses(allExpenses);

    // ─── Update category counts dynamically ───
    for (var i = 0; i < _categories.length; i++) {
      final cat = _categories[i];
      if (cat.label == 'All') {
        _categories[i] = _ExpCategory2(cat.label, cat.icon, allExpenses.length);
      } else {
        final count = allExpenses.where((e) {
          final dbCat = e.category.toLowerCase();
          final localCat = cat.label.toLowerCase();
          return dbCat == localCat || dbCat.contains(localCat.substring(0, 3));
        }).length;
        _categories[i] = _ExpCategory2(cat.label, cat.icon, count);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: AppRoutes.expenses),
      appBar: _buildAppBar(user?.fullName ?? 'Owner'),
      body: RefreshIndicator(
        onRefresh: () async => _loadExpenses(),
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

              // Search bar
              if (_isSearchActive) ...[
                _buildSearchBar(),
                SizedBox(height: r.spacing(14)),
              ],

              // Summary Card
              ExpenseSummaryCard(
                totalAmount: _formatPKR(expenseProv.thisMonthAmount),
                changePercent: '+0%',
                changeUp: true,
                topCategory: _getTopCategory(allExpenses),
                topCategoryAmount: _formatPKR(_getTopCategoryAmount(allExpenses)),
                totalTransactions: allExpenses.length,
                sparklineData: const [8, 10, 9, 12, 14, 13, 15],
              ),

              SizedBox(height: r.spacing(14)),

              // Mini stats
              Row(
                children: [
                  Expanded(
                    child: ExpenseMiniStatCard(
                      label: 'This Week',
                      value: _formatPKR(
                          _calculateThisWeekAmount(allExpenses)),
                      icon: Icons.calendar_view_week_rounded,
                      accent: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ExpenseMiniStatCard(
                      label: 'Today',
                      value: _formatPKR(expenseProv.todayAmount),
                      icon: Icons.today_rounded,
                      accent: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ExpenseMiniStatCard(
                      label: 'Avg / Day',
                      value: _formatPKR(expenseProv.thisMonthAmount / 30),
                      icon: Icons.show_chart_rounded,
                      accent: AppColors.success,
                    ),
                  ),
                ],
              ),

              SizedBox(height: r.spacing(16)),

              // Categories
              SizedBox(
                height: 46,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return ExpenseCategoryChip(
                      label: cat.label,
                      icon: cat.icon,
                      count: cat.count,
                      isSelected: _selectedCategory == index,
                      onTap: () => setState(
                              () => _selectedCategory = index),
                    );
                  },
                ),
              ),

              SizedBox(height: r.spacing(8)),

              // Expenses list
              if (expenseProv.isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                )
              else if (filteredExpenses.isEmpty)
                _buildEmptyState()
              else
                ..._buildGroupedList(filteredExpenses, auth.canDelete),

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

  // ═══════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════
  List<ExpenseModel> _getFilteredExpenses(List<ExpenseModel> all) {
    var result = all;

    // Category filter
    if (_selectedCategory > 0) {
      final catLabel = _categories[_selectedCategory].label.toLowerCase();
      result = result.where((e) {
        final dbCat = e.category.toLowerCase();
        return dbCat == catLabel || dbCat.contains(catLabel.substring(0, 3));
      }).toList();
    }

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final q = _searchController.text.toLowerCase();
      result = result
          .where((e) =>
      e.title.toLowerCase().contains(q) ||
          (e.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return result;
  }

  List<Widget> _buildGroupedList(
      List<ExpenseModel> expenses, bool canDelete) {
    final r = ResponsiveRepo(context);
    final now = DateTime.now();

    // Group by date
    final today = <ExpenseModel>[];
    final yesterday = <ExpenseModel>[];
    final thisWeek = <ExpenseModel>[];
    final older = <ExpenseModel>[];

    for (final e in expenses) {
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(e.date.year, e.date.month, e.date.day))
          .inDays;
      if (diff == 0) {
        today.add(e);
      } else if (diff == 1) {
        yesterday.add(e);
      } else if (diff < 7) {
        thisWeek.add(e);
      } else {
        older.add(e);
      }
    }

    final widgets = <Widget>[];

    if (today.isNotEmpty) {
      widgets.add(ExpenseDateGroup(
        label: 'Today',
        total: _formatPKR(today.fold(0, (s, e) => s + e.amount)),
        count: today.length,
      ));
      widgets.addAll(
          today.map((e) => _buildTile(e, canDelete, r)));
    }

    if (yesterday.isNotEmpty) {
      widgets.add(ExpenseDateGroup(
        label: 'Yesterday',
        total: _formatPKR(yesterday.fold(0, (s, e) => s + e.amount)),
        count: yesterday.length,
      ));
      widgets.addAll(
          yesterday.map((e) => _buildTile(e, canDelete, r)));
    }

    if (thisWeek.isNotEmpty) {
      widgets.add(ExpenseDateGroup(
        label: 'This Week',
        total: _formatPKR(thisWeek.fold(0, (s, e) => s + e.amount)),
        count: thisWeek.length,
      ));
      widgets.addAll(
          thisWeek.map((e) => _buildTile(e, canDelete, r)));
    }

    if (older.isNotEmpty) {
      widgets.add(ExpenseDateGroup(
        label: 'Earlier',
        total: _formatPKR(older.fold(0, (s, e) => s + e.amount)),
        count: older.length,
      ));
      widgets.addAll(
          older.map((e) => _buildTile(e, canDelete, r)));
    }

    return widgets;
  }

  Widget _buildTile(
      ExpenseModel e, bool canDelete, ResponsiveRepo r) {
    final icon = _iconForCategory(e.category);
    final accent = _colorForCategory(e.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onLongPress: canDelete ? () => _handleDeleteExpense(e) : null,
        child: ExpenseTile(
          title: e.title,
          subtitle: '${_formatDate(e.date)} • ${e.paymentMethod}',
          amount: _formatPKR(e.amount),
          icon: icon,
          accent: accent,
          status: e.status == ExpenseStatus.paid ? 'Paid' : 'Pending',
          onTap: () {},
        ),
      ),
    );
  }

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
              Icons.receipt_long_outlined,
              size: 42,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          const AppText(
            'No expenses yet',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 6),
          const AppText(
            'Tap the + button below to add your first expense.',
            fontSize: 13,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
            height: 1.5,
          ),
        ],
      ),
    );
  }

  String _getTopCategory(List<ExpenseModel> all) {
    if (all.isEmpty) return 'None';
    final map = <String, double>{};
    for (final e in all) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    final top = map.entries.reduce((a, b) => a.value > b.value ? a : b);
    return top.key[0].toUpperCase() + top.key.substring(1);
  }

  double _getTopCategoryAmount(List<ExpenseModel> all) {
    if (all.isEmpty) return 0;
    final map = <String, double>{};
    for (final e in all) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map.values.reduce((a, b) => a > b ? a : b);
  }

  double _calculateThisWeekAmount(List<ExpenseModel> all) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return all
        .where((e) => e.date.isAfter(startOfWeek))
        .fold(0, (s, e) => s + e.amount);
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

  String _formatDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  IconData _iconForCategory(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('salar')) return Icons.groups_rounded;
    if (c.contains('rent')) return Icons.home_work_outlined;
    if (c.contains('bill')) return Icons.receipt_outlined;
    if (c.contains('groc')) return Icons.shopping_cart_outlined;
    if (c.contains('emi')) return Icons.credit_card_rounded;
    if (c.contains('loan')) return Icons.account_balance_rounded;
    if (c.contains('host')) return Icons.cloud_outlined;
    if (c.contains('maint')) return Icons.build_outlined;
    if (c.contains('dial')) return Icons.phone_android_rounded;
    return Icons.more_horiz_rounded;
  }

  Color _colorForCategory(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('salar')) return AppColors.success;
    if (c.contains('rent')) return AppColors.primary;
    if (c.contains('bill')) return AppColors.warning;
    if (c.contains('groc')) return AppColors.accent;
    if (c.contains('emi')) return const Color(0xFF8B5CF6);
    if (c.contains('loan')) return AppColors.error;
    if (c.contains('host')) return AppColors.info;
    if (c.contains('maint')) return const Color(0xFFF97316);
    if (c.contains('dial')) return const Color(0xFF06B6D4);
    return AppColors.textSecondary;
  }

  // ═══════════════════════════════════════════
  //  APPBAR
  // ═══════════════════════════════════════════
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
                'Expenses',
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
          onPressed: () => setState(
                  () => _isSearchActive = !_isSearchActive),
          icon: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _isSearchActive
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isSearchActive
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.inputBorder,
              ),
            ),
            child: Icon(
              _isSearchActive
                  ? Icons.close_rounded
                  : Icons.search_rounded,
              color: _isSearchActive
                  ? AppColors.primary
                  : AppColors.textPrimary,
              size: 20,
            ),
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          hintText: 'Search expenses...',
          hintStyle: TextStyle(
            color: AppColors.textHint,
            fontSize: 13,
          ),
          border: InputBorder.none,
          icon: Icon(
            Icons.search_rounded,
            color: AppColors.textHint,
            size: 20,
          ),
        ),
      ),
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
          onTap: _handleAddExpense,
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                AppText(
                  'Add Expense',
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

class _ExpCategory2 {
  final String label;
  final IconData icon;
  final int count;
  const _ExpCategory2(this.label, this.icon, this.count);
}