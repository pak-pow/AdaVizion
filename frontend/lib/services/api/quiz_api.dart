import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class QuizApi {
  // GET /quizzes/
  // Returns all quizzes with per-student attempt status and best score.
  static Future<List<dynamic>> getQuizzes() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/quizzes'),
      headers: await ApiConfig.getHeaders(),
    );

    ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }

  // GET /quizzes/:id
  // Returns a single quiz with its questions and the student's previous score (if any).
  static Future<Map<String, dynamic>> getQuiz(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/quizzes/$id'),
      headers: await ApiConfig.getHeaders(),
    );

    ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }

  // POST /quizzes/:id/submit
  // Submits a completed quiz attempt and returns scoring results + XP awarded.
  //
  // [answers] must be a list of maps with the exact keys the backend Zod schema expects:
  //   { 'question_id': int, 'selected_idx': int (0–3) }
  static Future<Map<String, dynamic>> submitQuiz(
    int id,
    List<Map<String, int>> answers,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/quizzes/$id/submit'),
      headers: await ApiConfig.getHeaders(),
      body: jsonEncode({'answers': answers}),
    );

    ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }
}
