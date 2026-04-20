import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ProfileApi {
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/students/me'),
      headers: await ApiConfig.getHeaders(),
    );

    ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }
}
