class EmotionRecordModel {
  final String emotion;
  final double confidence;
  final DateTime timestamp;

  const EmotionRecordModel({
    required this.emotion,
    required this.confidence,
    required this.timestamp,
  });

  factory EmotionRecordModel.fromJson(Map<String, dynamic> json) {
    return EmotionRecordModel(
      emotion: json['emotion'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'emotion': emotion,
        'confidence': confidence,
        'timestamp': timestamp.toIso8601String(),
      };
}
