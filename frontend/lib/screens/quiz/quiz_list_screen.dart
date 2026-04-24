import 'package:flutter/material.dart';
import '../../services/api/quiz_api.dart';
import 'quiz_taking_screen.dart';
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

  // ─── STATE VARIABLES ───────────────────────────────────────────────────────
  List<dynamic> _quizzes = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _expandedQuizId;

  final Map<int, bool> _detailLoading = {};
  final Map<int, Map<String, dynamic>> _detailData = {};
  final Map<int, String> _detailErrors = {};

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

  /// Fetches full quiz detail for [quizId] if not already loaded.
  Future<void> _loadDetail(int quizId) async {
    if (_detailData.containsKey(quizId)) return;

    setState(() {
      _detailLoading[quizId] = true;
      _detailErrors.remove(quizId);
    });

    try {
      final data = await QuizApi.getQuiz(quizId);
      setState(() {
        _detailData[quizId] = data;
        _detailLoading[quizId] = false;
      });
    } catch (e) {
      setState(() {
        _detailErrors[quizId] = e.toString();
        _detailLoading[quizId] = false;
      });
    }
  }

  /// Toggles the accordion. Tapping the same card collapses it.
  void _toggleExpand(int quizId) {
    setState(() {
      if (_expandedQuizId == quizId) {
        _expandedQuizId = null;
      } else {
        _expandedQuizId = quizId;
        _loadDetail(quizId);
      }
    });
  }

  /// Maps the backend status fields to a local [QuizState] enum.
  QuizState _resolveState(Map<String, dynamic> status) {
    if (status['is_locked'] == true) return QuizState.locked;
    if (status['is_completed'] == true) return QuizState.completed;
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
    return RefreshIndicator(
      color: _maroon,
      onRefresh: _loadQuizzes,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // RED GRADIENT HEADER
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

            _buildBody(),

            const SizedBox(height: 32),
          ],
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: _quizzes.map((quiz) {
          final info = quiz['info'] as Map<String, dynamic>;
          final status = quiz['status'] as Map<String, dynamic>;
          final state = _resolveState(status);
          final quizId = info['quiz_id'] as int;

          return _buildAccordionCard(
            quizId: quizId,
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

  // ─── ACCORDION CARD ────────────────────────────────────────────────────────
  Widget _buildAccordionCard({
    required int quizId,
    required QuizState state,
    required String title,
    required String hint,
    int? scoreAchieved,
    int? maxScore,
  }) {
    final bool isLocked = state == QuizState.locked;
    final bool isExpanded = _expandedQuizId == quizId;

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
          // ── COLLAPSED HEADER (always visible) ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Inner button / status pill
                GestureDetector(
                  onTap: isLocked ? null : () => _toggleExpand(quizId),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.grey.shade400 : _maroonDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInnerButtonContent(
                            state,
                            scoreAchieved,
                            maxScore,
                          ),
                          if (!isLocked) ...[
                            const SizedBox(width: 8),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Quiz title
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

                // Hint
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

          // ── EXPANDED DETAIL (animated) ──
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedDetail(quizId),
          ),
        ],
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

  // ─── EXPANDED DETAIL PANEL ─────────────────────────────────────────────────
  Widget _buildExpandedDetail(int quizId) {
    final isLoading = _detailLoading[quizId] == true;
    final error = _detailErrors[quizId];
    final data = _detailData[quizId];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Divider to visually separate header from detail
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: Colors.grey.shade200, height: 1),
        ),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(color: _maroon)),
          )
        else if (error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: _maroon, size: 36),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    _detailData.remove(quizId);
                    _loadDetail(quizId);
                  },
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
          )
        else if (data != null)
          _buildDetailContent(quizId, data),
      ],
    );
  }

  Widget _buildDetailContent(int quizId, Map<String, dynamic> data) {
    final bool isCompleted = data['status']?['is_completed'] == true;

    // ─── Rules ────────────────────────────────────────────────────────────────
    const List<String> rules = [
      'Answer all questions carefully before submitting. Once submitted, your answers cannot be changed.',
      'Your score will be recorded and displayed on the Quiz Scores screen after completion.',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── REMINDERS BOX ──
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: _maroonDark, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
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
                    'Reminders / Rules',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Rules list
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(rules.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _maroonDark,
                              ),
                            ),
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
          ),

          const SizedBox(height: 20),

          // ── START QUIZ BUTTON ──
          if (!isCompleted)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        QuizTakingScreen(quizId: quizId, quizData: data),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _maroonDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Start Quiz',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            )
          else
            Container(
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
                    color: _maroonDark,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // ── RETURN TO DASHBOARD ──
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
              foregroundColor: _maroonDark,
              side: const BorderSide(color: _maroonDark, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text(
              'Return to Dashboard',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
