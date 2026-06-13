import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mood_dashboard_model.dart';
import 'api_service.dart';
import 'mood_analytics_local.dart';

class MoodDashboardService {
  Future<MoodDashboardModel> fetchWeeklyDashboard(String deviceId) async {
    try {
      final uri = Uri.parse('${ApiService.baseUrl}/mood/weekly?device_id=$deviceId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        if (!jsonData.containsKey('error')) {
          return MoodDashboardModel.fromJson(jsonData);
        }
      }
    } catch (_) {
      // Fall back to Firestore when API is unavailable or not yet deployed.
    }

    final records = await MoodAnalyticsLocal.fetchWeeklyFromFirestore(deviceId);
    return MoodAnalyticsLocal.buildFromRecords(records);
  }
}
