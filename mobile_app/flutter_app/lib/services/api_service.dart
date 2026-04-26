import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> detectEmotion(File imageFile) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://fequote-api-155804644015.asia-southeast1.run.app/analyze'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    var response = await request.send();

    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(responseData);

      return {
        "emotion": jsonData['emotion'],
        "quotes": List<String>.from(jsonData['quotes']),
      };
    } else {
      throw Exception("Server error");
    }
  } catch (e) {
    print("❌ $e");
    return {
      "emotion": "error",
      "quotes": []
    };
  }
}}