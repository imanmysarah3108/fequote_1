/// A recommended quote plus its (optional) author.
///
/// The recommender used to return quotes as bare strings; it now returns
/// `{"quote": ..., "author": ...}` objects. [fromJson] accepts BOTH shapes so
/// the app keeps working against an older deployed backend (strings) and the
/// updated one (objects) — string elements simply have a null [author].
class RecommendedQuote {
  final String text;
  final String? author;

  const RecommendedQuote({required this.text, this.author});

  factory RecommendedQuote.fromJson(dynamic json) {
    if (json is Map) {
      final rawAuthor = json['author'];
      final author = (rawAuthor is String && rawAuthor.trim().isNotEmpty)
          ? rawAuthor.trim()
          : null;
      return RecommendedQuote(
        text: (json['quote'] ?? '').toString(),
        author: author,
      );
    }
    // Legacy shape: a plain quote string with no author.
    return RecommendedQuote(text: json.toString());
  }

  bool get hasAuthor => author != null && author!.isNotEmpty;
}
