import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<String> detectEmotion(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.62.49.84:8000/analyze'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonData = jsonDecode(responseData);

      return jsonData['emotion'];
    } else {
      return "error";
    }
  }
}