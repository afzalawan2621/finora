import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class ExpenseCategory {
  final String label;
  final IconData icon;
  final Color color;
  final String categoryKey;

  const ExpenseCategory({
    required this.label,
    required this.icon,
    required this.color,
    required this.categoryKey,
  });
}

class CategoryPickerSheet extends StatelessWidget {
  const CategoryPickerSheet({super.key});

  // ─── All Categories ───
  static const List<ExpenseCategory> categories = [
    ExpenseCategory(
      label: 'Salaries',
      icon: Icons.groups_rounded,
      color: AppColors.success,
      categoryKey: 'salaries',
    ),
    ExpenseCategory(
      label: 'Rent',
      icon: Icons.home_work_outlined,
      color: AppColors.primary,
      categoryKey: 'rent',
    ),
    ExpenseCategory(
      label: 'Bills',
      icon: Icons.receipt_outlined,
      color: AppColors.warning,
      categoryKey: 'bills',
    ),
    ExpenseCategory(
      label: 'Groceries',
      icon: Icons.shopping_cart_outlined,
      color: AppColors.accent,
      categoryKey: 'groceries',
    ),
    ExpenseCategory(
      label: 'EMI',
      icon: Icons.credit_card_rounded,
      color: Color(0xFF8B5CF6),
      categoryKey: 'emi',
    ),
    ExpenseCategory(
      label: 'Loans',
      icon: Icons.account_balance_rounded,
      color: Color(0xFFEF4444),
      categoryKey: 'loans',
    ),
    ExpenseCategory(
      label: 'Hosting',
      icon: Icons.cloud_outlined,
      color: AppColors.info,
      categoryKey: 'hosting',
    ),
    ExpenseCategory(
      label: 'Maintenance',
      icon: Icons.build_outlined,
      color: Color(0xFFF97316),
      categoryKey: 'maintenance',
    ),
    ExpenseCategory(
      label: 'Dialer Bills',
      icon: Icons.phone_android_rounded,
      color: Color(0xFF06B6D4),
      categoryKey: 'dialer',
    ),
    ExpenseCategory(
      label: 'Other',
      icon: Icons.more_horiz_rounded,
      color: AppColors.textSecondary,
      categoryKey: 'other',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Handle bar ───
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.inputBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ─── Title ───
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AppText(
                        'Add Expense',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      SizedBox(height: 2),
                      AppText(
                        'Choose a category to continue',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ─── Category Grid ───
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, cat),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: cat.color.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  cat.color,
                                  cat.color.withOpacity(0.75),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: [
                                BoxShadow(
                                  color: cat.color.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              cat.icon,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppText(
                            cat.label,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}