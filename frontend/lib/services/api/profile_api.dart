import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Service class for fetching the authenticated student's profile data.
///
/// The backend's `/students/me` endpoint uses the Bearer token from the request
/// header to identify the student — no student ID is passed in the URL.
/// This is the primary data source for the Dashboard screen.
class ProfileApi {
  // ─── GET PROFILE ────────────────────────────────────────────────────────────

  /// Fetches the complete profile and progress data for the logged-in student.
  ///
  /// Endpoint: `GET /students/me`
  /// Auth required: ✅ Bearer token (automatically included via [ApiConfig.getHeaders])
  ///
  /// Returns: A [Map] with the following top-level structure:
  /// ```json
  /// {
  ///   "info": {
  ///     "student_number", "first_name", "last_name", "middle_name",
  ///     "program", "specialization", "year_level", "email", "img_path"
  ///   },
  ///   "progress": {
  ///     "level", "quiz_points", "updated_at",
  ///     "landmarks": { "total": int, "visited": int },
  ///     "xp": { "total_xp": int, "next_threshold": int, "to_next_level": int }
  ///   }
  /// }
  /// ```
  ///
  /// Throws: [Exception] if the token is missing/expired (401) or if the
  /// student's progress record doesn't exist in the database (unlikely in
  /// normal use since it's created atomically with the account).
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/students/me'),
      // getHeaders() reads the JWT from SharedPreferences and appends it as
      // "Authorization: Bearer <token>". The backend uses this to identify the student.
      headers: await ApiConfig.getHeaders(),
    );

    // Throws a user-readable Exception for any non-2xx response.
    ApiConfig.handleBackendError(response);

    // Decode the JSON string from the response body into a Dart Map.
    return jsonDecode(response.body);
  }
}
