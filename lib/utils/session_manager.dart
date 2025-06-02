import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUsername = 'username';
  static const String keyUserId = 'userId'; // New key for User ID

  // Save login session with both username and userId
  static Future<bool> saveLoginSession(String username, int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyUsername, username);
    await prefs.setInt(keyUserId, userId); // Save userId
    print('Session saved: UserID: $userId, Username: $username, IsLoggedIn: true');
    return true;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool(keyIsLoggedIn) ?? false;
    print('Session check: IsLoggedIn: $loggedIn');
    return loggedIn;
  }

  // Get username
  static Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString(keyUsername);
    print('Session get: Username: $username');
    return username;
  }

  // Get userId
  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt(keyUserId);
    print('Session get: UserID: $userId');
    return userId;
  }

  // Clear all session data for a complete logout
  static Future<bool> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyIsLoggedIn);
    await prefs.remove(keyUsername);
    await prefs.remove(keyUserId); // Remove userId as well
    print('Session cleared');
    return true;
  }
}