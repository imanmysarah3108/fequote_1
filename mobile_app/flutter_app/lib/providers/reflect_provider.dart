import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/emotion_history_service.dart';
import 'quote_provider.dart';

class ReflectProvider extends ChangeNotifier {
  final EmotionHistoryService _historyService = EmotionHistoryService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>?> captureAndDetect(
    File imageFile, {
    String? deviceId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.detectEmotion(imageFile, deviceId: deviceId);
      _isLoading = false;
      notifyListeners();

      final emotion = result['emotion'] as String;
      final confidence = (result['confidence'] as num?)?.toDouble() ?? 0.0;

      if (deviceId != null && emotion != 'no emotion detected') {
        await _historyService.saveRecord(
          deviceId: deviceId,
          emotion: emotion,
          confidence: confidence,
        );
      }

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
