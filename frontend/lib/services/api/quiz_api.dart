import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class QuizApi {
  static Future<List<dynamic>> getQuizzes() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/quizzes'),
      headers: await ApiConfig.getHeaders(),
    );

    ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }
}
