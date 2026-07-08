import 'package:flutter/foundation.dart';

/// Sentinel the FER backend returns when it cannot confidently read a face.
/// The confidence threshold itself is decided server-side (Gemini) — this
/// string is the only signal the client receives, so it is the single source
/// of truth for the "no emotion" state. It must never be shown as an emotion
/// label or routed into a quote query.
const String kNoEmotionSentinel = 'no emotion detected';

/// Sentinel the CBF recommender returns when an emotion matches no quotes.
/// Normalised away so it can never render as if it were a real quote.
const String kNoQuotesSentinel = 'No quotes found';

class QuoteProvider extends ChangeNotifier {
  String _emotion = 'Peaceful';
  List<String> _quotes = [];
  int _selectedQuoteIndex = 0;

  String get emotion => _emotion;
  List<String> get quotes => List.unmodifiable(_quotes);
  int get selectedQuoteIndex => _selectedQuoteIndex;

  /// True when FER could not read the expression. Consumers branch to the
  /// fallback UI instead of treating [emotion] as a real detected mood.
  bool get noEmotionDetected =>
      _emotion.trim().toLowerCase() == kNoEmotionSentinel;

  String get selectedQuote {
    if (_quotes.isEmpty) {
      return 'Your motivational quote will appear here. You are stronger than you think.';
    }
    return _quotes[_selectedQuoteIndex.clamp(0, _quotes.length - 1)];
  }

  void setResult({required String emotion, required List<String> quotes}) {
    _emotion = emotion;
    // Drop the recommender's "No quotes found" sentinel so it never renders as
    // a real quote; an empty list drives the proper placeholder/empty state.
    final normalised = List<String>.from(quotes);
    if (normalised.length == 1 && normalised.first == kNoQuotesSentinel) {
      normalised.clear();
    }
    _quotes = normalised;
    _selectedQuoteIndex = 0;
    notifyListeners();
  }

  void setSelectedQuoteIndex(int index) {
    if (_quotes.isEmpty) return;
    _selectedQuoteIndex = index.clamp(0, _quotes.length - 1);
    notifyListeners();
  }

  void clear() {
    _emotion = 'Peaceful';
    _quotes = [];
    _selectedQuoteIndex = 0;
    notifyListeners();
  }
}
