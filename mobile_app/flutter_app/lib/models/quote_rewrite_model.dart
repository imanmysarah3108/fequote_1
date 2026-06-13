class QuoteRewriteModel {
  final String originalQuote;
  final String context;
  final String? rewrittenQuote;

  const QuoteRewriteModel({
    required this.originalQuote,
    required this.context,
    this.rewrittenQuote,
  });

  QuoteRewriteModel copyWith({
    String? originalQuote,
    String? context,
    String? rewrittenQuote,
  }) {
    return QuoteRewriteModel(
      originalQuote: originalQuote ?? this.originalQuote,
      context: context ?? this.context,
      rewrittenQuote: rewrittenQuote ?? this.rewrittenQuote,
    );
  }
}
