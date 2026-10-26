import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/auth_helper.dart';
import '../../models/user_status.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/responsive_repo.dart';
import '../../routes/app_routes.dart';
import '../../widgets/auth/app_footer_note_widget.dart';
import '../../widgets/common/app_background_widget.dart';
import '../../widgets/common/app_button_widget.dart';
import '../../widgets/common/app_card_widget.dart';
import '../../widgets/common/app_info_row_widget.dart';
import '../../widgets/common/app_section_label_widget.dart';
import '../../widgets/common/app_text_widget.dart';

class WaitingApprovalScreen extends StatefulWidget {
  const WaitingApprovalScreen({super.key});

  @override
  State<WaitingApprovalScreen> createState() =>
      _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends State<WaitingApprovalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  bool _isChecking = false;
  Timer? _autoRefreshTimer; // ← Auto refresh timer

  @override
  void initState() {
    super.initState();
    AuthHelper.onScreenOpen();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Auto-refresh every 5 seconds
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) => _autoCheckStatus(),
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _pulseController.dispose();
    AuthHelper.onScreenClose();
    super.dispose();
  }

  // ─── Silent auto-check ───
  Future<void> _autoCheckStatus() async {
    if (_isChecking) return;
    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final status = await auth.refreshStatus();

    if (!mounted) return;

    if (status == UserStatus.approved) {
      _autoRefreshTimer?.cancel();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
            (route) => false,
      );
    } else if (status == UserStatus.rejected ||
        status == UserStatus.blocked) {
      _autoRefreshTimer?.cancel();
      await auth.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
            (route) => false,
      );
    }
  }

  // ─── Manual check button ───
  Future<void> _handleCheckStatus() async {
    _autoRefreshTimer?.cancel(); // stop auto-refresh temporarily

    await AuthHelper.handleWaitingApprovalCheck(
      context,
      setLoading: (v) => setState(() => _isChecking = v),
    );

    // Restart auto-refresh if still on this screen
    if (mounted) {
      _autoRefreshTimer?.cancel();
      _autoRefreshTimer = Timer.periodic(
        const Duration(seconds: 5),
            (_) => _autoCheckStatus(),
      );
    }
  }

  Future<void> _handleBackToLogin() async {
    _autoRefreshTimer?.cancel();
    await AuthHelper.handleBackToLogin(context);
  }

  String _formattedTime(DateTime? date) {
    if (date == null) return '—';
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final mo = date.month.toString().padLeft(2, '0');
    return '$d/$mo/${date.year} • $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveRepo(context);
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: r.horizontalPadding,
                vertical: r.verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: r.h(2)),

                    // ─── Animated Icon ───
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnim.value,
                                child: Container(
                                  width: r.w(42),
                                  height: r.w(42),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.warning
                                        .withOpacity(0.08),
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
                            width: r.w(32),
                            height: r.w(32),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.warning
                                  .withOpacity(0.12),
                            ),
                          ),
                          Container(
                            width: r.w(22),
                            height: r.w(22),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.warning,
                                  Color(0xFFFBBF24),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.warning
                                      .withOpacity(0.35),
                                  blurRadius: 30,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.hourglass_top_rounded,
                                size: r.icon(36),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: r.h(4)),

                    Center(
                      child: AppText(
                        AppStrings.waitingTitle,
                        fontSize: r.font(26),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        textAlign: TextAlign.center,
                        letterSpacing: -0.4,
                      ),
                    ),

                    SizedBox(height: r.spacing(10)),

                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.spacing(16),
                        ),
                        child: AppText(
                          AppStrings.waitingSubtitle,
                          fontSize: r.font(13.5),
                          color: AppColors.textSecondary,
                          textAlign: TextAlign.center,
                          height: 1.55,
                        ),
                      ),
                    ),

                    SizedBox(height: r.h(4)),

                    // ─── Card ───
                    AppCard(
                      showTopAccent: true,
                      padding: EdgeInsets.all(r.spacing(24)),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                        children: [
                          AppSectionLabel(
                            label: AppStrings.approvalStatusLabel,
                          ),

                          SizedBox(height: r.spacing(14)),

                          // ─── Status chip (LIVE) ───
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: (user?.status == UserStatus.approved
                                  ? AppColors.success
                                  : user?.status == UserStatus.rejected
                                  ? AppColors.error
                                  : AppColors.warning)
                                  .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (user?.status ==
                                    UserStatus.approved
                                    ? AppColors.success
                                    : user?.status ==
                                    UserStatus.rejected
                                    ? AppColors.error
                                    : AppColors.warning)
                                    .withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: user?.status ==
                                        UserStatus.approved
                                        ? AppColors.success
                                        : user?.status ==
                                        UserStatus.rejected
                                        ? AppColors.error
                                        : AppColors.warning,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (user?.status ==
                                            UserStatus
                                                .approved
                                            ? AppColors.success
                                            : user?.status ==
                                            UserStatus
                                                .rejected
                                            ? AppColors.error
                                            : AppColors.warning)
                                            .withOpacity(0.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppText(
                                    user?.status == UserStatus.approved
                                        ? 'Approved'
                                        : user?.status ==
                                        UserStatus.rejected
                                        ? 'Rejected'
                                        : AppStrings
                                        .approvalStatusPending,
                                    fontSize: r.font(13),
                                    fontWeight: FontWeight.w700,
                                    color: user?.status ==
                                        UserStatus.approved
                                        ? AppColors.success
                                        : user?.status ==
                                        UserStatus.rejected
                                        ? AppColors.error
                                        : AppColors.warning,
                                  ),
                                ),
                                const Icon(
                                  Icons.schedule_rounded,
                                  size: 16,
                                  color: AppColors.warning,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: r.spacing(18)),

                          // ─── Info rows ───
                          AppInfoRow(
                            icon: Icons.person_outline_rounded,
                            label: AppStrings.approvalNameLabel,
                            value: user?.fullName ?? '—',
                            fontSize: r.font(13),
                          ),
                          SizedBox(height: r.spacing(10)),
                          AppInfoRow(
                            icon: Icons.mail_outline_rounded,
                            label: AppStrings.approvalEmailLabel,
                            value: user?.email ?? '—',
                            fontSize: r.font(13),
                          ),
                          SizedBox(height: r.spacing(10)),
                          AppInfoRow(
                            icon: Icons.access_time_rounded,
                            label: AppStrings.approvalSubmittedLabel,
                            value: _formattedTime(user?.createdAt),
                            fontSize: r.font(13),
                          ),

                          SizedBox(height: r.spacing(20)),

                          Container(
                            height: 1,
                            color:
                            AppColors.inputBorder.withOpacity(0.5),
                          ),

                          SizedBox(height: r.spacing(18)),

                          // ─── What happens next ───
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withOpacity(0.08),
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      AppStrings.approvalInfoTitle,
                                      fontSize: r.font(13),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    const SizedBox(height: 4),
                                    AppText(
                                      AppStrings.approvalInfoMsg,
                                      fontSize: r.font(12),
                                      color: AppColors
                                          .textSecondary,
                                      height: 1.5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: r.spacing(22)),

                          // ─── Auto-refresh hint ───
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                              AppColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.8,
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AppText(
                                  'Auto-checking every 5 seconds',
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: r.spacing(14)),

                          // ─── Check status button ───
                          AppButton(
                            label: AppStrings.checkStatus,
                            onPressed: _handleCheckStatus,
                            isLoading: _isChecking,
                            icon: Icons.refresh_rounded,
                          ),

                          SizedBox(height: r.spacing(12)),

                          AppButton(
                            label: AppStrings.backToLoginBtn,
                            onPressed: _handleBackToLogin,
                            type: AppButtonType.outline,
                            icon: Icons.arrow_back_rounded,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: r.spacing(16)),

                    // ─── Contact support ───
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary
                                  .withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.support_agent_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              AppText(
                                AppStrings.contactSupport,
                                fontSize: r.font(12.5),
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: r.spacing(16)),

                    AppFooterNote(
                      text: AppStrings.endToEndEncrypted,
                    ),

                    SizedBox(height: r.h(2)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}