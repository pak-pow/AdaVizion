import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../quiz_constants.dart';

// ─── Quiz result view ─────────────────────────────────────────────────────────

/// Displays the score, pass/fail status, XP earned, and a full answer review
/// after a quiz is submitted.
class QuizResultView extends StatelessWidget {
  final String quizName;
  final QuizResult result;
  final List<dynamic> questions;

  /// Maps `question_id` → selected choice index.
  final Map<int, int> selectedAnswers;
  final void Function(int index)? onNavigateToTab;

  const QuizResultView({
    super.key,
    required this.quizName,
    required this.result,
    required this.questions,
    required this.selectedAnswers,
    this.onNavigateToTab,
  });

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with proper toast/notification system once implemented.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRewardToasts(context);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: kQuizHeaderGrey,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Image.asset('assets/images/nav_logo.png', height: 75),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Title ──────────────────────────────────────────────────────
              _TitleHeader(title: quizName),
              const SizedBox(height: 20),

              // ── Stats row ──────────────────────────────────────────────────
              _StatsRow(result: result),
              const SizedBox(height: 16),

              // ── Action buttons ─────────────────────────────────────────────
              _ActionsRow(onNavigateToTab: onNavigateToTab, context: context),
              const SizedBox(height: 24),

              // ── Divider ────────────────────────────────────────────────────
              const Divider(thickness: 1.5, color: kQuizDivider),
              const SizedBox(height: 16),

              // ── Answer review ──────────────────────────────────────────────
              _AnswerReview(
                questions: questions,
                selectedAnswers: selectedAnswers,
                correctnessById: result.correctnessById,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Reward toasts ───────────────────────────────────────────────────────────

  /// Shows level-up and achievement snackbars.
  /// TODO: Remove once dedicated toast notifications are implemented.
  void _showRewardToasts(BuildContext context) {
    if (result.didLevelUp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Level Up! You are now Level ${result.currentLevel}!',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: kQuizMaroonDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    for (final achievement in result.newAchievements) {
      final title =
          (achievement as Map<String, dynamic>)['title'] as String? ??
          'Achievement Unlocked';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🏆 $title',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: kQuizMaroon,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

// ─── Title header ─────────────────────────────────────────────────────────────

class _TitleHeader extends StatelessWidget {
  final String title;
  const _TitleHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: kQuizMaroonDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final QuizResult result;
  const _StatsRow({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Score
          _StatCell(
            label: 'Score',
            value: result.maxScore > 0
                ? '${result.scoreAchieved} / ${result.maxScore}'
                : '${result.scoreAchieved} pts',
            valueColor: kQuizMaroonDark,
          ),

          _VerticalDivider(),

          // Pass / Fail
          _StatCell(
            label: 'Result',
            value: result.isPassed ? 'Passed' : 'Failed',
            valueColor: result.isPassed ? kQuizPassGreen : kQuizFailRed,
            icon: result.isPassed ? Icons.check_circle : Icons.cancel,
          ),

          _VerticalDivider(),

          // XP
          _StatCell(
            label: 'XP Earned',
            value: '+${result.xpEarned}',
            valueColor: kQuizMaroon,
          ),
        ],
      ),
    );
  }
}

// ─── Actions row ──────────────────────────────────────────────────────────────

class _ActionsRow extends StatelessWidget {
  final void Function(int index)? onNavigateToTab;
  final BuildContext context;

  const _ActionsRow({required this.context, this.onNavigateToTab});

  @override
  Widget build(BuildContext _) {
    return Row(
      children: [
        // See Quiz Scores → Home tab (index 0)
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              onNavigateToTab?.call(0);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: kQuizMaroonDark,
              side: const BorderSide(color: kQuizMaroonDark, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(180, 45),
            ),
            child: const Text(
              'See Quiz Scores',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Back to Quizzes → Quizzes tab (index 2)
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              onNavigateToTab?.call(2);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kQuizMaroonDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(180, 45),
            ),
            child: const Text(
              'Back to Quizzes',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Answer review ────────────────────────────────────────────────────────────

class _AnswerReview extends StatelessWidget {
  final List<dynamic> questions;
  final Map<int, int> selectedAnswers;
  final Map<int, bool> correctnessById;

  const _AnswerReview({
    required this.questions,
    required this.selectedAnswers,
    required this.correctnessById,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Answers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: kQuizMaroonDark,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(questions.length, (i) {
          final q = questions[i] as Map<String, dynamic>;
          final questionId = q['question_id'] as int;
          return _ReviewQuestion(
            index: i,
            questionText: q['question_text'] as String? ?? '',
            choices: q['choices'] as List<dynamic>? ?? [],
            selectedIdx: selectedAnswers[questionId] ?? -1,
            wasCorrect: correctnessById[questionId] ?? false,
          );
        }),
      ],
    );
  }
}

// ─── Review question ──────────────────────────────────────────────────────────

class _ReviewQuestion extends StatelessWidget {
  final int index;
  final String questionText;
  final List<dynamic> choices;
  final int selectedIdx;
  final bool wasCorrect;

  const _ReviewQuestion({
    required this.index,
    required this.questionText,
    required this.choices,
    required this.selectedIdx,
    required this.wasCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = wasCorrect ? kQuizPassGreen : kQuizFailRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number + text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}.  ',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kQuizMaroonDark,
                ),
              ),
              Expanded(
                child: Text(
                  questionText,
                  style: const TextStyle(fontSize: 13, color: kQuizMaroonDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Choices
          ...List.generate(choices.length, (i) {
            final isSelected = i == selectedIdx;
            if (!isSelected) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        choices[i] as String? ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: statusColor, width: 1.5),
                    ),
                    child: Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      choices[i] as String? ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    wasCorrect ? Icons.check_circle : Icons.cancel,
                    color: statusColor,
                    size: 16,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

/// A single labeled stat cell used in [_StatsRow].
class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData? icon;

  const _StatCell({
    required this.label,
    required this.value,
    required this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        if (icon != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: valueColor, size: 15),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: valueColor,
                ),
              ),
            ],
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
      ],
    );
  }
}

/// Thin vertical line separator between stat cells.
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 40, width: 1, color: Colors.grey.shade200);
  }
}
