import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Central configuration and shared infrastructure for all API calls.
///
/// This class is the single source of truth for:
///   - The backend base URL ([baseUrl])
///   - JWT token persistence ([saveToken], [getToken], [logout])
///   - Request header construction with automatic auth injection ([getHeaders])
///   - Unified error handling for non-2xx responses ([handleBackendError])
///
/// Every service class (AuthApi, QuizApi, etc.) depends on this class.
/// No screen or widget should call this class directly — use the specialized
/// service classes instead.
class ApiConfig {
  /// The root URL of the EUventure Express backend.
  /// Change this value when deploying to a staging or production server.
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// The key used to store and retrieve the JWT token in SharedPreferences.
  /// Kept private to ensure all token access goes through the methods below.
  static const String _tokenKey = 'jwt_token';

  // ─── TOKEN MANAGEMENT ───────────────────────────────────────────────────────

  /// Reads the stored JWT token from on-device persistent storage.
  ///
  /// Returns `null` if no token exists (i.e., the user is not logged in).
  /// Called internally by [getHeaders] — most callers should not use this directly.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Persists a JWT token to on-device storage after a successful login.
  ///
  /// [token] — The raw JWT string returned by `POST /students/login`.
  /// Called exclusively by [AuthApi.login] immediately after a successful response.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Removes the stored JWT token, effectively logging the user out locally.
  ///
  /// This does NOT invalidate the token on the server (the backend has no
  /// revocation endpoint). The token simply becomes inaccessible to the app.
  /// Called by [DashboardScreen._showLogoutConfirmation] on user confirmation.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ─── REQUEST INFRASTRUCTURE ─────────────────────────────────────────────────

  /// Builds the HTTP headers required for every backend request.
  ///
  /// Always sets `Content-Type: application/json`.
  /// If a JWT token is stored, appends `Authorization: Bearer <token>`.
  /// If no token exists (unauthenticated), the Authorization header is omitted —
  /// the backend will return a 401 for any protected route.
  ///
  /// This is an async method because reading from SharedPreferences is async.
  /// Always `await` it: `headers: await ApiConfig.getHeaders()`.
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    // Return unauthenticated headers for public routes (login, register).
    return {'Content-Type': 'application/json'};
  }

  // ─── ERROR HANDLING ─────────────────────────────────────────────────────────

  /// Inspects an HTTP response and throws a user-readable [Exception] if the
  /// status code indicates a failure (any code outside the 200–299 range).
  ///
  /// The backend always responds with a JSON body in the form:
  ///   `{ "type": "...", "code": "...", "message": "Human-readable error" }`
  ///
  /// This method extracts the `message` field and throws it as an [Exception],
  /// so the calling service's `catch` block receives a clean, displayable string.
  ///
  /// If the response body cannot be parsed as JSON (e.g., a network proxy
  /// returned an HTML error page), a generic fallback message is thrown instead.
  ///
  /// **Usage:** Call immediately after every `http.get/post/patch` call:
  /// ```dart
  /// final response = await http.get(...);
  /// ApiConfig.handleBackendError(response); // throws if not 2xx
  /// return jsonDecode(response.body);       // safe to decode here
  /// ```
  static void handleBackendError(http.Response response) {
    // 2xx range means success — nothing to do.
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    try {
      // Attempt to decode the error body to extract the message field.
      final decoded = jsonDecode(response.body);
      final message = decoded['message'];
      if (message != null && message is String) {
        throw Exception(message);
      } else {
        throw Exception('An unknown backend error occurred.');
      }
    } catch (e) {
      if (e is FormatException) {
        // The body wasn't valid JSON — likely a network/proxy error.
        throw Exception('Failed to connect or parse response from the server.');
      }
      // Re-throw the Exception we created above.
      rethrow;
    }
  }
}
