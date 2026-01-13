import 'package:hive_flutter/hive_flutter.dart';

class TokenStorage {
  static const String _boxName = 'auth';
  static const String _tokenKey = 'token';
  static const String _cartBoxName = 'cart';

  /// Initialize Hive (call once at app startup)
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_boxName);
    await Hive.openBox<Map>(_cartBoxName);
  }

  static Future<void> saveToken(String token) async {
    final box = Hive.box<String>(_boxName);
    await box.put(_tokenKey, token);
  }

  static String? getToken() {
    final box = Hive.box<String>(_boxName);
    return box.get(_tokenKey);
  }

  static Future<void> clearToken() async {
    final box = Hive.box<String>(_boxName);
    await box.delete(_tokenKey);
  }
}
// ...existing code...