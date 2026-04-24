import 'package:flutter/material.dart';
import '../../services/api/quiz_api.dart';
import '../dashboard_screen.dart';
import 'quiz_taking_screen.dart';
import 'quiz_list_screen.dart';

class QuizDetailScreen extends StatefulWidget {
  final int quizId;

  const QuizDetailScreen({super.key, required this.quizId});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  // ─── BRANDING COLORS ───────────────────────────────────────────────────────
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF4A0F0F);
  static const _headerGrey = Color(0xFFF5F5F5);

  // ─── STATE VARIABLES ───────────────────────────────────────────────────────
  Map<String, dynamic>? _quizData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  // ─── PRIVATE METHODS ───────────────────────────────────────────────────────
  /// Loads the full quiz detail (info + status + questions) from the backend.
  Future<void> _loadQuiz() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await QuizApi.getQuiz(widget.quizId);

      setState(() {
        _quizData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Returns true if this quiz has already been completed by the student.
  bool get _isCompleted => _quizData?['status']?['is_completed'] == true;

  /// Builds the hint text shown under the quiz title.
  String _buildHintText() {
    final info = _quizData!['info'] as Map<String, dynamic>;
    final questions = _quizData!['questions'] as List<dynamic>;
    final minLandmarks = info['min_landmarks'] ?? 0;
    final questionCount = questions.length;

    return 'Requires $minLandmarks landmark visit${minLandmarks == 1 ? '' : 's'} • $questionCount questions';
  }

  void _onTakeQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QuizTakingScreen(quizId: widget.quizId, quizData: _quizData!),
      ),
    );
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

      body: _buildBody(),
    );
  }

  // ─── BODY STATES ───────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _maroon));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: _maroon, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Failed to load quiz',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _maroonDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loadQuiz,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _maroonDark,
                  side: const BorderSide(color: _maroonDark, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final info = _quizData!['info'] as Map<String, dynamic>;
    final String quizName = info['name'] as String? ?? 'Untitled Quiz';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. QUIZ CARD (action button + title + hint)
            _buildQuizCard(quizName),

            const SizedBox(height: 24),

            // 2. REMINDERS / RULES BOX
            _buildRemindersBox(),

            const SizedBox(height: 40),

            // 3. BACK BUTTON
            Column(
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                      (route) => false,
                    );
                  },
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
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizListScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _maroonDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(180, 45),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: const Text(
                    'Back to Quizzes',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ─── QUIZ CARD ─────────────────────────────────────────────────────────────
  Widget _buildQuizCard(String quizName) {
    return Container(
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
          // --- ACTION BUTTON (Take Quiz / Completed) ---
          GestureDetector(
            onTap: _isCompleted ? null : _onTakeQuiz,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: _maroonDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _isCompleted ? 'Completed' : 'Take Quiz',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- QUIZ TITLE ---
          Text(
            quizName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _maroonDark,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),

          // --- HINT ---
          Text(
            _buildHintText(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _maroonDark,
            ),
          ),
        ],
      ),
    );
  }

  // ─── REMINDERS / RULES BOX ─────────────────────────────────────────────────
  /// Renders the bordered box with a dark maroon header and a numbered list of rules.
  /// Rules are hardcoded here since they are not returned by the backend.
  Widget _buildRemindersBox() {
    // TODO: Replace with real rules from backend or a config constant when available
    const List<String> rules = [
      'Answer all questions carefully before submitting. Once submitted, your answers cannot be changed.',
      'Your score will be recorded and displayed on the Quiz Scores screen after completion.',
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _maroonDark, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: _maroonDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: const Text(
              'Reminders/ Rules',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Numbered rules list
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(rules.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Number
                      Text(
                        '${index + 1}. ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _maroonDark,
                        ),
                      ),
                      // Rule text
                      Expanded(
                        child: Text(
                          rules[index],
                          style: const TextStyle(
                            fontSize: 13,
                            color: _maroonDark,
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
