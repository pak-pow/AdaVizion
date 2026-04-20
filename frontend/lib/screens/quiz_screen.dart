import 'package:flutter/material.dart';
import '../services/api/quiz_api.dart';

// ============================================================================
// QUIZ LIST SCREEN
// ============================================================================

enum QuizState { locked, unlocked, completed }

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // --- BRAND COLORS ---
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF4A0F0F);
  static const _gradientTop = Color(0xFFA62121);
  static const _headerGrey = Color(0xFFF5F5F5);

  bool _isLoading = true;
  List<Map<String, dynamic>> _quizzes = [];

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    try {
      final data = await QuizApi.getQuizzes();
      if (mounted) {
        setState(() {
          // ✅ FIXED: Use correct nested keys from the backend response shape:
          //   { info: { quiz_id, name, ... }, status: { is_locked, is_completed, ... } }
          _quizzes = data.map<Map<String, dynamic>>((q) {
            final info = q['info'] as Map<String, dynamic>;
            final status = q['status'] as Map<String, dynamic>;

            QuizState state = QuizState.locked;
            if (status['is_locked'] != true) {
              state = status['is_completed'] == true
                  ? QuizState.completed
                  : QuizState.unlocked;
            }

            return {
              'quiz_id': info['quiz_id'] as int,
              'name': info['name'] ?? 'Quiz',
              'min_landmarks': info['min_landmarks'] ?? 0,
              'max_score': info['max_score'] ?? 0,
              'question_count': info['question_count'] ?? 0,
              'state': state,
              'remaining_needed': status['remaining_landmarks_needed'] ?? 0,
              'score_achieved': status['score_achieved'],
              'is_passed': status['is_passed'] ?? false,
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openQuiz(Map<String, dynamic> quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizDetailScreen(
          quizId: quiz['quiz_id'] as int,
          quizName: quiz['name'] as String,
        ),
      ),
    ).then((_) {
      // Refresh the list when returning so completion status updates
      _fetchQuizzes();
    });
  }

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
        title: Image.asset('assets/images/nav_logo.png', height: 42),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _maroon))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 1. THE RED HEADER BOX
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_gradientTop, _maroon],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Quiz',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'answer and earn points',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. DYNAMIC QUIZ CARDS LIST
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: _quizzes
                          .map((quizData) => _buildQuizCard(quizData))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 3. FOOTER
                  const Text(
                    'Go back',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: _maroon,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'to unlock quizzes and explore\nEnverga University',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _maroon,
                    ),
                  ),
                  const SizedBox(height: 16),

                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _maroonDark,
                      side: const BorderSide(color: _maroonDark, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(180, 45),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text(
                      'Return to Dashboard',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }

  // ==========================================
  // QUIZ CARD COMPONENT
  // ==========================================
  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    final QuizState state = quiz['state'];
    final int remaining = quiz['remaining_needed'] as int;
    final int? score = quiz['score_achieved'] as int?;
    final bool isPassed = quiz['is_passed'] as bool;

    // Hint text depends on state
    String hintText;
    if (state == QuizState.locked) {
      hintText = 'Scan $remaining more landmark${remaining != 1 ? 's' : ''} to unlock';
    } else if (state == QuizState.completed) {
      hintText = isPassed
          ? 'Passed! Score: $score pts'
          : 'Attempted. Score: $score pts';
    } else {
      hintText = 'Requires ${quiz['min_landmarks']} landmark visit(s) • ${quiz['question_count']} questions';
    }

    return GestureDetector(
      onTap: state == QuizState.locked ? null : () => _openQuiz(quiz),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
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
            // --- THE INNER DYNAMIC BUTTON ---
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: state == QuizState.locked
                    ? Colors.grey.shade400
                    : state == QuizState.completed
                        ? Colors.green.shade700
                        : _maroonDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: _buildInnerButtonContent(state)),
            ),

            const SizedBox(height: 16),

            // --- THE TEXT BLOCK ---
            Text(
              quiz['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: _maroonDark,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hintText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: state == QuizState.completed
                    ? Colors.green.shade700
                    : _maroonDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInnerButtonContent(QuizState state) {
    if (state == QuizState.locked) {
      return const Icon(Icons.lock_outline, color: Colors.white, size: 32);
    }
    if (state == QuizState.completed) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Text(
            'Completed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
    }
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

// ============================================================================
// QUIZ DETAIL / TAKING SCREEN
// ============================================================================

class QuizDetailScreen extends StatefulWidget {
  final int quizId;
  final String quizName;

  const QuizDetailScreen({
    super.key,
    required this.quizId,
    required this.quizName,
  });

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  // --- BRAND COLORS ---
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF4A0F0F);
  static const _gradientTop = Color(0xFFA62121);
  static const _headerGrey = Color(0xFFF5F5F5);

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isCompleted = false;

  Map<String, dynamic> _quizData = {};
  List<dynamic> _questions = [];

  // Maps question_id → selected_idx (0–3) for unanswered quizzes
  final Map<int, int> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final data = await QuizApi.getQuiz(widget.quizId);
      if (mounted) {
        setState(() {
          _quizData = data;
          _questions = data['questions'] as List<dynamic>? ?? [];
          _isCompleted = data['status']['is_completed'] == true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Returns true only if every question has been answered
  bool get _allAnswered =>
      _questions.every((q) => _selectedAnswers.containsKey(q['question_id'] as int));

  Future<void> _submitQuiz() async {
    if (!_allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before submitting.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Build the exact body shape the Zod schema expects:
      // { "answers": [{ "question_id": int, "selected_idx": int }] }
      final answers = _selectedAnswers.entries
          .map((e) => {'question_id': e.key, 'selected_idx': e.value})
          .toList();

      final result = await QuizApi.submitQuiz(widget.quizId, answers);

      if (!mounted) return;

      final performance = result['quiz']['performance'];
      final progress = result['progress'];
      final List newAchievements = result['new_achievements'] ?? [];

      final bool isPassed = performance['is_passed'] == true;
      final int score = performance['score_achieved'] ?? 0;
      final bool didLevelUp = progress['level']['did_level_up'] == true;
      final int newLevel = progress['level']['current'] ?? 0;

      setState(() => _isCompleted = true);

      // ─── REWARD TRIGGERS ─────────────────────────────────────────────────────

      // 1. Show quiz result snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPassed
                ? '🎉 Passed! You scored $score points.'
                : 'Quiz complete. Score: $score pts. Keep exploring to retry!',
          ),
          backgroundColor: isPassed ? Colors.green.shade700 : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );

      // 2. Level-up notification
      if (didLevelUp) {
        await Future.delayed(const Duration(milliseconds: 3200));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⭐ LEVEL UP! You are now Level $newLevel!'),
              backgroundColor: Colors.amber.shade700,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }

      // 3. Achievement notifications (one per badge, staggered)
      for (int i = 0; i < newAchievements.length; i++) {
        final badge = newAchievements[i];
        await Future.delayed(const Duration(milliseconds: 4500));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🏅 Achievement Unlocked: "${badge['title']}"'),
              backgroundColor: Colors.deepPurple,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }

      // Reload to show review mode (answers with your_answer highlighted)
      _loadQuiz();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _quizData['status'] as Map<String, dynamic>?;
    final int? scoreAchieved = status?['score_achieved'] as int?;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        backgroundColor: _headerGrey,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/images/nav_logo.png', height: 42),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _maroon, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _maroon))
          : Column(
              children: [
                // --- HERO HEADER ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_gradientTop, _maroon],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.quizName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isCompleted
                            ? 'Your score: $scoreAchieved pts — Review your answers below'
                            : '${_questions.length} question${_questions.length != 1 ? 's' : ''} · Answer all to submit',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- QUESTIONS ---
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) =>
                        _buildQuestionCard(index, _questions[index]),
                  ),
                ),

                // --- SUBMIT BUTTON (only for unanswered quizzes) ---
                if (!_isCompleted)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _maroonDark,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Submit Quiz',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  // ==========================================
  // QUESTION CARD BUILDER
  // ==========================================
  Widget _buildQuestionCard(int index, Map<String, dynamic> question) {
    final int questionId = question['question_id'] as int;
    final String questionText = question['question_text'] ?? '';
    final List<dynamic> choices = question['choices'] as List<dynamic>? ?? [];
    final int itemPoints = question['item_points'] as int? ?? 10;

    // In review mode (completed quiz), the backend sends `your_answer`
    final int? yourAnswer = question['your_answer'] as int?;
    final int? selected = _isCompleted ? yourAnswer : _selectedAnswers[questionId];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number + points
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${index + 1}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _maroon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$itemPoints pts',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _maroon,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Question text
          Text(
            questionText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          // Choices
          ...choices.asMap().entries.map((entry) {
            final int idx = entry.key;
            final String choiceText = entry.value.toString();
            final bool isSelected = selected == idx;

            return GestureDetector(
              onTap: _isCompleted
                  ? null
                  : () => setState(() => _selectedAnswers[questionId] = idx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (_isCompleted
                          ? Colors.green.shade50
                          : _maroon.withValues(alpha: 0.08))
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? (_isCompleted ? Colors.green.shade400 : _maroon)
                        : Colors.grey.shade200,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    // Circle indicator
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? (_isCompleted ? Colors.green.shade600 : _maroon)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? (_isCompleted ? Colors.green.shade600 : _maroon)
                              : Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        choiceText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? (_isCompleted ? Colors.green.shade800 : _maroonDark)
                              : const Color(0xFF374151),
                        ),
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
  }
}

