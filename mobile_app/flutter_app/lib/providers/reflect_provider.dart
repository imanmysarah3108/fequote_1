import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import 'quote_provider.dart';

class ReflectProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>?> captureAndDetect(File imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.detectEmotion(imageFile);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('❌ ERROR: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void updateQuoteFromResult(QuoteProvider quoteProvider, Map<String, dynamic> result) {
    quoteProvider.setResult(
      emotion: result['emotion'] as String,
      quotes: List<String>.from(result['quotes'] as List),
    );
  }
}
