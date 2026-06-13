import 'package:flutter/foundation.dart';

class QuoteProvider extends ChangeNotifier {
  String _emotion = 'Peaceful';
  List<String> _quotes = [];
  int _selectedQuoteIndex = 0;

  String get emotion => _emotion;
  List<String> get quotes => List.unmodifiable(_quotes);
  int get selectedQuoteIndex => _selectedQuoteIndex;

  String get selectedQuote {
    if (_quotes.isEmpty) {
      return 'Your motivational quote will appear here. You are stronger than you think.';
    }
    return _quotes[_selectedQuoteIndex.clamp(0, _quotes.length - 1)];
  }

  void setResult({required String emotion, required List<String> quotes}) {
    _emotion = emotion;
    _quotes = List<String>.from(quotes);
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
