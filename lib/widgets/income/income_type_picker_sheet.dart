import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class IncomeType {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String typeKey;

  const IncomeType({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.typeKey,
  });
}

class IncomeTypePickerSheet extends StatelessWidget {
  const IncomeTypePickerSheet({super.key});

  static const List<IncomeType> types = [
    IncomeType(
      label: 'Client Payment',
      subtitle: 'Payment from existing client',
      icon: Icons.payments_rounded,
      color: AppColors.success,
      typeKey: 'client_payment',
    ),
    IncomeType(
      label: 'New Project',
      subtitle: 'Invoice for new project',
      icon: Icons.work_rounded,
      color: AppColors.primary,
      typeKey: 'new_project',
    ),
    IncomeType(
      label: 'Retainer Payment',
      subtitle: 'Monthly retainer fee',
      icon: Icons.autorenew_rounded,
      color: AppColors.accent,
      typeKey: 'retainer',
    ),
    IncomeType(
      label: 'Other Income',
      subtitle: 'Anything else',
      icon: Icons.more_horiz_rounded,
      color: AppColors.warning,
      typeKey: 'other',
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
              // Handle bar
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

              // Title
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.success,
                          Color(0xFF34D399),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.35),
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
                        'Add Income',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      SizedBox(height: 2),
                      AppText(
                        'Choose a type to continue',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Types grid
              ...types.map((type) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, type),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: type.color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: type.color.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                type.color,
                                type.color.withOpacity(0.75),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: type.color.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            type.icon,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              AppText(
                                type.label,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                              const SizedBox(height: 2),
                              AppText(
                                type.subtitle,
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: type.color.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}