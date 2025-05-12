import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUsername = 'username';

  // save login session
  static Future<bool> saveLoginSession(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyUsername, username);
    return true;
  }

  // cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  // get username
  static Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUsername);
  }

  // clear session
  static Future<bool> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, false);
    return true;
  }
}