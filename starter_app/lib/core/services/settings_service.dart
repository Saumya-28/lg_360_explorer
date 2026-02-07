import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyHost = 'lg_host';
  static const String _keyPort = 'lg_port';
  static const String _keyUsername = 'lg_username';
  static const String _keyPassword = 'lg_password';
  static const String _keyScreens = 'lg_screens';

  Future<void> saveConnectionSettings(
    String host,
    String username,
    String password,
    int port,
    int screens,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHost, host);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyPassword, password);
    await prefs.setInt(_keyPort, port);
    await prefs.setInt(_keyScreens, screens);
  }

  Future<Map<String, dynamic>?> loadConnectionSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString(_keyHost);
    final username = prefs.getString(_keyUsername);
    final password = prefs.getString(_keyPassword);
    final port = prefs.getInt(_keyPort);
    final screens = prefs.getInt(_keyScreens);

    if (host != null && username != null && password != null && port != null && screens != null) {
      return {
        'host': host,
        'username': username,
        'password': password,
        'port': port,
        'screens': screens,
      };
    }
    return null;
  }

  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHost);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyPort);
    await prefs.remove(_keyScreens);
  }
}
