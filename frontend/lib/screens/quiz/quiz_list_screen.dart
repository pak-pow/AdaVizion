import 'package:flutter/material.dart';
import '../../services/api/quiz_api.dart';
import 'quiz_detail_screen.dart';
import '../dashboard_screen.dart';

enum QuizState { locked, unlocked, completed }

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  // ─── BRANDING COLORS ───────────────────────────────────────────────────────
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF4A0F0F);
  static const _gradientTop = Color(0xFFA62121);
  static const _headerGrey = Color(0xFFF5F5F5);

  // ─── STATE VARIABLES ───────────────────────────────────────────────────────
  List<dynamic> _quizzes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  // ─── PRIVATE METHODS ───────────────────────────────────────────────────────
  /// Loads the quiz list from the backend and updates the state.
  /// Handles loading and error states appropriately.
  Future<void> _loadQuizzes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final quizzes = await QuizApi.getQuizzes();

      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Maps the backend status fields to a local [QuizState] enum.
  QuizState _resolveState(Map<String, dynamic> status) {
    if (status['is_locked'] == true) {
      return QuizState.locked;
    } else if (status['is_completed'] == true) {
      return QuizState.completed;
    }
    return QuizState.unlocked;
  }

  /// Builds the hint text shown below the quiz title.
  /// - Locked:    "Visit X more landmark(s) to unlock • N questions"
  /// - Unlocked:  "Requires N landmark visits • N questions"
  /// - Completed: "Requires N landmark visits • N questions"
  String _buildHintText(
    Map<String, dynamic> info,
    Map<String, dynamic> status,
  ) {
    final questionCount = info['question_count'] ?? 0;
    final minLandmarks = info['min_landmarks'] ?? 0;

    if (status['is_locked'] == true) {
      final remaining = status['remaining_landmarks_needed'] ?? minLandmarks;
      return 'Visit $remaining more landmark(s) to unlock • $questionCount questions';
    }

    return 'Requires $minLandmarks landmark visit${minLandmarks == 1 ? '' : 's'} • $questionCount questions';
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

      body: RefreshIndicator(
        color: _maroon,
        onRefresh: _loadQuizzes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 1. RED GRADIENT HEADER
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. QUIZ CARDS - loading / error/ list
              _buildBody(),

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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _maroon,
                ),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // ─── BODY STATES ───────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: CircularProgressIndicator(color: _maroon),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: _maroon, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Failed to load quizzes',
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
              onPressed: _loadQuizzes,
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
      );
    }

    if (_quizzes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Text(
          'No quizzes available.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    // Render one card per quiz from the API
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: _quizzes.map((quiz) {
          final info = quiz['info'] as Map<String, dynamic>;
          final status = quiz['status'] as Map<String, dynamic>;
          final state = _resolveState(status);

          return _buildQuizCard(
            quizId: info['quiz_id'] as int,
            state: state,
            title: info['name'] as String? ?? 'Untitled Quiz',
            hint: _buildHintText(info, status),
            scoreAchieved: status['score_achieved'] as int?,
            maxScore: info['max_score'] as int?,
          );
        }).toList(),
      ),
    );
  }

  // ─── QUIZ CARD BUILDER ────────────────────────────────────────────────────
  Widget _buildQuizCard({
    required int quizId,
    required QuizState state,
    required String title,
    required String hint,
    int? scoreAchieved,
    int? maxScore,
  }) {
    final bool isLocked = state == QuizState.locked;

    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizDetailScreen(quizId: quizId),
                ),
              );
            },
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
            // --- INNER BUTTON ---
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: isLocked ? Colors.grey.shade400 : _maroonDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: _buildInnerButtonContent(state, scoreAchieved, maxScore),
              ),
            ),

            const SizedBox(height: 16),

            // --- TITLE ---
            Text(
              title,
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
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _maroonDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInnerButtonContent(
    QuizState state,
    int? scoreAchieved,
    int? maxScore,
  ) {
    switch (state) {
      case QuizState.locked:
        return const Icon(Icons.lock_outline, color: Colors.white, size: 32);

      case QuizState.completed:
        // Show "score/maxScore" if available, otherwise just "Completed"
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
