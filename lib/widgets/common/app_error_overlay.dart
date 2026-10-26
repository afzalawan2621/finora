import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'app_text_widget.dart';

enum AppErrorType { error, success, warning, info }

class AppErrorOverlay {
  AppErrorOverlay._();

  static OverlayEntry? _currentEntry;

  // ─────────────────────────────────────────
  //  SHOW
  // ─────────────────────────────────────────
  static void show(
      BuildContext context, {
        required String heading,
        required String subheading,
        AppErrorType type = AppErrorType.error,
        Duration duration = const Duration(seconds: 4),
        VoidCallback? onTap,
      }) {
    _removeCurrent();

    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(
      builder: (context) => _ErrorBannerWidget(
        heading: heading,
        subheading: subheading,
        type: type,
        duration: duration,
        onTap: onTap,
        onDismissed: _removeCurrent,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  // ─────────────────────────────────────────
  //  DISMISS (public)
  // ─────────────────────────────────────────
  static void dismiss() {
    _removeCurrent();
  }

  // ─────────────────────────────────────────
  //  SHORTCUTS
  // ─────────────────────────────────────────
  static void error(
      BuildContext context, {
        required String heading,
        required String subheading,
        Duration? duration,
      }) {
    show(
      context,
      heading: heading,
      subheading: subheading,
      type: AppErrorType.error,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  static void success(
      BuildContext context, {
        required String heading,
        required String subheading,
        Duration? duration,
      }) {
    show(
      context,
      heading: heading,
      subheading: subheading,
      type: AppErrorType.success,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void warning(
      BuildContext context, {
        required String heading,
        required String subheading,
        Duration? duration,
      }) {
    show(
      context,
      heading: heading,
      subheading: subheading,
      type: AppErrorType.warning,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  static void info(
      BuildContext context, {
        required String heading,
        required String subheading,
        Duration? duration,
      }) {
    show(
      context,
      heading: heading,
      subheading: subheading,
      type: AppErrorType.info,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  static void _removeCurrent() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

// ═══════════════════════════════════════════
//  BANNER WIDGET
// ═══════════════════════════════════════════
class _ErrorBannerWidget extends StatefulWidget {
  final String heading;
  final String subheading;
  final AppErrorType type;
  final Duration duration;
  final VoidCallback onDismissed;
  final VoidCallback? onTap;

  const _ErrorBannerWidget({
    required this.heading,
    required this.subheading,
    required this.type,
    required this.duration,
    required this.onDismissed,
    this.onTap,
  });

  @override
  State<_ErrorBannerWidget> createState() => _ErrorBannerWidgetState();
}

class _ErrorBannerWidgetState extends State<_ErrorBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    _autoDismissTimer = Timer(widget.duration, () {
      if (mounted) _dismiss();
    });
  }

  void _dismiss() async {
    if (!mounted) return;
    _autoDismissTimer?.cancel();
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // ─── type → colors ───
  Color get _accent {
    switch (widget.type) {
      case AppErrorType.error:
        return AppColors.error;
      case AppErrorType.success:
        return AppColors.success;
      case AppErrorType.warning:
        return AppColors.warning;
      case AppErrorType.info:
        return AppColors.info;
    }
  }

  Color get _bgTint {
    switch (widget.type) {
      case AppErrorType.error:
        return const Color(0xFFFEF2F2);
      case AppErrorType.success:
        return const Color(0xFFECFDF5);
      case AppErrorType.warning:
        return const Color(0xFFFFFBEB);
      case AppErrorType.info:
        return const Color(0xFFEFF6FF);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case AppErrorType.error:
        return Icons.error_outline_rounded;
      case AppErrorType.success:
        return Icons.check_circle_outline_rounded;
      case AppErrorType.warning:
        return Icons.warning_amber_rounded;
      case AppErrorType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding + 8,
                left: 16,
                right: 16,
              ),
              child: GestureDetector(
                onTap: () {
                  widget.onTap?.call();
                  _dismiss();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accent.withOpacity(0.25),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 4,
                            color: _accent,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(color: _bgTint),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              16, 14, 12, 14),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _accent.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    _icon,
                                    color: _accent,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppText(
                                      widget.heading,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      maxLines: 1,
                                      overflow:
                                      TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    AppText(
                                      widget.subheading,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color:
                                      AppColors.textSecondary,
                                      height: 1.4,
                                      maxLines: 3,
                                      overflow:
                                      TextOverflow.ellipsis,
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}