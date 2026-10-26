import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';
import '../common/app_text_widget.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  static const items = [
    _NavItem3(Icons.home_rounded, Icons.home_outlined, 'Home',
        AppRoutes.dashboard),
    _NavItem3(Icons.receipt_long_rounded, Icons.receipt_long_outlined,
        'Expenses', AppRoutes.expenses),
    _NavItem3(Icons.attach_money_rounded, Icons.attach_money_rounded,
        'Income', AppRoutes.income),
    _NavItem3(Icons.pie_chart_rounded, Icons.pie_chart_outline_rounded,
        'Budget', AppRoutes.budget),
    _NavItem3(Icons.more_horiz_rounded, Icons.more_horiz_rounded,
        'More', AppRoutes.more),
  ];

  void _handleTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    // Callback (optional)
    onTap?.call(index);

    // Navigate to the route
    final route = items[index].route;
    if (route == AppRoutes.dashboard) {
      // For dashboard, pop all back to it
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
            (r) => false,
      );
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final isActive = i == currentIndex;
              final item = items[i];

              return Expanded(
                child: GestureDetector(
                  onTap: () => _handleTap(context, i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          padding: EdgeInsets.symmetric(
                            horizontal: isActive ? 16 : 10,
                            vertical: isActive ? 8 : 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? AppColors.primaryGradient
                                : null,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isActive
                                ? [
                              BoxShadow(
                                color: AppColors.primary
                                    .withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                                : null,
                          ),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            size: 20,
                            color: isActive
                                ? Colors.white
                                : AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isActive ? 1 : 0.6,
                          child: AppText(
                            item.label,
                            fontSize: 9.5,
                            fontWeight: isActive
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem3 {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  final String route;
  const _NavItem3(this.activeIcon, this.icon, this.label, this.route);
}