import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/income_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/income_provider.dart';
import '../../repositories/responsive_repo.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_text_widget.dart';
import '../../widgets/dashboard/app_bottom_nav_widget.dart';
import '../../widgets/dashboard/app_drawer_widget.dart';
import '../../widgets/income/income_client_tile.dart';
import '../../widgets/income/income_date_group.dart';
import '../../widgets/income/income_invoice_chip.dart';
import '../../widgets/income/income_mini_stat_card.dart';
import '../../widgets/income/income_summary_card.dart';
import '../../widgets/income/income_type_picker_sheet.dart';
import 'add_income_screen.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  int _bottomNavIndex = 2; // Income
  int _selectedFilter = 0;
  bool _isSearchActive = false;
  final _searchController = TextEditingController();

  final List<_IncomeFilter> _filters = [
    _IncomeFilter('All', Icons.apps_rounded, 0),
    _IncomeFilter('Received', Icons.check_circle_outline_rounded, 0),
    _IncomeFilter('Pending', Icons.schedule_rounded, 0),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIncomes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadIncomes() {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<IncomeProvider>().fetchIncomes(auth.user!.ownerId);
    }
  }

  // ═══════════════════════════════════════════
  //  DELETE INCOME
  // ═══════════════════════════════════════════
  Future<void> _handleDeleteIncome(IncomeModel income) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const AppText(
          'Delete Income?',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        content: const AppText(
          'Are you sure you want to delete this income entry? This action cannot be undone.',
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
    await context.read<IncomeProvider>().deleteIncome(income);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const AppText(
            'Income deleted!',
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
            context.read<IncomeProvider>().error ?? 'Failed to delete',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveRepo(context);
    final auth = context.watch<AuthProvider>();
    final incomeProv = context.watch<IncomeProvider>();
    final user = auth.user;

    final allIncomes = incomeProv.incomes;
    final filteredIncomes = _getFilteredIncomes(allIncomes);

    // Update category counts dynamically
    for (var i = 0; i < _filters.length; i++) {
      final f = _filters[i];
      if (f.label == 'All') {
        _filters[i] = _IncomeFilter(f.label, f.icon, allIncomes.length);
      } else if (f.label == 'Received') {
        final count = allIncomes
            .where((e) => e.status == IncomeStatus.received)
            .length;
        _filters[i] = _IncomeFilter(f.label, f.icon, count);
      } else if (f.label == 'Pending') {
        final count = allIncomes
            .where((e) => e.status == IncomeStatus.pending)
            .length;
        _filters[i] = _IncomeFilter(f.label, f.icon, count);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: AppRoutes.income),
      appBar: _buildAppBar(user?.fullName ?? 'Owner'),
      body: RefreshIndicator(
        onRefresh: () async => _loadIncomes(),
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

              // Summary card
              IncomeSummaryCard(
                totalAmount: _formatPKR(incomeProv.totalAmount),
                changePercent: '+0%',
                changeUp: true,
                pendingAmount: _formatPKR(incomeProv.pendingAmount),
                pendingClients: allIncomes
                    .where((e) => e.status == IncomeStatus.pending)
                    .length,
                sparklineData: const [10, 12, 11, 15, 18, 22, 25],
              ),

              SizedBox(height: r.spacing(14)),

              // Mini stats
              Row(
                children: [
                  Expanded(
                    child: IncomeMiniStatCard(
                      label: 'Total',
                      value: _formatPKR(incomeProv.totalAmount),
                      icon: Icons.calendar_month_rounded,
                      accent: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: IncomeMiniStatCard(
                      label: 'Received',
                      value: _formatPKR(
                        allIncomes
                            .where((e) => e.status == IncomeStatus.received)
                            .fold(0, (s, e) => s + e.amount),
                      ),
                      icon: Icons.check_circle_outline_rounded,
                      accent: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: IncomeMiniStatCard(
                      label: 'Pending',
                      value: _formatPKR(incomeProv.pendingAmount),
                      icon: Icons.access_time_rounded,
                      accent: AppColors.warning,
                    ),
                  ),
                ],
              ),

              SizedBox(height: r.spacing(16)),

              // Filter chips
              SizedBox(
                height: 46,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final f = _filters[index];
                    return IncomeInvoiceChip(
                      label: f.label,
                      icon: f.icon,
                      count: f.count,
                      isSelected: _selectedFilter == index,
                      onTap: () =>
                          setState(() => _selectedFilter = index),
                    );
                  },
                ),
              ),

              SizedBox(height: r.spacing(8)),

              // Client list
              if (incomeProv.isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                )
              else if (filteredIncomes.isEmpty)
                _buildEmptyState()
              else
                ..._buildGroupedList(filteredIncomes, auth.canDelete),

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
  List<IncomeModel> _getFilteredIncomes(List<IncomeModel> all) {
    var result = all;

    // Filter by status
    if (_selectedFilter == 1) {
      result =
          result.where((e) => e.status == IncomeStatus.received).toList();
    } else if (_selectedFilter == 2) {
      result =
          result.where((e) => e.status == IncomeStatus.pending).toList();
    }

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final q = _searchController.text.toLowerCase();
      result = result
          .where((e) =>
      e.clientName.toLowerCase().contains(q) ||
          (e.projectName?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return result;
  }

  List<Widget> _buildGroupedList(
      List<IncomeModel> incomes, bool canDelete) {
    final r = ResponsiveRepo(context);
    final now = DateTime.now();

    final today = <IncomeModel>[];
    final yesterday = <IncomeModel>[];
    final thisWeek = <IncomeModel>[];
    final older = <IncomeModel>[];

    for (final e in incomes) {
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
      widgets.add(IncomeDateGroup(
        label: 'Today',
        total: _formatPKR(today.fold(0, (s, e) => s + e.amount)),
        count: today.length,
      ));
      widgets.addAll(today.map((e) => _buildTile(e, canDelete, r)));
    }

    if (yesterday.isNotEmpty) {
      widgets.add(IncomeDateGroup(
        label: 'Yesterday',
        total: _formatPKR(yesterday.fold(0, (s, e) => s + e.amount)),
        count: yesterday.length,
      ));
      widgets.addAll(yesterday.map((e) => _buildTile(e, canDelete, r)));
    }

    if (thisWeek.isNotEmpty) {
      widgets.add(IncomeDateGroup(
        label: 'This Week',
        total: _formatPKR(thisWeek.fold(0, (s, e) => s + e.amount)),
        count: thisWeek.length,
      ));
      widgets.addAll(thisWeek.map((e) => _buildTile(e, canDelete, r)));
    }

    if (older.isNotEmpty) {
      widgets.add(IncomeDateGroup(
        label: 'Earlier',
        total: _formatPKR(older.fold(0, (s, e) => s + e.amount)),
        count: older.length,
      ));
      widgets.addAll(older.map((e) => _buildTile(e, canDelete, r)));
    }

    return widgets;
  }

  Widget _buildTile(
      IncomeModel e, bool canDelete, ResponsiveRepo r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onLongPress: canDelete ? () => _handleDeleteIncome(e) : null,
        child: IncomeClientTile(
          clientName: e.clientName,
          projectName: e.projectName ?? 'No project',
          amount: _formatPKR(e.amount),
          icon: Icons.payments_rounded,
          accent: AppColors.success,
          status: e.status == IncomeStatus.received ? 'Paid' : 'Pending',
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
              color: AppColors.success.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 42,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 18),
          const AppText(
            'No income yet',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 6),
          const AppText(
            'Tap the + button below to add your first income.',
            fontSize: 13,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
            height: 1.5,
          ),
        ],
      ),
    );
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
                'Income',
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
                  AppColors.success.withOpacity(0.15),
                  AppColors.success.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppColors.success,
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
          hintText: 'Search clients or projects...',
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
          onTap: () async {
            // 1. Income type picker
            final IncomeType? picked =
            await showModalBottomSheet<IncomeType>(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => const IncomeTypePickerSheet(),
            );

            if (picked == null || !mounted) return;

            // 2. Add Income screen
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddIncomeScreen(type: picked),
              ),
            );

            // 3. Snackbar
            if (result == true && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const AppText(
                    'Income added successfully!',
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
          },
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
                  'Add Income',
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

class _IncomeFilter {
  final String label;
  final IconData icon;
  final int count;
  const _IncomeFilter(this.label, this.icon, this.count);
}