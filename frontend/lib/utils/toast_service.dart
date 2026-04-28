import 'package:flutter/material.dart';
import 'package:adavizion/theme/app_colors.dart';
import 'package:adavizion/services/api/api_config.dart';

// ============================================================================
// TOAST SERVICE
//
// Provides three levels of notification:
//   • showError / showInfo / showSuccess  — SnackBar-based, context-optional
//   • showAchievement                     — Custom overlay with slide-in anim
//
// GLOBALISATION PATTERN
// ─────────────────────
// Every public method accepts an *optional* [BuildContext].
// • If a context is supplied  → uses ScaffoldMessenger.of(context)  (legacy).
// • If context is omitted     → falls back to ApiConfig.navigatorKey.currentContext.
//
// This means you can call:
//   ToastService.showSuccess('Uploaded!');          // from a service / XP logic
//   ToastService.showSuccess('Uploaded!', context); // from a widget (legacy)
//
// showAchievement always uses the global Overlay via the navigatorKey so it
// can be triggered from *anywhere* — including async XP callbacks.
// ============================================================================

class ToastService {
  // ──────────────────────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  /// Resolves a usable [BuildContext]: caller-supplied first, then global nav.
  static BuildContext? _resolveContext([BuildContext? ctx]) {
    return ctx ?? ApiConfig.navigatorKey.currentContext;
  }

  /// Internal SnackBar dispatcher.
  static void _showSnackBar(
    String message,
    Color bgColor,
    IconData icon, [
    BuildContext? ctx,
  ]) {
    final context = _resolveContext(ctx);
    if (context == null) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PUBLIC SNACKBAR METHODS (context-optional)
  // ──────────────────────────────────────────────────────────────────────────

  /// Shows a green success SnackBar.
  ///
  /// Omit [context] to use the global navigator context (e.g. from a service).
  static void showSuccess(String message, [BuildContext? context]) {
    _showSnackBar(message, AppColors.green, Icons.check_circle, context);
  }

  /// Shows a maroon error SnackBar.
  ///
  /// Omit [context] to use the global navigator context.
  static void showError(String message, [BuildContext? context]) {
    _showSnackBar(message, AppColors.maroon, Icons.error, context);
  }

  /// Shows a neutral info SnackBar.
  ///
  /// Omit [context] to use the global navigator context.
  static void showInfo(String message, [BuildContext? context]) {
    _showSnackBar(
        message, Colors.grey.shade800, Icons.info_outline, context);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ACHIEVEMENT TOAST  (Overlay-based, fully context-free)
  // ──────────────────────────────────────────────────────────────────────────

  /// Shows a premium "Achievement Unlocked" overlay toast.
  ///
  /// Slides in from the top with a spring-style animation and auto-dismisses
  /// after 3 seconds.  Fully global — no [BuildContext] required.
  ///
  /// ```dart
  /// // Trigger from anywhere — widget, service, XP callback:
  /// ToastService.showAchievement('Level Up!', 'You are now Level 2!');
  /// ```
  static void showAchievement(String title, String message) {
    final context = ApiConfig.navigatorKey.currentContext;
    if (context == null) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _AchievementToast(
        title: title,
        message: message,
        onDismissed: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

// ============================================================================
// _AchievementToast  — animated widget rendered in the Overlay
// ============================================================================

class _AchievementToast extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onDismissed;

  const _AchievementToast({
    required this.title,
    required this.message,
    required this.onDismissed,
  });

  @override
  State<_AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<_AchievementToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    // Slide in from top-center (−1 → 0 in Y axis)
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Auto-dismiss: play in → wait 3 s → play out → remove from overlay
    _controller.forward().then((_) async {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        await _controller.reverse();
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6B0000), // deep maroon
                    Color(0xFF9B1C1C), // rich maroon-red
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B0000).withAlpha(130),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: AppColors.gold.withAlpha(100),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Trophy Icon ──────────────────────────────────────────
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.gold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // ── Text Column ──────────────────────────────────────────
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Eyebrow label
                        Text(
                          'ACHIEVEMENT UNLOCKED',
                          style: TextStyle(
                            color: AppColors.gold.withAlpha(220),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Title
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Message
                        Text(
                          widget.message,
                          style: const TextStyle(
                            color: Color(0xFFFFCDD2),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
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
    );
  }
}
