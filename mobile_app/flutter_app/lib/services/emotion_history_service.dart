import 'package:cloud_firestore/cloud_firestore.dart';

class EmotionHistoryService {
  static const _collection = 'emotion_records';

  Future<void> saveRecord({
    required String deviceId,
    required String emotion,
    required double confidence,
  }) async {
    await FirebaseFirestore.instance.collection(_collection).add({
      'device_id': deviceId,
      'emotion': emotion.toLowerCase(),
      'confidence': confidence,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
