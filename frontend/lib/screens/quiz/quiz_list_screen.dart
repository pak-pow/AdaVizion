import 'package:flutter/material.dart';
import '../../services/api/quiz_api.dart';
import 'models/quiz_model.dart';
import 'quiz_constants.dart';
import 'widgets/quiz_accordion_card.dart';
import 'widgets/shared/quiz_error_state.dart';

// ─── Quiz list screen ─────────────────────────────────────────────────────────

/// Root screen for the Quiz feature.
///
/// Fetches the quiz list via [QuizApi.getQuizzes] and renders each entry as a
/// [QuizAccordionCard]. Pull-to-refresh reloads the full list.
class QuizListScreen extends StatefulWidget {
  /// Optional callback that switches the parent [DashboardScreen] to a given
  /// bottom-nav tab index. Passed down to result and taking screens.
  final void Function(int index)? onNavigateToTab;

  const QuizListScreen({super.key, this.onNavigateToTab});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  // ─── State ──────────────────────────────────────────────────────────────────

  List<dynamic> _quizzes = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _expandedQuizId;

  /// Per-quiz detail loading flags.
  final Map<int, bool> _detailLoading = {};

  /// Per-quiz detail payloads, keyed by quiz_id.
  final Map<int, Map<String, dynamic>> _detailData = {};

  /// Per-quiz detail error messages.
  final Map<int, String> _detailErrors = {};

  // ─── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  // ─── Data ───────────────────────────────────────────────────────────────────

  /// Fetches the quiz list and refreshes the widget tree.
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

  /// Fetches full quiz detail for [quizId] if not already cached.
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

  // ─── Interaction ────────────────────────────────────────────────────────────

  /// Collapses the current card or expands [quizId] and triggers a detail fetch.
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

  /// Clears the cached detail so it is re-fetched on the next expand.
  void _retryDetail(int quizId) {
    setState(() => _detailData.remove(quizId));
    _loadDetail(quizId);
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kQuizMaroon,
      onRefresh: _loadQuizzes,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // ── Gradient header ───────────────────────────────────────────────
            const _QuizHeader(),

            const SizedBox(height: 24),

            // ── Body ──────────────────────────────────────────────────────────
            _buildBody(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Body states ────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: CircularProgressIndicator(color: kQuizMaroon),
      );
    }

    if (_errorMessage != null) {
      return QuizErrorState(message: _errorMessage, onRetry: _loadQuizzes);
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: _quizzes.map((quiz) {
          final info = quiz['info'] as Map<String, dynamic>;
          final status = quiz['status'] as Map<String, dynamic>;
          final state = resolveQuizState(status);
          final quizId = info['quiz_id'] as int;

          return QuizAccordionCard(
            quizId: quizId,
            state: state,
            title: info['name'] as String? ?? 'Untitled Quiz',
            hint: buildQuizHint(info, status),
            scoreAchieved: status['score_achieved'] as int?,
            maxScore: info['max_score'] as int?,
            isExpanded: _expandedQuizId == quizId,
            onToggle: () => _toggleExpand(quizId),
            detailLoading: _detailLoading[quizId] == true,
            detailData: _detailData[quizId],
            detailError: _detailErrors[quizId],
            onRetryDetail: () => _retryDetail(quizId),
            onNavigateToTab: widget.onNavigateToTab,

            onQuizExited: () {
              setState(() {
                _detailData.remove(quizId);
                _expandedQuizId = null;
              });
              _loadQuizzes();
            },
          );
        }).toList(),
      ),
    );
  }
}

// ─── Quiz header ──────────────────────────────────────────────────────────────

/// Gradient banner shown at the top of the quiz list.
class _QuizHeader extends StatelessWidget {
  const _QuizHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.55, 1.0],
          colors: [kQuizGradientTop, kQuizGradientTop, kQuizGradientBottom],
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
    );
  }
}
