import 'package:flutter/foundation.dart';
import '../models/mood_dashboard_model.dart';
import '../services/mood_dashboard_service.dart';

class MoodDashboardViewModel extends ChangeNotifier {
  final MoodDashboardService _service = MoodDashboardService();

  MoodDashboardModel _dashboard = MoodDashboardModel.empty();
  bool _isLoading = false;
  String? _error;

  MoodDashboardModel get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _dashboard.statistics.totalScans == 0;

  Future<void> loadDashboard(String deviceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await _service.fetchWeeklyDashboard(deviceId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
