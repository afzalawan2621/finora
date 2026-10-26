import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../repositories/responsive_repo.dart';
import '../../widgets/common/app_background_widget.dart';
import '../../widgets/common/app_card_widget.dart';
import '../../widgets/common/app_text_widget.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const ComingSoonScreen({
    super.key,
    required this.title,
    this.icon = Icons.construction_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveRepo(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          title,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
      ),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: r.horizontalPadding,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: AppCard(
                  showTopAccent: true,
                  padding: EdgeInsets.all(r.spacing(28)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary
                                  .withOpacity(0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Title
                      AppText(
                        title,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // Subtitle
                      AppText(
                        'This section is coming soon. Stay tuned for updates!',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.center,
                        height: 1.5,
                      ),
                      const SizedBox(height: 22),
                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.warning
                                .withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.warning
                                        .withOpacity(0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppText(
                              'In Development',
                              fontSize: 11.5,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}