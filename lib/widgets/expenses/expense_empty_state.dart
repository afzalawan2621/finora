import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class ExpenseEmptyState extends StatelessWidget {
  final bool isSearchEmpty;
  final VoidCallback? onAddExpense;

  const ExpenseEmptyState({
    super.key,
    this.isSearchEmpty = false,
    this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.primary.withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isSearchEmpty
                          ? Icons.search_off_rounded
                          : Icons.receipt_long_outlined,
                      color: AppColors.primary,
                      size: 42,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            AppText(
              isSearchEmpty
                  ? 'No results found'
                  : 'No expenses yet',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: 8),
            AppText(
              isSearchEmpty
                  ? 'Try a different search term.'
                  : 'Start tracking your business spending by adding your first expense.',
              fontSize: 13,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
              height: 1.55,
            ),
            if (!isSearchEmpty && onAddExpense != null) ...[
              const SizedBox(height: 22),
              GestureDetector(
                onTap: onAddExpense,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      AppText(
                        'Add Expense',
                        fontSize: 13.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}