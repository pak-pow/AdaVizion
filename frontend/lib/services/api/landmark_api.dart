import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Service class for all campus landmark operations.
///
/// Landmarks are physical locations around the MSEUF campus. Students scan
/// QR codes posted at each location to "visit" them, earning XP and unlocking
/// quiz eligibility. This service covers:
///   1. [getChecklist]   — Load all landmarks with visited/unvisited status
///   2. [getLandmark]    — Load one landmark's full details (fun_fact gated by visit)
///   3. [visitLandmark]  — Submit a QR scan to record a visit and earn XP
///
/// All three endpoints require authentication.
class LandmarkApi {
  // ─── GET CHECKLIST ──────────────────────────────────────────────────────────

  /// Fetches every campus landmark with a per-student `is_visited` flag.
  ///
  /// Endpoint: `GET /landmarks/`
  /// Auth required: ✅ Bearer token
  ///
  /// Returns: A [List] where each item has the shape:
  /// ```json
  /// {
  ///   "landmark_id": int,
  ///   "name": String,
  ///   "is_visited": bool
  /// }
  /// ```
  ///
  /// Note: `description`, `fun_fact`, and `qr_string` are intentionally excluded
  /// from this endpoint. Both `description` and `fun_fact` are only revealed after
  /// a successful QR scan. `qr_string` is never sent to the client — it is only
  /// compared server-side.
  static Future<List<dynamic>> getChecklist() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/landmarks'),
      headers: await ApiConfig.getHeaders(),
    );

    ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }

  // ─── GET SINGLE LANDMARK ────────────────────────────────────────────────────

  /// Fetches the full details for a single landmark.
  ///
  /// Endpoint: `GET /landmarks/:id`
  /// Auth required: ✅ Bearer token
  ///
  /// Parameters:
  ///   [id] — The landmark's database ID (retrieved from [getChecklist]).
  ///
  /// Returns: A [Map] with the landmark's full details (including `description`
  /// and `fun_fact`) if the student has already visited this landmark:
  /// ```json
  /// {
  ///   "landmark_id": int,
  ///   "name": String,
  ///   "description": String,
  ///   "fun_fact": String,
  ///   "img_path": String?,
  ///   "is_unlocked": true
  /// }
  /// ```
  ///
  /// Throws: [Exception] with "Scan landmark QR first" (423 Locked) if the
  ///   student has not yet scanned this landmark's QR code. The caller should
  ///   catch this to show a locked/discovery UI state rather than the detail view.
  ///
  /// Access control is enforced entirely server-side — the client cannot bypass it.
  static Future<Map<String, dynamic>> getLandmark(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/landmarks/$id'),
      headers: await ApiConfig.getHeaders(),
    );

    ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }

  // ─── VISIT LANDMARK (QR SCAN) ───────────────────────────────────────────────

  /// Records a QR code scan visit for the logged-in student at a specific landmark.
  ///
  /// Endpoint: `POST /landmarks/visit`
  /// Auth required: ✅ Bearer token
  ///
  /// Parameters:
  ///   [qrCode] — The raw string value decoded from the QR code scan.
  ///              The backend looks up the landmark by this value and compares it
  ///              against `landmark.qr_string` in the database.
  ///
  /// Request body sent: `{ "qr_code_scanned": "<qrCode>" }`
  ///
  /// Returns: A [Map] containing:
  /// ```json
  /// {
  ///   "message": "Scan and visit successful",
  ///   "landmark": { "name", "description", "fun_fact", "img_path", "visited_at" },
  ///   "progress": {
  ///     "xp": { "previous", "current", "earned", "next_threshold", "to_next_level" },
  ///     "level": { "previous", "current", "did_level_up" }
  ///   },
  ///   "new_achievements": [{ "title", "description", ... }]
  /// }
  /// ```
  ///
  /// Reward triggers to check in the UI after a successful call:
  ///   - `progress['level']['did_level_up'] == true` → show level-up toast
  ///   - `new_achievements.isNotEmpty`              → show achievement badge toast(s)
  ///   - `result['landmark']['fun_fact']`           → display the unlocked fun fact
  ///
  /// Throws:
  ///   - [Exception] with "Landmark not found" (404) if the scanned QR string
  ///     does not match any landmark in the database.
  ///   - [Exception] with "Invalid landmark QR code" (403) if the QR string is
  ///     found but does not match the landmark's stored `qr_string`.
  ///   - [Exception] with "Landmark already visited" (409) if the student has
  ///     already scanned this landmark before.
  static Future<Map<String, dynamic>> visitLandmark(String qrCode) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/landmarks/visit'),
      headers: await ApiConfig.getHeaders(),
      body: jsonEncode({'qr_code_scanned': qrCode}),
    );

    ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }
}
