import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Service class for all quiz-related backend operations.
///
/// Covers the full quiz lifecycle:
///   1. [getQuizzes]  — List all quizzes with lock/completion status
///   2. [getQuiz]     — Load a single quiz's questions for taking or reviewing
///   3. [submitQuiz]  — Submit answers and receive scoring + XP rewards
///
/// All three endpoints are protected: a valid Bearer token is required.
/// Quiz lock/unlock is determined server-side based on landmark visit count.
class QuizApi {
  // ─── LIST QUIZZES ───────────────────────────────────────────────────────────

  /// Fetches all quizzes with per-student lock and completion status.
  ///
  /// Endpoint: `GET /quizzes/`
  /// Auth required: ✅ Bearer token
  ///
  /// Returns: A [List] where each item has the shape:
  /// ```json
  /// {
  ///   "info": {
  ///     "quiz_id": int, "name": String, "min_landmarks": int,
  ///     "max_score": int, "question_count": int
  ///   },
  ///   "status": {
  ///     "is_locked": bool,
  ///     "remaining_landmarks_needed": int,
  ///     "is_completed": bool,
  ///     "score_achieved": int?,
  ///     "is_passed": bool
  ///   }
  /// }
  /// ```
  ///
  /// Note: `is_locked` is derived by the backend comparing `quiz.min_landmarks`
  /// against the student's actual visited landmark count — not stored in the DB.
  ///
  /// UI note: Access fields via `q['info']['name']` and `q['status']['is_locked']`.
  /// Direct access like `q['name']` will return null (common bug — fields are nested).
  static Future<List<dynamic>> getQuizzes() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/quizzes'),
      headers: await ApiConfig.getHeaders(),
    );

    await ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }

  // ─── GET SINGLE QUIZ ────────────────────────────────────────────────────────

  /// Fetches a single quiz with its full question list.
  ///
  /// Endpoint: `GET /quizzes/:id`
  /// Auth required: ✅ Bearer token
  ///
  /// Parameters:
  ///   [id] — The quiz's database ID (retrieved from [getQuizzes] as `info.quiz_id`).
  ///
  /// Returns: A [Map] with `info`, `status`, and a `questions` list:
  /// ```json
  /// {
  ///   "info": { ... },
  ///   "status": { "is_completed": bool, "score_achieved": int?, ... },
  ///   "questions": [
  ///     {
  ///       "question_id": int, "question_text": String,
  ///       "choices": ["Option A", "Option B", "Option C", "Option D"],
  ///       "item_points": int,
  ///       "your_answer": int?  // Only present if the quiz was already completed
  ///     }
  ///   ]
  /// }
  /// ```
  ///
  /// Important: The `correct_idx` field is intentionally stripped by the backend
  /// before delivery to prevent cheating. It is only stored server-side.
  /// If the quiz was already completed, `your_answer` (the student's previous
  /// choice index) is included so the UI can render a review mode.
  ///
  /// Throws: [Exception] with message "Quiz requires more landmark visits to unlock"
  ///   if the student attempts to access a locked quiz directly.
  static Future<Map<String, dynamic>> getQuiz(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/quizzes/$id'),
      headers: await ApiConfig.getHeaders(),
    );

    await ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }

  // ─── SUBMIT QUIZ ────────────────────────────────────────────────────────────

  /// Submits a completed quiz attempt and returns the graded result with XP rewards.
  ///
  /// Endpoint: `POST /quizzes/:id/submit`
  /// Auth required: ✅ Bearer token
  ///
  /// Parameters:
  ///   [id]      — The quiz's database ID.
  ///   [answers] — A list of answer maps. Each map must have exactly two keys:
  ///               `'question_id'` (int) and `'selected_idx'` (int 0–3).
  ///               This matches the backend's Zod `SubmitQuizSchema` exactly.
  ///
  /// Request body sent:
  /// ```json
  /// { "answers": [{ "question_id": 1, "selected_idx": 2 }, ...] }
  /// ```
  ///
  /// Returns: A [Map] containing:
  /// ```json
  /// {
  ///   "quiz": {
  ///     "performance": { "score_achieved": int, "is_passed": bool, ... },
  ///     "breakdown": [{ "info": {...}, "performance": { "is_correct": bool, ... } }]
  ///   },
  ///   "progress": {
  ///     "xp": { "previous": int, "current": int, "earned": int, ... },
  ///     "level": { "previous": int, "current": int, "did_level_up": bool }
  ///   },
  ///   "new_achievements": [{ "title": String, "description": String, ... }]
  /// }
  /// ```
  ///
  /// Reward triggers to check in the UI after a successful call:
  ///   - `progress['level']['did_level_up'] == true` → show level-up toast
  ///   - `new_achievements.isNotEmpty`              → show achievement badge toast(s)
  ///
  /// Throws: [Exception] if the answer count doesn't match the question count,
  ///   if a question_id is invalid, or if the quiz was already submitted (409).
  static Future<Map<String, dynamic>> submitQuiz(
    int id,
    List<Map<String, int>> answers,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/quizzes/$id/submit'),
      headers: await ApiConfig.getHeaders(),
      // Encode the answers list into the exact JSON body shape the Zod schema expects.
      body: jsonEncode({'answers': answers}),
    );

    await ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }
}
