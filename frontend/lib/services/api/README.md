# EUventure — API Service Layer

`lib/services/api/`

This directory contains all network communication logic for the EUventure Flutter app.
Every interaction with the Node.js/Express backend lives here — no screen file ever
constructs an HTTP request directly.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                    UI / Screens                     │
│  (quiz_screen.dart, dashboard_screen.dart, etc.)    │
└──────────────────────┬──────────────────────────────┘
                       │  calls static methods on
                       ▼
┌─────────────────────────────────────────────────────┐
│             Specialized Service Classes             │
│  AuthApi │ ProfileApi │ QuizApi │ LandmarkApi │ …   │
└──────────────────────┬──────────────────────────────┘
                       │  all delegate through
                       ▼
┌─────────────────────────────────────────────────────┐
│                   ApiConfig                         │
│  • baseUrl        – single source of truth for URL  │
│  • getHeaders()   – injects Bearer token or plain   │
│  • handleBackendError() – throws on non-2xx         │
│  • saveToken() / getToken() / logout() – JWT store  │
└──────────────────────┬──────────────────────────────┘
                       │  HTTP via
                       ▼
           package:http (dart http library)
```

**Key principle:** `ApiConfig` is the single integration point.
All service classes call `ApiConfig.getHeaders()` before every request and
`ApiConfig.handleBackendError(response)` immediately after. Neither step is optional.

---

## Service Directory

| File | Class | Routes Handled | Auth Required |
|---|---|---|:---:|
| `api_config.dart` | `ApiConfig` | *(infrastructure — no routes)* | — |
| `auth_api.dart` | `AuthApi` | `POST /students/login` `POST /students/register` | ❌ |
| `profile_api.dart` | `ProfileApi` | `GET /students/me` | ✅ |
| `quiz_api.dart` | `QuizApi` | `GET /quizzes/` `GET /quizzes/:id` `POST /quizzes/:id/submit` | ✅ |
| `landmark_api.dart` | `LandmarkApi` | `GET /landmarks/` `GET /landmarks/:id` `POST /landmarks/:id/visit` | ✅ |
| `achievement_api.dart` | `AchievementApi` | `GET /achievements/` | ✅ |

---

## Authentication — How the Bearer Token Works

1. **Login** — `AuthApi.login()` sends credentials to the backend. On success, the
   backend returns a JWT string inside `{ "token": "..." }`. `AuthApi` immediately
   calls `ApiConfig.saveToken(token)`, which stores it in `SharedPreferences`
   (on-device persistent storage).

2. **Every subsequent request** — `ApiConfig.getHeaders()` reads the token from
   `SharedPreferences` and returns:
   ```dart
   { 'Content-Type': 'application/json', 'Authorization': 'Bearer <token>' }
   ```
   If no token is stored (unauthenticated state), the `Authorization` header is
   simply omitted — the backend will respond with `401 Unauthorized`.

3. **Logout** — `ApiConfig.logout()` calls `prefs.remove(_tokenKey)`, erasing the
   token from device storage. The `DashboardScreen` then clears the navigation
   stack and pushes `AuthScreen`, making it impossible to navigate back.

> **Never hardcode a token.** Always go through `ApiConfig.getHeaders()`.

---

## Standard Pattern — Writing a New Service Method

All service methods follow this exact template. Copy it whenever adding a new endpoint.

### GET request (returns a list)
```dart
/// Brief description of what this fetch returns.
///
/// Endpoint: GET /your-resource
/// Returns: A list of [YourModel] maps from the backend.
/// Throws: [Exception] with a user-readable message if the server responds
///         with a non-2xx status code.
static Future<List<dynamic>> getItems() async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/your-resource'),
    headers: await ApiConfig.getHeaders(), // ← Always await headers
  );

  // Throws an Exception with the backend's error message if status >= 400.
  ApiConfig.handleBackendError(response);

  // Decode the JSON response body into a Dart List.
  return jsonDecode(response.body);
}
```

### POST request (sends a body, returns a map)
```dart
/// Brief description of what this action does.
///
/// Endpoint: POST /your-resource/:id/action
/// Parameters:
///   [id]       - The database ID of the target resource.
///   [payload]  - Map of fields to send. Keys must match the backend schema exactly.
/// Returns: A [Map] containing the server's response (e.g., updated record, result).
/// Throws: [Exception] with a user-readable message on failure.
static Future<Map<String, dynamic>> doAction(int id, String payload) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/your-resource/$id/action'),
    headers: await ApiConfig.getHeaders(),
    body: jsonEncode({'field': payload}), // ← Keys must exactly match Zod schema
  );

  ApiConfig.handleBackendError(response);

  return jsonDecode(response.body);
}
```

### Calling a service method from the UI (correct pattern)
```dart
Future<void> _loadData() async {
  try {
    final data = await YourApi.getItems();
    if (mounted) {
      setState(() { /* update state */ });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        // Strip the "Exception: " prefix that Dart prepends automatically.
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red,
      ));
    }
  } finally {
    // Always reset loading state — even if the widget was disposed mid-request.
    if (mounted) setState(() => _isLoading = false);
  }
}
```

> **Why `finally`?** If an exception is thrown AND `mounted` is false (user navigated
> away mid-request), the `catch` block's `setState` would be skipped entirely, leaving
> `_isLoading = true` forever. The `finally` block guarantees the reset happens.

---

## Error Response Format

The backend always returns errors in this shape:
```json
{
  "type": "QUIZ",
  "code": "QUIZ_LOCKED",
  "message": "Quiz requires more landmark visits to unlock"
}
```
`ApiConfig.handleBackendError()` extracts the `message` field and throws it as a
Dart `Exception`. The UI's `catch` block receives a clean, human-readable string.

---

## Response Shape Quick Reference

### `GET /students/me`
```json
{ "info": { "student_number", "first_name", "last_name", "program", ... },
  "progress": { "level", "quiz_points", "landmarks": { "total", "visited" },
                "xp": { "total_xp", "next_threshold", "to_next_level" } } }
```

### `GET /quizzes/`
```json
[{ "info": { "quiz_id", "name", "min_landmarks", "max_score", "question_count" },
   "status": { "is_locked", "remaining_landmarks_needed", "is_completed",
               "score_achieved", "is_passed" } }]
```

### `GET /quizzes/:id`
```json
{ "info": { ... }, "status": { ... },
  "questions": [{ "question_id", "question_text", "choices", "item_points",
                  "your_answer?" }] }
```

### `POST /quizzes/:id/submit`
```json
{ "quiz": { "performance": { "score_achieved", "is_passed" }, "breakdown": [...] },
  "progress": { "xp": { ... }, "level": { "current", "did_level_up" } },
  "new_achievements": [{ "title", "description", ... }] }
```

### `GET /landmarks/`
```json
[{ "landmark_id", "name", "description", "img_path", "is_visited" }]
```

### `POST /landmarks/:id/visit`
```json
{ "landmark": { "name", "fun_fact", "visited_at" },
  "progress": { "xp": { ... }, "level": { "current", "did_level_up" } },
  "new_achievements": [...] }
```

### `GET /achievements/`
```json
[{ "achievement_id", "title", "description", "category", "threshold",
   "is_unlocked", "earned_at" }]
```
