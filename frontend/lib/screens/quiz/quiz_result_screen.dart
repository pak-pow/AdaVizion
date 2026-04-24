import 'quiz_list_screen.dart';
import 'package:flutter/material.dart';
import '../dashboard_screen.dart'; // For QuizScoresPlaceholder

class QuizResultScreen extends StatelessWidget {
  final String quizName;
  final Map<String, dynamic> result;

  const QuizResultScreen({
    super.key,
    required this.quizName,
    required this.result,
  });

  // ─── BRANDING COLORS ───────────────────────────────────────────────────────
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF4A0F0F);
  static const _headerGrey = Color(0xFFF5F5F5);
  static const _failAndWrongRed = Color(0xFFC62828);
  static const _passAndCorrectGreen = Color(0xFF2E7D32);
  static const _dividerGrey = Color(0xFFDDDDDD);

  // ─── GETTERS ───────────────────────────────────────────────────────────────
  Map<String, dynamic> get _quizMap => result['quiz'] as Map<String, dynamic>;

  Map<String, dynamic> get _performance =>
      _quizMap['performance'] as Map<String, dynamic>;

  Map<String, dynamic> get _levelProgress =>
      (result['progress'] as Map<String, dynamic>)['level']
          as Map<String, dynamic>;

  Map<String, dynamic> get _xpProgress =>
      (result['progress'] as Map<String, dynamic>)['xp']
          as Map<String, dynamic>;

  List<dynamic> get _newAchievements =>
      result['new_achievements'] as List<dynamic>? ?? [];

  List<dynamic> get _breakdown => _quizMap['breakdown'] as List<dynamic>? ?? [];

  bool get _didLevelUp => _levelProgress['did_level_up'] == true;
  int get _xpEarned => _xpProgress['earned'] as int? ?? 0;
  int get _scoreAchieved => _performance['score_achieved'] as int? ?? 0;
  bool get _isPassed => _performance['is_passed'] == true;

  int get _maxScore =>
      (_quizMap['info'] as Map<String, dynamic>?)?['max_score'] as int? ?? 0;

  // ─── BUILD METHOD ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // TODO: REMOVE ONCE DEDICATED TOASTS ARE IMPLEMENTED - This is just a temporary way to show rewards until we have a proper notification system in place.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRewardToasts(context);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: _headerGrey,
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
              // 1. QUIZ TITLE
              _buildTitleHeader(),

              const SizedBox(height: 20),

              // 2. STATS ROW (SCORE | PASS/FAIL | XP EARNED)
              _buildStatsRow(),

              const SizedBox(height: 16),

              // 3. ACTION BUTTONS ROW
              _buildActionsRow(context),

              const SizedBox(height: 24),

              // 4. DIVIDER
              const Divider(thickness: 1.5, color: _dividerGrey),

              const SizedBox(height: 16),

              // 5. ANSWER REVIEW
              _buildAnswerReview(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─── TITLE HEADER ──────────────────────────────────────────────────────────
  Widget _buildTitleHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _maroonDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        quizName,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ─── STATS ROW ───────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
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
          // SCORE
          _StatCell(
            label: 'Score',
            value: _maxScore > 0
                ? '$_scoreAchieved / $_maxScore'
                : '$_scoreAchieved pts',
            valueColor: _maroonDark,
          ),

          _VerticalDivider(),

          // PASS/FAIL
          _StatCell(
            label: 'Result',
            value: _isPassed ? 'Passed' : 'Failed',
            valueColor: _isPassed ? _passAndCorrectGreen : _failAndWrongRed,
            icon: _isPassed ? Icons.check_circle : Icons.cancel,
          ),

          _VerticalDivider(),

          // XP EARNED
          _StatCell(
            label: 'XP Earned',
            value: '+$_xpEarned',
            valueColor: _maroon,
          ),
        ],
      ),
    );
  }

  // ─── ACTIONS ROW ─────────────────────────────────────────────────────────
  Widget _buildActionsRow(BuildContext context) {
    return Row(
      children: [
        // Go to Quiz Scores
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuizScoresPlaceholder()),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _maroonDark,
              side: const BorderSide(color: _maroonDark, width: 1.5),
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

        // Back to Quizzes
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const QuizListScreen()),
              (route) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _maroonDark,
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

  // ─── ANSWER REVIEW ───────────────────────────────────────────────────────────────────────────
  Widget _buildAnswerReview() {
    if (_breakdown.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Answers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: _maroonDark,
          ),
        ),
        const SizedBox(height: 16),

        ...List.generate(_breakdown.length, (index) {
          final info =
              (_breakdown[index] as Map<String, dynamic>)['info']
                  as Map<String, dynamic>;
          return _buildReviewQuestion(index, info);
        }),
      ],
    );
  }

  Widget _buildReviewQuestion(int index, Map<String, dynamic> info) {
    final String questionText = info['question_text'] as String? ?? '';
    final List<dynamic> choices = info['choices'] as List<dynamic>? ?? [];
    final int correctIdx = info['correct_idx'] as int? ?? -1;
    final int selectedIdx = info['selected_idx'] as int? ?? -1;
    final bool wasCorrect = selectedIdx == correctIdx;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: wasCorrect
              ? _passAndCorrectGreen.withValues(alpha: 0.35)
              : _failAndWrongRed.withValues(alpha: 0.35),
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
          // Question number + text + correct/wrong badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}.  ',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _maroonDark,
                ),
              ),
              Expanded(
                child: Text(
                  questionText,
                  style: const TextStyle(fontSize: 13, color: _maroonDark),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                wasCorrect ? Icons.check_circle : Icons.cancel,
                color: wasCorrect ? _passAndCorrectGreen : _failAndWrongRed,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Choices
          ...List.generate(choices.length, (choiceIndex) {
            final String choiceText = choices[choiceIndex] as String? ?? '';
            final bool isSelected = choiceIndex == selectedIdx;

            if (!isSelected) {
              // Unselected choice - show as plain text with empty circle
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Empty circle
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
                    // Choice text
                    Expanded(
                      child: Text(
                        choiceText,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Selected choice - show with status (correct or wrong)
              final bool wasCorrect = selectedIdx == correctIdx;
              final Color statusColor = wasCorrect
                  ? _passAndCorrectGreen
                  : _failAndWrongRed;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Filled circle
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
                    // Choice text
                    Expanded(
                      child: Text(
                        choiceText,
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Status icon (checkmark or X)
                    Icon(
                      wasCorrect ? Icons.check_circle : Icons.cancel,
                      color: statusColor,
                      size: 16,
                    ),
                  ],
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  /// TODO: Remove once dedicated toast notifications are implemented in the app.
  // ─── REWARD TOASTS ─────────────────────────────────────────────────────────
  /// Shows level-up and achievement snackbars based on the result payload.
  /// Called via [WidgetsBinding.addPostFrameCallback] so the screen is
  /// fully rendered before snackbars appear.
  void _showRewardToasts(BuildContext context) {
    if (_didLevelUp) {
      final int newLevel = _levelProgress['current'] as int? ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Level Up! You are now Level $newLevel!',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: _maroonDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    for (final achievement in _newAchievements) {
      final title =
          (achievement as Map<String, dynamic>)['title'] as String? ??
          'Achievement Unlocked';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🏆 $title',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: _maroon,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

// ─── SMALL REUSABLE WIDGETS ────────────────────────────────────────────────

/// A single labeled stat cell used in the stats row
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        if (icon != null) ...[
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
          ),
        ] else
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

/// A thin vertical separator for the stats row
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 40, width: 1, color: Colors.grey.shade200);
  }
}
