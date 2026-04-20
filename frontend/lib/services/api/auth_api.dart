import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Service class responsible for all student authentication operations.
///
/// Handles the two public (unauthenticated) endpoints:
///   - `POST /students/login`    — verifies credentials and stores the JWT
///   - `POST /students/register` — creates a new student account
///
/// These are the only endpoints in the entire app that do NOT require a
/// Bearer token. All other service classes require the user to be logged in.
class AuthApi {
  // ─── LOGIN ──────────────────────────────────────────────────────────────────

  /// Authenticates a student with the backend and persists the returned JWT token.
  ///
  /// Endpoint: `POST /students/login`
  /// Auth required: ❌ No token needed
  ///
  /// Parameters:
  ///   [studentNumber] — The student's ID number (e.g., "A12-1235").
  ///                     `.trim()` is applied before sending to strip accidental spaces.
  ///   [password]      — The student's plain-text password. The backend handles
  ///                     bcrypt comparison — never hash on the client side.
  ///
  /// On success: The backend returns `{ "token": "...", "student": { ... } }`.
  ///   The token is saved via [ApiConfig.saveToken] so all subsequent requests
  ///   will automatically include `Authorization: Bearer <token>`.
  ///
  /// On failure: [ApiConfig.handleBackendError] throws an [Exception] with the
  ///   backend's error message (e.g., "Incorrect student number or password").
  static Future<void> login(String studentNumber, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/students/login'),
      headers: await ApiConfig.getHeaders(),
      body: jsonEncode({
        // The backend expects camelCase key "studentNum", not "student_number".
        'studentNum': studentNumber.trim(),
        'password': password,
      }),
    );

    // Throws a user-readable Exception if the server returns 4xx or 5xx.
    ApiConfig.handleBackendError(response);

    // Decode the success body and extract the JWT token.
    final decoded = jsonDecode(response.body);
    final token = decoded['token'];

    // Persist the token to on-device storage for all future requests.
    if (token != null) {
      await ApiConfig.saveToken(token);
    }
  }

  // ─── REGISTER ───────────────────────────────────────────────────────────────

  /// Registers a new student account on the backend.
  ///
  /// Endpoint: `POST /students/register`
  /// Auth required: ❌ No token needed
  ///
  /// Parameters:
  ///   [data] — A map containing the raw form values from the registration screen:
  ///     - `'full_name'`      (String) — Full name entered by the user.
  ///     - `'student_number'` (String) — Student ID (e.g., "A12-1235").
  ///     - `'program'`        (String) — Program abbreviation (e.g., "BSCS").
  ///     - `'specialization'` (String?) — Optional track (e.g., "Software Engineering").
  ///     - `'password'`       (String) — Plain-text password chosen by the user.
  ///
  /// Data transformations applied before sending:
  ///   - `full_name` is split into `firstName` / `lastName` (backend requires these separately).
  ///   - `student_number` is `.trim()`-ed to strip whitespace.
  ///   - `email` is auto-generated as `<studentNum>@student.mseuf.edu.ph` (lowercase).
  ///   - Empty or null `specialization` is explicitly sent as `null` (not an empty string).
  ///   - `yearLevel` is hardcoded to `1` for all new registrations.
  ///
  /// On success: The backend creates the student and a Progress record in a
  ///   single database transaction. Returns `{ "message": "Sign-up successful", "student": {...} }`.
  ///
  /// On failure: Throws an [Exception] — most commonly a duplicate student
  ///   number/email (Prisma P2002 → "Student number or email already exists").
  static Future<void> register(Map<String, dynamic> data) async {
    // Split the full name into first and last name components.
    // The backend's RegistrationSchema requires them as separate fields.
    final fullName = (data['full_name'] as String).trim();
    final parts = fullName.split(' ');
    final firstName = parts.first;
    // If only one word was entered, default last name to 'Unknown'.
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : 'Unknown';

    final studentNum = (data['student_number'] as String).trim();
    final program = data['program'];
    final specialization = data['specialization'];
    final password = data['password'];

    final requestBody = {
      'studentNum': studentNum,
      'firstName': firstName,
      'lastName': lastName,
      'program': program,
      // Convert empty string to null — the Zod schema rejects empty strings
      // for optional fields, but accepts null.
      'specialization':
          specialization == '' || specialization == null ? null : specialization,
      // All new students start at year level 1.
      'yearLevel': 1,
      // Email is derived from the student number per university convention.
      'email': '$studentNum@student.mseuf.edu.ph'.toLowerCase(),
      'password': password,
    };

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/students/register'),
      headers: await ApiConfig.getHeaders(),
      body: jsonEncode(requestBody),
    );

    ApiConfig.handleBackendError(response);
    // No return value needed — the UI simply navigates to the login screen on success.
  }
}
