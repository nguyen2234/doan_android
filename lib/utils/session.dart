import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _key = 'user_id';

  static Future<void> save(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, userId);
  }

  static Future<int?> get() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
