// ─── Quiz state ───────────────────────────────────────────────────────────────

/// Represents the three possible states a quiz can be in for the current user.
enum QuizState {
  /// Requires more landmark visits before it can be attempted.
  locked,

  /// Available to take.
  unlocked,

  /// Already submitted — score is frozen.
  completed,
}

/// Maps a raw `status` map (from the API list endpoint) to [QuizState].
QuizState resolveQuizState(Map<String, dynamic> status) {
  if (status['is_locked'] == true) return QuizState.locked;
  if (status['is_completed'] == true) return QuizState.completed;
  return QuizState.unlocked;
}

/// Builds the hint string shown below a quiz title on the list screen.
///
/// - Locked:    "Visit X more landmark(s) to unlock • N questions"
/// - Unlocked / Completed: "Requires N landmark visit(s) • N questions"
String buildQuizHint(Map<String, dynamic> info, Map<String, dynamic> status) {
  final questionCount = info['question_count'] ?? 0;
  final minLandmarks = info['min_landmarks'] ?? 0;

  if (status['is_locked'] == true) {
    final remaining = status['remaining_landmarks_needed'] ?? minLandmarks;
    return 'Visit $remaining more landmark(s) to unlock • $questionCount questions';
  }

  return 'Requires $minLandmarks landmark visit${minLandmarks == 1 ? '' : 's'} • $questionCount questions';
}

// ─── Quiz result ──────────────────────────────────────────────────────────────

/// Wraps the raw result payload returned by [QuizApi.submitQuiz] and exposes
/// typed getters so views don't scatter `as Map / as int / ?? 0` casts everywhere.
class QuizResult {
  final Map<String, dynamic> _raw;

  const QuizResult(this._raw);

  Map<String, dynamic> get _quiz => _raw['quiz'] as Map<String, dynamic>;
  Map<String, dynamic> get _progress =>
      _raw['progress'] as Map<String, dynamic>;
  Map<String, dynamic> get _performance =>
      _quiz['performance'] as Map<String, dynamic>;
  Map<String, dynamic> get _levelProg =>
      _progress['level'] as Map<String, dynamic>;
  Map<String, dynamic> get _xpProg => _progress['xp'] as Map<String, dynamic>;

  List<dynamic> get newAchievements =>
      _raw['new_achievements'] as List<dynamic>? ?? [];

  List<dynamic> get breakdown => _quiz['breakdown'] as List<dynamic>? ?? [];

  bool get didLevelUp => _levelProg['did_level_up'] == true;
  int get currentLevel => _levelProg['current'] as int? ?? 0;
  int get xpEarned => _xpProg['earned'] as int? ?? 0;
  int get scoreAchieved => _performance['score_achieved'] as int? ?? 0;
  bool get isPassed => _performance['is_passed'] == true;

  int get maxScore =>
      (_quiz['info'] as Map<String, dynamic>?)?['max_score'] as int? ?? 0;

  /// Builds a lookup of `question_id → is_correct` from [breakdown].
  Map<int, bool> get correctnessById {
    return {
      for (final item in breakdown)
        (item as Map<String, dynamic>).let(
          (m) => (m['info'] as Map<String, dynamic>)['question_id'] as int,
        ): ((item)['performance'] as Map<String, dynamic>)['is_correct'] ==
            true,
    };
  }
}

// Dart doesn't ship `.let` — add a tiny extension so [correctnessById] reads cleanly.
extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
