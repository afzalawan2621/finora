import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/income_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/income_provider.dart';
import '../../repositories/responsive_repo.dart';
import '../../widgets/common/app_text_widget.dart';
import '../../widgets/income/income_type_picker_sheet.dart';

class AddIncomeScreen extends StatefulWidget {
  final IncomeType type;

  const AddIncomeScreen({
    super.key,
    required this.type,
  });

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _clientController = TextEditingController();
  final _projectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocus = FocusNode();

  DateTime _selectedDate = DateTime.now();
  String _paymentMethod = 'Bank';
  String _status = 'Received';
  bool _isLoading = false;

  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _paymentMethods = [
    _PaymentMethod('Cash', Icons.payments_outlined),
    _PaymentMethod('Bank', Icons.account_balance_outlined),
    _PaymentMethod('JazzCash', Icons.phone_android_rounded),
    _PaymentMethod('Easypaisa', Icons.account_balance_wallet_outlined),
    _PaymentMethod('Company', Icons.business_outlined),
    _PaymentMethod('Other', Icons.more_horiz_rounded),
  ];

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));

    _entryController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _amountController.dispose();
    _clientController.dispose();
    _projectController.dispose();
    _descriptionController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.success,
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

  Future<void> _handleSave() async {
    final amountText = _amountController.text.trim();
    final client = _clientController.text.trim();

    if (amountText.isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    if (client.isEmpty) {
      _showError('Please enter client name');
      return;
    }

    final parsedAmount = double.tryParse(amountText.replaceAll(',', ''));
    if (parsedAmount == null || parsedAmount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final incomeProv = context.read<IncomeProvider>();

    if (auth.user == null) return;

    final income = IncomeModel(
      id: '',
      ownerId: auth.user!.ownerId,
      createdBy: auth.user!.uid,
      clientName: client,
      projectName: _projectController.text.trim().isEmpty
          ? null
          : _projectController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      incomeType: widget.type.typeKey,
      amount: parsedAmount,
      paymentMethod: _paymentMethod,
      status: _status == 'Received'
          ? IncomeStatus.received
          : IncomeStatus.pending,
      date: _selectedDate,
      createdAt: DateTime.now(),
    );

    final success = await incomeProv.addIncome(income);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      _showError(incomeProv.error ?? 'Failed to save income');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(
          msg,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveRepo(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: r.horizontalPadding,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Income type header
                _buildTypeHeader(),
                SizedBox(height: r.spacing(18)),

                // Amount field
                _buildSectionLabel('AMOUNT'),
                SizedBox(height: r.spacing(10)),
                _buildAmountField(),
                SizedBox(height: r.spacing(20)),

                // Client name
                _buildSectionLabel('CLIENT NAME'),
                SizedBox(height: r.spacing(10)),
                _buildInputField(
                  controller: _clientController,
                  hint: 'e.g. ABC Technologies',
                  icon: Icons.person_outline_rounded,
                ),
                SizedBox(height: r.spacing(20)),

                // Project name
                _buildSectionLabel('PROJECT', optional: true),
                SizedBox(height: r.spacing(10)),
                _buildInputField(
                  controller: _projectController,
                  hint: 'e.g. E-Commerce App',
                  icon: Icons.work_outline_rounded,
                ),
                SizedBox(height: r.spacing(20)),

                // Description
                _buildSectionLabel('DESCRIPTION', optional: true),
                SizedBox(height: r.spacing(10)),
                _buildDescriptionField(),
                SizedBox(height: r.spacing(20)),

                // Date
                _buildSectionLabel('DATE'),
                SizedBox(height: r.spacing(10)),
                _buildDateField(),
                SizedBox(height: r.spacing(20)),

                // Payment method
                _buildSectionLabel('PAYMENT METHOD'),
                SizedBox(height: r.spacing(10)),
                _buildPaymentMethodGrid(),
                SizedBox(height: r.spacing(20)),

                // Status
                _buildSectionLabel('STATUS'),
                SizedBox(height: r.spacing(10)),
                _buildStatusRow(),
                SizedBox(height: r.spacing(30)),

                // Save button
                _buildSaveButton(),
                SizedBox(height: r.spacing(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
              border: Border.all(
                color: AppColors.inputBorder,
              ),
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
        'Add Income',
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      centerTitle: true,
    );
  }

  // ═══════════════════════════════════════════
  //  TYPE HEADER
  // ═══════════════════════════════════════════
  Widget _buildTypeHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.type.color.withOpacity(0.2),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.type.color,
                  widget.type.color.withOpacity(0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: widget.type.color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              widget.type.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Income Type',
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                const SizedBox(height: 2),
                AppText(
                  widget.type.label,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: widget.type.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.type.color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 13,
                    color: widget.type.color,
                  ),
                  const SizedBox(width: 4),
                  AppText(
                    'Change',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: widget.type.color,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, {bool optional = false}) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.success, Color(0xFF34D399)],
            ),
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
        if (optional) ...[
          const SizedBox(width: 6),
          AppText(
            '(optional)',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textHint,
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════
  //  AMOUNT FIELD
  // ═══════════════════════════════════════════
  Widget _buildAmountField() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.success,
                  Color(0xFF34D399),
                ],
              ),
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
              controller: _amountController,
              focusNode: _amountFocus,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[\d.,]'),
                ),
              ],
              style: const TextStyle(
                fontSize: 28,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              cursorColor: AppColors.success,
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
    );
  }

  // ═══════════════════════════════════════════
  //  INPUT FIELD
  // ═══════════════════════════════════════════
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.inputBorder.withOpacity(0.6),
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          icon: Icon(
            icon,
            color: AppColors.textHint,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.inputBorder.withOpacity(0.6),
        ),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 2,
        minLines: 1,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          hintText: 'e.g. Payment for milestone 2',
          hintStyle: TextStyle(
            color: AppColors.textHint,
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      behavior: HitTestBehavior.opaque,
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
                    AppColors.success.withOpacity(0.15),
                    AppColors.success.withOpacity(0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(11),
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
                _formatDate(_selectedDate),
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
    );
  }

  Widget _buildPaymentMethodGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _paymentMethods.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final method = _paymentMethods[index];
        final isSelected = _paymentMethod == method.label;

        return GestureDetector(
          onTap: () =>
              setState(() => _paymentMethod = method.label),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                colors: [
                  AppColors.success,
                  Color(0xFF34D399),
                ],
              )
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : AppColors.inputBorder.withOpacity(0.6),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  method.icon,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: 6),
                AppText(
                  method.label,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        Expanded(
          child: _statusChip(
            label: 'Received',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            isSelected: _status == 'Received',
            onTap: () => setState(() => _status = 'Received'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statusChip(
            label: 'Pending',
            icon: Icons.access_time_rounded,
            color: AppColors.warning,
            isSelected: _status == 'Pending',
            onTap: () => setState(() => _status = 'Pending'),
          ),
        ),
      ],
    );
  }

  Widget _statusChip({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.5)
                : AppColors.inputBorder.withOpacity(0.6),
            width: isSelected ? 1.5 : 1.2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            AppText(
              label,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? color : AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleSave,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.success, Color(0xFF34D399)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.4),
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
              Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              AppText(
                'Save Income',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethod {
  final String label;
  final IconData icon;
  const _PaymentMethod(this.label, this.icon);
}