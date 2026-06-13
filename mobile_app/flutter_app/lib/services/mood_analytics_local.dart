import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emotion_record_model.dart';
import '../models/mood_dashboard_model.dart';

class MoodAnalyticsLocal {
  static const _supportedEmotions = ['happy', 'sad', 'surprise', 'angry'];

  static DateTime _weekStart(DateTime reference) {
    return DateTime(reference.year, reference.month, reference.day)
        .subtract(Duration(days: reference.weekday - 1));
  }

  static MoodDashboardModel buildFromRecords(List<EmotionRecordModel> records) {
    final now = DateTime.now();
    final weekStart = _weekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 6));

    final weekly = records.where((record) {
      final day = DateTime(record.timestamp.year, record.timestamp.month, record.timestamp.day);
      final start = weekStart;
      final end = weekStart.add(const Duration(days: 7));
      return !day.isBefore(start) && day.isBefore(end) &&
          _supportedEmotions.contains(record.emotion.toLowerCase());
    }).toList();

    final counts = {for (final e in _supportedEmotions) e: 0};
    double confidenceSum = 0;
    final days = <String>{};

    for (final record in weekly) {
      final emotion = record.emotion.toLowerCase();
      if (counts.containsKey(emotion)) {
        counts[emotion] = counts[emotion]! + 1;
      }
      confidenceSum += record.confidence;
      days.add(record.timestamp.toIso8601String().split('T').first);
    }

    final total = weekly.length;
    final distribution = total == 0
        ? {for (final e in _supportedEmotions) e: 0.0}
        : {
            for (final entry in counts.entries)
              entry.key: (entry.value / total * 100).roundToDouble(),
          };

    final happy = distribution['happy'] ?? 0;
    final sad = distribution['sad'] ?? 0;
    final angry = distribution['angry'] ?? 0;

    String title;
    String description;
    if (happy > 40) {
      title = 'Positive';
      description = 'You had a positive week and maintained a healthy emotional balance.';
    } else if (sad > 40) {
      title = 'Needs Support';
      description =
          'This week appears emotionally challenging. Remember to take time for yourself and seek support when needed.';
    } else if (angry > 40) {
      title = 'Emotionally Strained';
      description =
          'You experienced higher emotional stress this week. Taking breaks and practicing self-care may help.';
    } else {
      title = 'Balanced';
      description = 'You had a mix of ups and downs, but you stayed strong and kept going.';
    }

    String mostFrequent = '—';
    if (total > 0) {
      final top = counts.entries.reduce((a, b) => a.value > b.value ? a : b);
      if (top.value > 0) mostFrequent = top.key[0].toUpperCase() + top.key.substring(1);
    }

    return MoodDashboardModel(
      weekStart: weekStart,
      weekEnd: weekEnd,
      distribution: distribution,
      summary: MoodSummaryModel(title: title, description: description),
      statistics: MoodStatisticsModel(
        totalScans: total,
        mostFrequentEmotion: mostFrequent,
        averageConfidence: total == 0 ? 0 : (confidenceSum / total * 100).round(),
        daysTracked: days.length,
      ),
    );
  }

  static Future<List<EmotionRecordModel>> fetchWeeklyFromFirestore(String deviceId) async {
    final weekStart = _weekStart(DateTime.now());
    final weekEnd = weekStart.add(const Duration(days: 7));

    final snapshot = await FirebaseFirestore.instance
        .collection('emotion_records')
        .where('device_id', isEqualTo: deviceId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
      return EmotionRecordModel(
        emotion: data['emotion'] as String,
        confidence: (data['confidence'] as num).toDouble(),
        timestamp: timestamp,
      );
    }).where((record) {
      final day = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );
      return !day.isBefore(weekStart) && day.isBefore(weekEnd);
    }).toList();
  }
}
