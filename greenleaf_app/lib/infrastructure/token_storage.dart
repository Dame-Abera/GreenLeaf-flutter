import 'package:hive/hive.dart';

class TokenStorage {
  static const String _boxName = 'tokens';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final box = Hive.box(_boxName);
    await box.put(_accessTokenKey, accessToken);
    await box.put(_refreshTokenKey, refreshToken);
  }

  static String? get accessToken {
    final box = Hive.box(_boxName);
    return box.get(_accessTokenKey);
  }

  static String? get refreshToken {
    final box = Hive.box(_boxName);
    return box.get(_refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    final box = Hive.box(_boxName);
    await box.delete(_accessTokenKey);
    await box.delete(_refreshTokenKey);
  }
} 