import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class BudgetSummaryCard extends StatelessWidget {
  final String totalBudget;
  final String totalSpent;
  final String remaining;
  final double progressPercent;
  final bool isOverBudget;
  final String monthLabel;

  const BudgetSummaryCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
    required this.progressPercent,
    required this.isOverBudget,
    required this.monthLabel,
  });

  Color get _progressColor {
    if (progressPercent >= 1.0) return AppColors.error;
    if (progressPercent >= 0.85) return AppColors.warning;
    if (progressPercent >= 0.6) return const Color(0xFFEAB308);
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF312E81),
            Color(0xFF4F46E5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative orbs
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.pie_chart_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            AppText(
                              monthLabel,
                              fontSize: 10.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (isOverBudget)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              AppText(
                                'Over Budget',
                                fontSize: 9.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Total Budget
                  const AppText(
                    'Total Budget',
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    totalBudget,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),

                  const SizedBox(height: 18),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progressPercent.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _progressColor,
                                _progressColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: _progressColor.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      AppText(
                        '${(progressPercent * 100).toStringAsFixed(0)}% used',
                        fontSize: 11.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      const Spacer(),
                      AppText(
                        isOverBudget
                            ? 'Over by $remaining'
                            : '$remaining left',
                        fontSize: 11.5,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Bottom row: Spent + Remaining
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat(
                          icon: Icons.receipt_long_rounded,
                          label: 'Spent',
                          value: totalSpent,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      Expanded(
                        child: _buildMiniStat(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Remaining',
                          value: remaining,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.white70),
              const SizedBox(width: 4),
              AppText(
                label,
                fontSize: 10,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ],
          ),
          const SizedBox(height: 3),
          AppText(
            value,
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w800,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}