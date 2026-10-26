import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';
import 'budget_progress_bar.dart';

class BudgetCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final List<BudgetCategoryItem> items;
  final VoidCallback? onTap;

  const BudgetCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.inputBorder.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Left accent strip
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                color: accent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accent,
                              accent.withOpacity(0.75),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      AppText(
                        title,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...items.map((item) => BudgetProgressBar(
                    category: item.name,
                    spent: item.spent,
                    limit: item.limit,
                    progress: item.progress,
                    accent: accent,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetCategoryItem {
  final String name;
  final String spent;
  final String limit;
  final double progress;

  const BudgetCategoryItem({
    required this.name,
    required this.spent,
    required this.limit,
    required this.progress,
  });
}