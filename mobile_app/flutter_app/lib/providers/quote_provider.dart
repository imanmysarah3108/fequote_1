import 'package:flutter/foundation.dart';

class QuoteProvider extends ChangeNotifier {
  String _emotion = 'Peaceful';
  List<String> _quotes = [];

  String get emotion => _emotion;
  List<String> get quotes => List.unmodifiable(_quotes);

  void setResult({required String emotion, required List<String> quotes}) {
    _emotion = emotion;
    _quotes = List<String>.from(quotes);
    notifyListeners();
  }

  void clear() {
    _emotion = 'Peaceful';
    _quotes = [];
    notifyListeners();
  }
}
