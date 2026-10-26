import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

enum AppAlertType3 { warning, error, info, success }

class AppAlertTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final AppAlertType3 type;
  final VoidCallback? onTap;

  const AppAlertTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.type = AppAlertType3.warning,
    this.onTap,
  });

  Color get _color {
    switch (type) {
      case AppAlertType3.warning:
        return AppColors.warning;
      case AppAlertType3.error:
        return AppColors.error;
      case AppAlertType3.info:
        return AppColors.info;
      case AppAlertType3.success:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _color.withOpacity(0.08),
              _color.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Left colored strip
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_color, _color.withOpacity(0.6)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Decorative corner
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _color.withOpacity(0.06),
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _color,
                            _color.withOpacity(0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _color.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
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
                            title,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          AppText(
                            subtitle,
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: _color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}