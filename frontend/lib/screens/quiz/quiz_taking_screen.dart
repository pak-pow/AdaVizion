import 'package:flutter/material.dart';
import '../../services/api/quiz_api.dart';
import 'quiz_result_screen.dart';

class QuizTakingScreen extends StatefulWidget {
  final int quizId;
  final Map<String, dynamic> quizData;
  final void Function(int index)? onNavigateToTab;

  const QuizTakingScreen({
    super.key,
    required this.quizId,
    required this.quizData,
    this.onNavigateToTab,
  });

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  // ─── BRANDING COLORS ───────────────────────────────────────────────────────
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF4A0F0F);
  static const _headerGrey = Color(0xFFF5F5F5);

  // ─── STATE VARIABLES ───────────────────────────────────────────────────────
  /// Maps question_id → selected choice index (0-based).
  final Map<int, int> _selectedAnswers = {};

  bool _isSubmitting = false;
  String? _errorMessage;

  // ─── GETTERS ───────────────────────────────────────────────────────────────
  //List<dynamic> get _questions => widget.quizData['questions'] as List<dynamic>; // uncomment when fixed

  // temp solution
  // TODO: find a fix for this bc smth is fucking it up
  /// Sorted by question_id — guarantees display order regardless of cache/server ordering.
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

  // ─── PRIVATE METHODS ───────────────────────────────────────────────────────

  /// Handles when a user selects a choice for a question.
  void _onChoiceSelected(int questionId, int choiceIndex) {
    setState(() {
      _selectedAnswers[questionId] = choiceIndex;
    });
  }

  /// Builds the answers payload expected by [QuizApi.submitQuiz].
  List<Map<String, int>> _buildAnswersPayload() {
    return _selectedAnswers.entries
        .map((e) => {'question_id': e.key, 'selected_idx': e.value})
        .toList();
  }

  /// Submits the quiz answers to the backend and handles the response.
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
      final result = await QuizApi.submitQuiz(
        widget.quizId,
        _buildAnswersPayload(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            quizName: _quizName,
            result: result,
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

  // ─── BUILD METHOD ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
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
                // 1. QUIZ TITLE HEADER
                _buildTitleHeader(),

                const SizedBox(height: 24),

                // 2. QUESTIONS LIST
                ..._buildQuestionList(),

                // 3. ERROR MESSAGE (unanswered / submit failure)
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _maroon,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // 4. SUBMIT BUTTON
                _buildSubmitSection(),

                const SizedBox(height: 8),
              ],
            ),
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
        _quizName,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ─── QUESTIONS LIST ────────────────────────────────────────────────────────
  List<Widget> _buildQuestionList() {
    return List.generate(_questions.length, (index) {
      final question = _questions[index] as Map<String, dynamic>;
      final int questionId = question['question_id'] as int;
      final String questionText = question['question_text'] as String? ?? '';
      final List<dynamic> choices = question['choices'] as List<dynamic>? ?? [];
      final int? selectedIdx = _selectedAnswers[questionId];

      return Padding(
        padding: const EdgeInsets.only(bottom: 32),
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
                    fontWeight: FontWeight.w600,
                    color: _maroonDark,
                  ),
                ),
                Expanded(
                  child: Text(
                    questionText,
                    style: const TextStyle(fontSize: 13, color: _maroonDark),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Choices
            ...List.generate(choices.length, (choiceIndex) {
              final String choiceText = choices[choiceIndex] as String? ?? '';
              final bool isSelected = selectedIdx == choiceIndex;

              return GestureDetector(
                onTap: () => _onChoiceSelected(questionId, choiceIndex),
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
                          border: Border.all(color: _maroon, width: 1.5),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _maroon,
                                  ),
                                ),
                              )
                            : null,
                      ),

                      // Choice text
                      Expanded(
                        child: Text(
                          choiceText,
                          style: TextStyle(fontSize: 13, color: _maroonDark),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  // ─── SUBMIT SECTION ────────────────────────────────────────────────────────
  Widget _buildSubmitSection() {
    return Column(
      children: [
        const Text(
          'Click submit to Complete',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _maroonDark,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: _isSubmitting
              ? const CircularProgressIndicator(color: _maroon)
              : OutlinedButton(
                  onPressed: _onSubmit,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _maroonDark,
                    side: const BorderSide(color: _maroonDark, width: 1.5),
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
        ),
      ],
    );
  }
}
