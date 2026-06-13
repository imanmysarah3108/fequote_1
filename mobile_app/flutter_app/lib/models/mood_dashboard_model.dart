class MoodSummaryModel {
  final String title;
  final String description;

  const MoodSummaryModel({
    required this.title,
    required this.description,
  });

  factory MoodSummaryModel.fromJson(Map<String, dynamic> json) {
    return MoodSummaryModel(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

class MoodStatisticsModel {
  final int totalScans;
  final String mostFrequentEmotion;
  final int averageConfidence;
  final int daysTracked;

  const MoodStatisticsModel({
    required this.totalScans,
    required this.mostFrequentEmotion,
    required this.averageConfidence,
    required this.daysTracked,
  });

  factory MoodStatisticsModel.fromJson(Map<String, dynamic> json) {
    return MoodStatisticsModel(
      totalScans: json['total_scans'] as int? ?? 0,
      mostFrequentEmotion: json['most_frequent_emotion'] as String? ?? '—',
      averageConfidence: json['average_confidence'] as int? ?? 0,
      daysTracked: json['days_tracked'] as int? ?? 0,
    );
  }

  static const empty = MoodStatisticsModel(
    totalScans: 0,
    mostFrequentEmotion: '—',
    averageConfidence: 0,
    daysTracked: 0,
  );
}

class MoodDashboardModel {
  final DateTime weekStart;
  final DateTime weekEnd;
  final Map<String, double> distribution;
  final MoodSummaryModel summary;
  final MoodStatisticsModel statistics;

  const MoodDashboardModel({
    required this.weekStart,
    required this.weekEnd,
    required this.distribution,
    required this.summary,
    required this.statistics,
  });

  factory MoodDashboardModel.fromJson(Map<String, dynamic> json) {
    final distributionRaw = json['distribution'] as Map<String, dynamic>? ?? {};
    final distribution = distributionRaw.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return MoodDashboardModel(
      weekStart: DateTime.parse(json['week_start'] as String),
      weekEnd: DateTime.parse(json['week_end'] as String),
      distribution: distribution,
      summary: MoodSummaryModel.fromJson(json['summary'] as Map<String, dynamic>),
      statistics: MoodStatisticsModel.fromJson(json['statistics'] as Map<String, dynamic>),
    );
  }

  static MoodDashboardModel empty() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return MoodDashboardModel(
      weekStart: weekStart,
      weekEnd: weekStart.add(const Duration(days: 6)),
      distribution: {
        'happy': 0,
        'sad': 0,
        'surprise': 0,
        'angry': 0,
      },
      summary: const MoodSummaryModel(
        title: 'Balanced',
        description: 'Start scanning your mood to see your weekly insights.',
      ),
      statistics: MoodStatisticsModel.empty,
    );
  }
}
