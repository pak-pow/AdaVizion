import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import 'package:adavizion/theme/app_colors.dart';
import 'quiz_detail_panel.dart';

// ─── Quiz accordion card ──────────────────────────────────────────────────────

/// Expandable card shown in [QuizListScreen] for each quiz entry.
///
/// Handles its own expand/collapse animation. When expanded, delegates to
/// [QuizDetailPanel] which loads and renders the full quiz rules + CTA.
class QuizAccordionCard extends StatelessWidget {
  final int quizId;
  final QuizState state;
  final String title;
  final String hint;
  final int? scoreAchieved;
  final int? maxScore;
  final bool isExpanded;

  /// Called when the header is tapped (ignored when [state] is [QuizState.locked]).
  final VoidCallback onToggle;

  /// Called when the user exits a quiz via the buttons in results page
  final VoidCallback? onQuizExited;

  // Detail panel pass-throughs
  final bool detailLoading;
  final Map<String, dynamic>? detailData;
  final String? detailError;
  final VoidCallback onRetryDetail;
  final void Function(int index)? onNavigateToTab;

  const QuizAccordionCard({
    super.key,
    required this.quizId,
    required this.state,
    required this.title,
    required this.hint,
    required this.isExpanded,
    required this.onToggle,
    required this.onRetryDetail,
    this.scoreAchieved,
    this.maxScore,
    this.detailLoading = false,
    this.detailData,
    this.detailError,
    this.onNavigateToTab,
    this.onQuizExited,
  });

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLocked = state == QuizState.locked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isExpanded ? 0.10 : 0.05),
            blurRadius: isExpanded ? 24 : 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Collapsed header (always visible) ─────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Status pill / CTA button ─────────────────────────────────
                GestureDetector(
                  onTap: isLocked ? null : onToggle,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.grey.shade400 : AppColors.maroonGradientBottom,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: _PillContent(
                        state: state,
                        scoreAchieved: scoreAchieved,
                        maxScore: maxScore,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Quiz title ──────────────────────────────────────────────
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.maroonGradientBottom,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),

                // ── Hint ────────────────────────────────────────────────────
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.maroonGradientBottom,
                  ),
                ),
              ],
            ),
          ),

          // ── Expanded detail panel (animated) ──────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: QuizDetailPanel(
              quizId: quizId,
              isLoading: detailLoading,
              data: detailData,
              error: detailError,
              onRetry: onRetryDetail,
              onNavigateToTab: onNavigateToTab,
              onQuizExited: onQuizExited,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pill content ─────────────────────────────────────────────────────────────

/// The icon / text shown inside the colored status pill.
class _PillContent extends StatelessWidget {
  final QuizState state;
  final int? scoreAchieved;
  final int? maxScore;

  const _PillContent({required this.state, this.scoreAchieved, this.maxScore});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case QuizState.locked:
        return const Icon(Icons.lock_outline, color: Colors.white, size: 32);

      case QuizState.completed:
        final label = (scoreAchieved != null && maxScore != null)
            ? '$scoreAchieved/$maxScore'
            : 'Completed';
        return Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        );

      case QuizState.unlocked:
        return const Text(
          'Take Quiz',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        );
    }
  }
}
