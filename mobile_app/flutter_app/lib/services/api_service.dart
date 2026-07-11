import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/recommended_quote.dart';

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
          'quotes': (jsonData['quotes'] as List)
              .map(RecommendedQuote.fromJson)
              .toList(),
        };
      }

      throw Exception('Server error: $responseData');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch quotes for a manually selected emotion (fallback when FER returns
  /// "no emotion detected"). Hits the same CBF recommender as [detectEmotion],
  /// just without an image. [emotion] must be a real FER label
  /// (happy / sad / angry / surprise).
  static Future<List<RecommendedQuote>> fetchQuotesByEmotion(
    String emotion,
  ) async {
    final uri = Uri.parse('$baseUrl/quotes').replace(
      queryParameters: {'emotion': emotion},
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonData.containsKey('error')) {
        throw Exception(jsonData['error'] as String);
      }
      return (jsonData['quotes'] as List)
          .map(RecommendedQuote.fromJson)
          .toList();
    }

    throw Exception('Server error: ${response.body}');
  }
}
