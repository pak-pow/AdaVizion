import 'package:flutter/material.dart';
import '../../landmark_constants.dart';

// ─── Error state ──────────────────────────────────────────────────────────────

/// General-purpose error widget for the landmark feature.
///
/// Pass [onRetry] for screens that can reload in-place (e.g. the list screen).
/// Pass [onBack] for detail screens that should pop the route on failure.
/// Both can be supplied simultaneously — the widget renders whichever are non-null.
///
/// The [error] string is mapped to a friendly message automatically; raw
/// technical detail is never shown to the user.
class LandmarkErrorState extends StatelessWidget {
  /// Raw error string used to determine the friendly message and icon.
  final String? error;

  /// Called when the user taps "Retry". Supply for in-place reload.
  final VoidCallback? onRetry;

  /// Called when the user taps "Go Back". Supply for detail/modal screens.
  final VoidCallback? onBack;

  const LandmarkErrorState({super.key, this.error, this.onRetry, this.onBack})
    : assert(
        onRetry != null || onBack != null,
        'Provide at least one of onRetry or onBack.',
      );

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String get _friendlyMessage {
    final e = error ?? '';
    if (e.contains('Scan landmark QR first')) {
      return 'Scan this landmark\'s QR code first to unlock its details.';
    }
    if (e.contains('Landmark not found')) {
      return 'This landmark no longer exists.';
    }
    if (e.contains('Failed to load landmarks')) {
      return 'Couldn\'t load landmarks. Check your connection and try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  IconData get _icon {
    final e = error ?? '';
    if (e.contains('Scan landmark QR first')) return Icons.lock_rounded;
    return Icons.wifi_off_rounded;
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Back button row — only rendered when [onBack] is provided.
          if (onBack != null)
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.black87,
                    ),
                    onPressed: onBack,
                  ),
                ),
              ),
            ),

          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_icon, size: 56, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      _friendlyMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Retry button
                    if (onRetry != null)
                      TextButton(
                        onPressed: onRetry,
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            color: kLandmarkMaroon,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                    // Go Back button
                    if (onBack != null)
                      TextButton(
                        onPressed: onBack,
                        child: const Text(
                          'Go Back',
                          style: TextStyle(
                            color: kLandmarkMaroon,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
