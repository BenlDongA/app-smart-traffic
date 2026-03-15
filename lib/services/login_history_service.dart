// services/login_history_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_activity_model.dart';

class LoginHistoryService {
  static const String _key = 'login_history';

  // Lưu login activity mới
  Future<void> saveLoginActivity(LoginActivity activity) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];

    // Thêm activity mới vào đầu list
    history.insert(0, jsonEncode(activity.toJson()));

    // Giữ tối đa 10 hoạt động gần nhất
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    await prefs.setStringList(_key, history);
  }

  // Lấy lịch sử login
  Future<List<LoginActivity>> getLoginHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];

    return history
        .map((item) => LoginActivity.fromJson(jsonDecode(item)))
        .toList();
  }

  // Xóa lịch sử
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
