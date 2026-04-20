import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class LandmarkApi {
  // GET /landmarks/
  // Returns the full checklist of all landmarks with a per-student `is_visited` flag.
  static Future<List<dynamic>> getChecklist() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/landmarks'),
      headers: await ApiConfig.getHeaders(),
    );

    ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }

  // GET /landmarks/:id
  // Returns the full detail for a single landmark.
  static Future<Map<String, dynamic>> getLandmark(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/landmarks/$id'),
      headers: await ApiConfig.getHeaders(),
    );

    ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }

  // POST /landmarks/:id/visit
  // Records a QR scan visit for the logged-in student.
  // [qrCode] must match the value encoded in the physical QR code for this landmark.
  // Returns visit details and the student's updated XP progress.
  static Future<Map<String, dynamic>> visitLandmark(
    int id,
    String qrCode,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/landmarks/$id/visit'),
      headers: await ApiConfig.getHeaders(),
      body: jsonEncode({'qr_code_scanned': qrCode}),
    );

    ApiConfig.handleBackendError(response);

    return jsonDecode(response.body);
  }
}
