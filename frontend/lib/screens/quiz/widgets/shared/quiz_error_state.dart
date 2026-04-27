import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

// ─── Error state ──────────────────────────────────────────────────────────────

/// General-purpose error widget for quiz screens.
///
/// Supply [onRetry] for in-place reload (e.g. the list screen or detail panel).
/// Supply [message] to override the default copy.
/// [compact] reduces padding when embedded inside a card rather than full-screen.
class QuizErrorState extends StatelessWidget {
  /// Human-readable error description. Falls back to a generic message.
  final String? message;

  /// Called when the user taps "Try Again".
  final VoidCallback onRetry;

  /// When `true`, uses tighter padding suited for inline use inside a card.
  final bool compact;

  const QuizErrorState({
    super.key,
    required this.onRetry,
    this.message,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = compact
        ? const EdgeInsets.all(16)
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 40);

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.maroonDark,
            size: compact ? 36 : 48,
          ),
          const SizedBox(height: 12),
          if (!compact)
            const Text(
              'Failed to load quizzes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.maroonDark,
              ),
            ),
          if (!compact) const SizedBox(height: 4),
          Text(
            message ?? 'Something went wrong. Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.maroonDark,
              side: const BorderSide(color: AppColors.maroonDark, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
