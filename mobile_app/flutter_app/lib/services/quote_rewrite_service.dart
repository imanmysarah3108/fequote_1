import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class QuoteRewriteService {
  Future<String> rewriteQuote({
    required String quote,
    required String context,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/rewrite');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'quote': quote,
        'context': context,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to rewrite quote: ${response.body}');
    }

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    if (jsonData.containsKey('error')) {
      throw Exception(jsonData['error'] as String);
    }

    return jsonData['rewritten_quote'] as String;
  }
}
