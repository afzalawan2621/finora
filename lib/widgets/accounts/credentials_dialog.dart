import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../common/app_text_widget.dart';

class CredentialsDialog extends StatelessWidget {
  final String fullName;
  final String email;
  final String password;
  final String role;

  const CredentialsDialog({
    super.key,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success,
                      Color(0xFF34D399),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const AppText(
                      'User Created!',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      '$fullName is now $role',
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Warning
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.warning,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: AppText(
                              'Save these credentials now. Password will not be shown again.',
                              fontSize: 11.5,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email field
                    _credentialTile(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email',
                      value: email,
                      color: AppColors.primary,
                    ),

                    const SizedBox(height: 10),

                    // Password field
                    _credentialTile(
                      icon: Icons.lock_outline_rounded,
                      label: 'Password',
                      value: password,
                      color: AppColors.accent,
                    ),

                    const SizedBox(height: 20),

                    // Copy button
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: 'Email: $email\nPassword: $password',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const AppText(
                              'Credentials copied!',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.copy_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              AppText(
                                'Copy Credentials',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Close
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: AppText(
                            'Done',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
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

  Widget _credentialTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                const SizedBox(height: 2),
                AppText(
                  value,
                  fontSize: 13.5,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
            },
            child: Icon(
              Icons.copy_rounded,
              size: 16,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}