import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'api_config.dart';

/// Service class for fetching and updating the authenticated student's profile.
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

  // ─── UPLOAD PROFILE PICTURE ─────────────────────────────────────────────────

  /// Uploads a new profile picture for the authenticated student to Supabase
  /// via the backend's Multer-powered pipeline.
  ///
  /// Endpoint: `PATCH /students/me/picture/upload`
  /// Auth required: ✅ Bearer token (injected via [ApiConfig.getHeaders])
  /// Multer field name: `picture-file` (as declared in `students.route.ts`)
  ///
  /// Constraints enforced by the backend Multer middleware:
  ///   - Max file size: 50 MB (Supabase free-tier limit)
  ///   - Allowed MIME types: `image/*` only
  ///
  /// On success the backend returns a JSON body:
  /// ```json
  /// { "student_number": "A25-XXXXX", "img_path": "https://...supabase..." }
  /// ```
  /// The caller should re-fetch the profile via [getProfile] to pull the
  /// updated `img_path` into the UI.
  ///
  /// Throws: [Exception] with the clearest available error text:
  ///   - If the body is valid JSON containing a `message` key, that string.
  ///   - If the body is not parseable JSON (e.g., an HTML 500 page from a
  ///     network proxy or a CORS failure string), the raw [response.body] is
  ///     thrown so the developer can see exactly what the server returned.
  ///
  /// [image] — The [XFile] returned directly by [ImagePicker.pickImage].
  /// Using [XFile] instead of [dart:io File] ensures this method works on
  /// Flutter Web, where [dart:io] is not available.
  static Future<void> uploadProfilePicture(XFile image) async {
    // Build the base headers from SharedPreferences (includes the Bearer token).
    // Note: MultipartRequest sets its own Content-Type (multipart/form-data),
    // so we only inject the Authorization header here and drop Content-Type.
    final headers = await ApiConfig.getHeaders();

    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse('${ApiConfig.baseUrl}/students/me/picture'),
    );

    // Inject the JWT. Content-Type is intentionally omitted — the http package
    // automatically sets `multipart/form-data` with the correct boundary.
    request.headers['Authorization'] = headers['Authorization'] ?? '';

    // Attach the image under the exact Multer field name from students.route.ts:
    //   upload.single('picture-file')
    // fromBytes is used instead of fromPath because dart:io is not available
    // on Flutter Web. XFile.readAsBytes() works on all platforms.
    // contentType must be set explicitly: Flutter Web's http defaults to
    // application/octet-stream, which fails Multer's image-only MIME filter.
    final bytes = await image.readAsBytes();
    final mimeType = image.mimeType ?? 'image/jpeg';
    final mimeSplit = mimeType.split('/');
    request.files.add(
      http.MultipartFile.fromBytes(
        'picture-file',
        bytes,
        filename: image.name,
        contentType: MediaType(mimeSplit[0], mimeSplit[1]),
      ),
    );

    // Send the streamed request and collect the full response.
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    // Safe decode: if the server returns a non-2xx, surface the clearest
    // possible error. We do NOT delegate to ApiConfig.handleBackendError here
    // because its catch swallows non-JSON bodies (HTML 500 pages, CORS
    // failure strings) into a generic message, hiding the real server error.
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // ─── AUTOMATIC LOGOUT ON UNAUTHORIZED ───────────────────────────────────
      if (response.statusCode == 401 || response.statusCode == 403) {
        ApiConfig.logout();
        ApiConfig.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }

      try {
        // Attempt to extract the backend's structured error message.
        final decoded = jsonDecode(response.body);
        final message = decoded['message'];
        if (message != null && message is String) {
          // Double check message content for redundancy
          if (message.contains('Access denied') || message.contains('missing token')) {
            ApiConfig.logout();
            ApiConfig.navigatorKey.currentState?.pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        }
        throw Exception(
          (message is String && message.isNotEmpty)
              ? message
              : 'Upload failed (HTTP ${response.statusCode}).',
        );
      } on FormatException {
        // The body wasn't valid JSON — throw the raw text so the dev can
        // see exactly what the server (or proxy) returned.
        throw Exception(
          'Upload failed (HTTP ${response.statusCode}): ${response.body}',
        );
      }
      // Note: the Exception thrown inside the try is NOT a FormatException,
      // so it propagates out of this catch and up to the caller correctly.
    }
  }

  // ─── UPDATE PROFILE ─────────────────────────────────────────────────────────

  /// Updates the student's profile information.
  ///
  /// Endpoint: `PATCH /students/me`
  /// Auth required: ✅ Bearer token
  static Future<void> updateProfile({
    required String firstName,
    required String middleName,
    required String lastName,
    required String program,
    required String specialization,
    required int yearLevel,
  }) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/students/me'),
      headers: await ApiConfig.getHeaders(),
      body: jsonEncode({
        'firstName': firstName,
        'middleName': middleName.isNotEmpty ? middleName : null,
        'lastName': lastName,
        'program': program,
        'specialization': specialization.isNotEmpty ? specialization : null,
        'yearLevel': yearLevel,
      }),
    );
    ApiConfig.handleBackendError(response);
  }

  // ─── CHANGE PASSWORD ────────────────────────────────────────────────────────

  /// Changes the student's password.
  ///
  /// Endpoint: `PATCH /students/me/password`
  /// Auth required: ✅ Bearer token
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/students/me/password'),
      headers: await ApiConfig.getHeaders(),
      body: jsonEncode({
        'oldPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );
    ApiConfig.handleBackendError(response);
  }
}
