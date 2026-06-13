import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/quote_rewrite_service.dart';

class QuoteRewriteViewModel extends ChangeNotifier {
  final QuoteRewriteService _service = QuoteRewriteService();
  final SpeechToText _speech = SpeechToText();

  String _originalQuote = '';
  String _context = '';
  String? _rewrittenQuote;
  bool _isLoading = false;
  bool _isListening = false;
  String? _error;
  bool _speechAvailable = false;

  String get originalQuote => _originalQuote;
  String get context => _context;
  String? get rewrittenQuote => _rewrittenQuote;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  String? get error => _error;
  bool get speechAvailable => _speechAvailable;
  bool get hasResult => _rewrittenQuote != null && _rewrittenQuote!.isNotEmpty;

  void setOriginalQuote(String quote) {
    _originalQuote = quote;
    notifyListeners();
  }

  void setContext(String value) {
    _context = value;
    notifyListeners();
  }

  Future<void> initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          notifyListeners();
        }
      },
      onError: (_) {
        _isListening = false;
        notifyListeners();
      },
    );
    notifyListeners();
  }

  Future<void> startListening() async {
    if (!_speechAvailable) return;

    _isListening = true;
    notifyListeners();

    await _speech.listen(
      onResult: (result) {
        _context = result.recognizedWords;
        notifyListeners();
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  Future<void> rewriteQuote() async {
    if (_context.trim().isEmpty) {
      _error = 'Please describe what is happening today.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rewrittenQuote = await _service.rewriteQuote(
        quote: _originalQuote,
        context: _context.trim(),
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rewriteAgain() async {
    _rewrittenQuote = null;
    notifyListeners();
    await rewriteQuote();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
