import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthApi {
  static Future<void> login(String studentNumber, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/students/login'),
      headers: await ApiConfig.getHeaders(),
      body: jsonEncode({
        'studentNum': studentNumber,
        'password': password,
      }),
    );

    ApiConfig.handleBackendError(response);

    final decoded = jsonDecode(response.body);
    final token = decoded['token'];
    if (token != null) {
      await ApiConfig.saveToken(token);
    }
  }

  static Future<void> register(Map<String, dynamic> data) async {
    final fullName = (data['full_name'] as String).trim();
    final parts = fullName.split(' ');
    final firstName = parts.first;
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
      'specialization': specialization == '' || specialization == null ? null : specialization,
      'yearLevel': 1,
      'email': '$studentNum@student.mseuf.edu.ph'.toLowerCase(),
      'password': password,
    };

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/students/register'),
      headers: await ApiConfig.getHeaders(),
      body: jsonEncode(requestBody),
    );

    ApiConfig.handleBackendError(response);
  }
}
