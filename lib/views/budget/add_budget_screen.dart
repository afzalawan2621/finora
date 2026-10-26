import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/budget_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../repositories/responsive_repo.dart';
import '../../widgets/common/app_text_widget.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _totalBudgetController = TextEditingController();
  final Map<String, TextEditingController> _categoryControllers = {
    'salaries': TextEditingController(),
    'rent': TextEditingController(),
    'bills': TextEditingController(),
    'groceries': TextEditingController(),
    'emi': TextEditingController(),
    'loans': TextEditingController(),
    'hosting': TextEditingController(),
    'maintenance': TextEditingController(),
    'dialer': TextEditingController(),
    'other': TextEditingController(),
  };

  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  // Categories list for display
  static const _categories = [
    _CategoryItem('salaries', 'Salaries', Icons.groups_rounded, AppColors.success),
    _CategoryItem('rent', 'Rent', Icons.home_work_outlined, AppColors.primary),
    _CategoryItem('bills', 'Bills', Icons.receipt_outlined, AppColors.warning),
    _CategoryItem('groceries', 'Groceries', Icons.shopping_cart_outlined, AppColors.accent),
    _CategoryItem('emi', 'EMI', Icons.credit_card_rounded, Color(0xFF8B5CF6)),
    _CategoryItem('loans', 'Loans', Icons.account_balance_rounded, AppColors.error),
    _CategoryItem('hosting', 'Hosting', Icons.cloud_outlined, AppColors.info),
    _CategoryItem('maintenance', 'Maintenance', Icons.build_outlined, Color(0xFFF97316)),
    _CategoryItem('dialer', 'Dialer Bills', Icons.phone_android_rounded, Color(0xFF06B6D4)),
    _CategoryItem('other', 'Other', Icons.more_horiz_rounded, AppColors.textSecondary),
  ];

  @override
  void initState() {
    super.initState();
    // Load existing budget (if any) for selected month
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingBudget();
    });
  }

  @override
  void dispose() {
    _totalBudgetController.dispose();
    for (final c in _categoryControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExistingBudget() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    final monthKey = _formatMonthKey(_selectedMonth);
    final budgetProv = context.read<BudgetProvider>();
    await budgetProv.fetchBudget(auth.user!.ownerId, monthKey);

    if (!mounted) return;

    final budget = budgetProv.currentBudget;
    if (budget != null) {
      setState(() {
        _totalBudgetController.text =
            budget.totalBudget.toStringAsFixed(0);
        for (final entry in budget.categoryLimits.entries) {
          if (_categoryControllers.containsKey(entry.key)) {
            _categoryControllers[entry.key]!.text =
                entry.value.toStringAsFixed(0);
          }
        }
      });
    }
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select Month',
      initialDatePickerMode: DatePickerMode.year,
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
      setState(() => _selectedMonth = picked);
      await _loadExistingBudget();
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final totalText = _totalBudgetController.text.trim();
    final total = double.tryParse(totalText.replaceAll(',', '')) ?? 0;

    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a total budget')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    // Build category limits map
    final categoryLimits = <String, double>{};
    for (final entry in _categoryControllers.entries) {
      final val = double.tryParse(entry.value.text.replaceAll(',', '')) ?? 0;
      if (val > 0) {
        categoryLimits[entry.key] = val;
      }
    }

    final budget = BudgetModel(
      id: '',
      ownerId: auth.user!.ownerId,
      createdBy: auth.user!.uid,
      monthKey: _formatMonthKey(_selectedMonth),
      totalBudget: total,
      categoryLimits: categoryLimits,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success =
    await context.read<BudgetProvider>().saveBudget(budget);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              context.read<BudgetProvider>().error ?? 'Failed to save'),
        ),
      );
    }
  }

  String _formatMonthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  String _formatMonthYear(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveRepo(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const AppText(
          'Set Budget',
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: r.horizontalPadding,
          vertical: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Month Picker ───
              _buildSectionLabel('MONTH'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickMonth,
                child: Container(
                  padding: const EdgeInsets.all(14),
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
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.15),
                              AppColors.primary.withOpacity(0.06),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(11),
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
                          _formatMonthYear(_selectedMonth),
                          fontSize: 14,
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

              const SizedBox(height: 20),

              // ─── Total Budget ───
              _buildSectionLabel('TOTAL BUDGET'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const AppText(
                        'PKR',
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _totalBudgetController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\d.,]'),
                          ),
                        ],
                        style: const TextStyle(
                          fontSize: 22,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            fontSize: 28,
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w800,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Category Limits ───
              _buildSectionLabel('CATEGORY LIMITS'),
              const SizedBox(height: 4),
              const AppText(
                '(Leave blank if not needed)',
                fontSize: 11,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 12),

              ..._categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildCategoryTile(cat),
                );
              }),

              const SizedBox(height: 24),

              // ─── Save Button ───
              GestureDetector(
                onTap: _isLoading ? null : _handleSave,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_rounded,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        AppText(
                          'Save Budget',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
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
          letterSpacing: 1.2,
        ),
      ],
    );
  }

  Widget _buildCategoryTile(_CategoryItem cat) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.inputBorder.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(cat.icon, size: 17, color: cat.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              cat.label,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(
            width: 130,
            child: TextField(
              controller: _categoryControllers[cat.key],
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                prefixText: 'PKR ',
                prefixStyle: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const _CategoryItem(this.key, this.label, this.icon, this.color);
}