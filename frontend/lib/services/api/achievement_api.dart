import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AchievementApi {
  // GET /achievements/
  // Returns all achievements in the system, each decorated with:
  //   `is_unlocked` (bool) — whether this student has earned it
  //   `earned_at`   (String?) — ISO timestamp when earned, or null
  static Future<List<dynamic>> getAchievements() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/achievements'),
      headers: await ApiConfig.getHeaders(),
    );

    ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }
}
