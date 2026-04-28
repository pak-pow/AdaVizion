import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../../screens/dashboard/models/badge_model.dart';

/// Service class for fetching the student's achievement badge progress.
class AchievementApi {
  /// Fetches all achievements in the system with the student's earned status.
  /// Endpoint: `GET /achievements`
  static Future<List<BadgeConfig>> getAchievements() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/achievements'),
      headers: await ApiConfig.getHeaders(),
    );

    await ApiConfig.handleBackendError(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => BadgeConfig.fromJson(json)).toList();
  }
}
