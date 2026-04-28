import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../services/api/quiz_api.dart';
import '../models/quiz_model.dart';
import 'package:adavizion/theme/app_colors.dart';
import 'quiz_result_view.dart';

// ─── Quiz taking view ─────────────────────────────────────────────────────────

/// Full-screen quiz session. Presents all questions and handles submission.
///
/// On success, replaces itself with [QuizResultView].
class QuizTakingView extends StatefulWidget {
  final int quizId;
  final Map<String, dynamic> quizData;
  final void Function(int index)? onNavigateToTab;

  const QuizTakingView({
    super.key,
    required this.quizId,
    required this.quizData,
    this.onNavigateToTab,
  });

  @override
  State<QuizTakingView> createState() => _QuizTakingViewState();
}

class _QuizTakingViewState extends State<QuizTakingView> {
  // ─── State ──────────────────────────────────────────────────────────────────

  /// Maps `question_id` → selected choice index (0-based).
  final Map<int, int> _selectedAnswers = {};

  bool _isSubmitting = false;
  String? _errorMessage;

  // ─── Getters ────────────────────────────────────────────────────────────────

  /// Questions sorted by `question_id` to guarantee stable display order.
  List<dynamic> get _questions {
    final list = List<dynamic>.from(
      widget.quizData['questions'] as List<dynamic>,
    );
    list.sort(
      (a, b) => (a['question_id'] as int).compareTo(b['question_id'] as int),
    );
    return list;
  }

  String get _quizName =>
      (widget.quizData['info'] as Map<String, dynamic>)['name'] as String? ??
      'Untitled Quiz';

  bool get _allAnswered => _questions.every(
    (q) => _selectedAnswers.containsKey(q['question_id'] as int),
  );

  // ─── Interaction ────────────────────────────────────────────────────────────

  void _onChoiceSelected(int questionId, int choiceIndex) {
    setState(() => _selectedAnswers[questionId] = choiceIndex);
  }

  List<Map<String, int>> _buildAnswersPayload() {
    return _selectedAnswers.entries
        .map((e) => {'question_id': e.key, 'selected_idx': e.value})
        .toList();
  }

  Future<void> _onSubmit() async {
    if (!_allAnswered) {
      setState(() {
        _errorMessage = 'Please answer all questions before submitting.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final raw = await QuizApi.submitQuiz(
        widget.quizId,
        _buildAnswersPayload(),
      );
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultView(
            quizName: _quizName,
            result: QuizResult(raw),
            questions: _questions,
            selectedAnswers: Map.unmodifiable(_selectedAnswers),
            onNavigateToTab: widget.onNavigateToTab,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isSubmitting = false;
      });
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,

      // ── APP BAR ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Image.asset('assets/images/nav_logo.png', height: 40),
        flexibleSpace: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -25,
              right: 14,
              child: Transform.rotate(
                angle: math.pi,
                child: Opacity(
                  opacity: 0.9,
                  child: Image.asset('assets/images/logo.png', height: 60),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Title header ─────────────────────────────────────────────
                _QuizTitleHeader(title: _quizName),

                const SizedBox(height: 24),

                // ── Question list ────────────────────────────────────────────
                ..._buildQuestionList(),

                // ── Validation error ─────────────────────────────────────────
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.maroon,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // ── Submit ───────────────────────────────────────────────────
                _SubmitSection(
                  isSubmitting: _isSubmitting,
                  onSubmit: _onSubmit,
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Question list ───────────────────────────────────────────────────────────

  List<Widget> _buildQuestionList() {
    return List.generate(_questions.length, (index) {
      final q = _questions[index] as Map<String, dynamic>;
      final questionId = q['question_id'] as int;
      final text = q['question_text'] as String? ?? '';
      final choices = q['choices'] as List<dynamic>? ?? [];
      final selected = _selectedAnswers[questionId];

      return Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: _QuestionItem(
          index: index,
          text: text,
          choices: choices,
          selectedIdx: selected,
          onSelect: (i) => _onChoiceSelected(questionId, i),
        ),
      );
    });
  }
}

// ─── Quiz title header ────────────────────────────────────────────────────────

class _QuizTitleHeader extends StatelessWidget {
  final String title;
  const _QuizTitleHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.maroonGradientBottom,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ─── Question item ────────────────────────────────────────────────────────────

/// A single question with its choices rendered as custom radio buttons.
class _QuestionItem extends StatelessWidget {
  final int index;
  final String text;
  final List<dynamic> choices;
  final int? selectedIdx;
  final void Function(int choiceIndex) onSelect;

  const _QuestionItem({
    required this.index,
    required this.text,
    required this.choices,
    required this.onSelect,
    this.selectedIdx,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                fontWeight: FontWeight.w600,
                color: AppColors.maroonGradientBottom,
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.maroonGradientBottom,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Choices
        ...List.generate(choices.length, (i) {
          final isSelected = selectedIdx == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Radio circle
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.maroon, width: 1.5),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.maroon,
                              ),
                            ),
                          )
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      choices[i] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.maroonGradientBottom,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Submit section ───────────────────────────────────────────────────────────

class _SubmitSection extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _SubmitSection({required this.isSubmitting, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isSubmitting
          ? const CircularProgressIndicator(color: AppColors.maroon)
          : OutlinedButton(
              onPressed: onSubmit,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.maroonGradientBottom,
                side: const BorderSide(
                  color: AppColors.maroonGradientBottom,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(180, 45),
                padding: const EdgeInsets.symmetric(horizontal: 32),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ),
    );
  }
}
