import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://fequote-api-155804644015.asia-southeast1.run.app';

  static Future<Map<String, dynamic>> detectEmotion(
    File imageFile, {
    String? deviceId,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/analyze'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      if (deviceId != null) {
        request.fields['device_id'] = deviceId;
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(responseData) as Map<String, dynamic>;
        if (jsonData.containsKey('error')) {
          throw Exception(jsonData['error'] as String);
        }

        return {
          'emotion': jsonData['emotion'],
          'confidence': (jsonData['confidence'] as num?)?.toDouble() ?? 0.0,
          'quotes': List<String>.from(jsonData['quotes'] as List),
        };
      }

      throw Exception('Server error: $responseData');
    } catch (e) {
      rethrow;
    }
  }
}
