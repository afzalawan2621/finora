import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final String totalAmount;
  final String changePercent;
  final bool changeUp;
  final String topCategory;
  final String topCategoryAmount;
  final int totalTransactions;
  final List<double> sparklineData;

  const ExpenseSummaryCard({
    super.key,
    required this.totalAmount,
    required this.changePercent,
    required this.changeUp,
    required this.topCategory,
    required this.topCategoryAmount,
    required this.totalTransactions,
    required this.sparklineData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 32,
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
                  gradient: RadialGradient(
                    colors: [
                      AppColors.error.withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
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
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
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
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            AppText(
                              'Total Spent',
                              fontSize: 10.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: (changeUp
                              ? AppColors.error
                              : AppColors.success)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              changeUp
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 12,
                              color: changeUp
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFF86EFAC),
                            ),
                            const SizedBox(width: 3),
                            AppText(
                              changePercent,
                              fontSize: 10.5,
                              color: changeUp
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFF86EFAC),
                              fontWeight: FontWeight.w800,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Amount
                  AppText(
                    totalAmount,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.7,
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        size: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(width: 5),
                      AppText(
                        '$totalTransactions transactions this month',
                        fontSize: 11.5,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Sparkline
                  SizedBox(
                    height: 40,
                    child: CustomPaint(
                      size: const Size(double.infinity, 40),
                      painter: _SparklinePainter(
                        data: sparklineData,
                        color: AppColors.error,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Top category
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.error,
                                AppColors.error.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_fire_department_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              AppText(
                                'Top Category',
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                              const SizedBox(height: 2),
                              AppText(
                                topCategory,
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ],
                          ),
                        ),
                        AppText(
                          topCategoryAmount,
                          fontSize: 13.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sparkline painter ───
class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height -
          ((data[i] - minVal) / range) * (size.height - 8) -
          4;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}