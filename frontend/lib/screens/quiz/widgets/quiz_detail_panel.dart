import 'package:flutter/material.dart';
import 'package:adavizion/theme/app_colors.dart';
import '../views/quiz_taking_view.dart';
import 'shared/quiz_error_state.dart';

// ─── Quiz detail panel ────────────────────────────────────────────────────────

/// The expanded section inside [QuizAccordionCard].
///
/// Shows a loading spinner, an inline error, or the rules box + start button
/// depending on [isLoading], [error], and [data].
class QuizDetailPanel extends StatelessWidget {
  final int quizId;
  final bool isLoading;
  final Map<String, dynamic>? data;
  final String? error;
  final VoidCallback onRetry;
  final void Function(int index)? onNavigateToTab;
  final VoidCallback? onQuizExited;

  const QuizDetailPanel({
    super.key,
    required this.quizId,
    required this.isLoading,
    required this.onRetry,
    this.data,
    this.error,
    this.onNavigateToTab,
    this.onQuizExited,
  });

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Separator between card header and panel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: Colors.grey.shade200, height: 1),
        ),

        // ── States ────────────────────────────────────────────────────────────
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(color: AppColors.maroon)),
          )
        else if (error != null)
          QuizErrorState(message: error, onRetry: onRetry, compact: true)
        else if (data != null)
          _DetailContent(
            quizId: quizId,
            data: data!,
            onNavigateToTab: onNavigateToTab,
            onQuizExited: onQuizExited,
          ),
      ],
    );
  }
}

// ─── Detail content ───────────────────────────────────────────────────────────

/// Renders the rules box and the Start / Already Completed button.
class _DetailContent extends StatelessWidget {
  final int quizId;
  final Map<String, dynamic> data;
  final void Function(int index)? onNavigateToTab;
  final VoidCallback? onQuizExited;

  const _DetailContent({
    required this.quizId,
    required this.data,
    this.onNavigateToTab,
    this.onQuizExited,
  });

  static const _rules = [
    'Answer all questions carefully before submitting. Once submitted, your answers cannot be changed.',
    'Your score will be recorded and displayed on the Quiz Scores screen after completion.',
  ];

  bool get _isCompleted => data['status']?['is_completed'] == true;

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Reminders box ─────────────────────────────────────────────────
          _RemindersBox(rules: _rules),

          const SizedBox(height: 20),

          // ── CTA ───────────────────────────────────────────────────────────
          if (!_isCompleted)
            _StartButton(onPressed: () => _startQuiz(context))
          else
            _AlreadyCompletedBadge(),
        ],
      ),
    );
  }

  Future<void> _startQuiz(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizTakingView(
          quizId: quizId,
          quizData: data,
          onNavigateToTab: onNavigateToTab,
        ),
      ),
    );
    onQuizExited?.call();
  }
}

// ─── Reminders box ────────────────────────────────────────────────────────────

/// Dark-bordered card listing numbered quiz rules.
class _RemindersBox extends StatelessWidget {
  final List<String> rules;
  const _RemindersBox({required this.rules});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.maroonGradientBottom, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.maroonGradientBottom,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: const Text(
              'Reminders / Rules',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Numbered rules
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(rules.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}. ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.maroonGradientBottom,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          rules[i],
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.maroon,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Start button ─────────────────────────────────────────────────────────────

class _StartButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _StartButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.maroonDeep,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text(
        'Start Quiz',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      ),
    );
  }
}

// ─── Already completed badge ──────────────────────────────────────────────────

class _AlreadyCompletedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          '✓ Already Completed',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.maroonGradientBottom,
          ),
        ),
      ),
    );
  }
}
