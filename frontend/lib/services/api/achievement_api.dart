import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Service class for fetching the student's achievement badge progress.
///
/// Achievements are awarded automatically by the backend — the Flutter app
/// never triggers them directly. They are checked and granted server-side
/// at the end of every [LandmarkApi.visitLandmark] and [QuizApi.submitQuiz] call.
///
/// This service's sole purpose is to retrieve the full achievement list
/// so it can be displayed on the Achievements/Badges screen.
///
/// Achievement categories (defined in the backend schema):
///   - `EXPLORER` — Unlocked by visiting landmarks (threshold = landmark count)
///   - `SCHOLAR`  — Unlocked by accumulating quiz points (threshold = quiz_points)
class AchievementApi {
  // ─── GET ACHIEVEMENTS ───────────────────────────────────────────────────────

  /// Fetches all achievements in the system with the student's earned status.
  ///
  /// Endpoint: `GET /achievements/`
  /// Auth required: ✅ Bearer token
  ///
  /// Returns: A [List] where each item represents one badge:
  /// ```json
  /// {
  ///   "achievement_id": int,
  ///   "title": String,
  ///   "description": String,
  ///   "category": "EXPLORER" | "SCHOLAR",
  ///   "threshold": int,
  ///   "img_path": String?,
  ///   "is_unlocked": bool,    // ← true if this student has earned this badge
  ///   "earned_at": String?    // ← ISO 8601 timestamp, or null if not yet earned
  /// }
  /// ```
  ///
  /// The `is_unlocked` and `earned_at` fields are computed server-side by
  /// joining the `achievements` table with `achievements_earned` for the
  /// logged-in student. The UI only needs to check `is_unlocked` to decide
  /// whether to render a badge as active (full color) or locked (greyed out).
  ///
  /// Note: `img_path` is currently an empty string in the seeded data.
  /// Image support will be added in a future update once the upload system
  /// is implemented on the backend.
  static Future<List<dynamic>> getAchievements() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/achievements'),
      headers: await ApiConfig.getHeaders(),
    );

    // Throws a user-readable Exception for any non-2xx response.
    ApiConfig.handleBackendError(response);

    // Decode the JSON array into a Dart List.
    return jsonDecode(response.body);
  }
}
