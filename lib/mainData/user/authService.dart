import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userEmailKey = 'userEmail';
  static const String _userInfoKey = 'userInfo';
  static const String _communeKey = 'userCommune';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> setLoggedIn(bool value, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
    if (value) {
      await prefs.setString(_userEmailKey, email);
    } else {
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userInfoKey);
      await prefs.remove(_communeKey);
    }
  }

  static Future<void> setUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userInfoKey, json.encode(userInfo));
    
    // Lưu thông tin xã riêng biệt
    if (userInfo.containsKey('commune')) {
      await prefs.setString(_communeKey, userInfo['commune']);
    }
  }

  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString(_userInfoKey);
    final commune = prefs.getString(_communeKey);
    if (userInfoString != null) {
      Map<String, dynamic> userInfo = json.decode(userInfoString) as Map<String, dynamic>;
      if (commune != null) {
        userInfo['commune'] = commune;
      }
      return userInfo;
    }
    return null;
  }

  static Future<String?> getLoggedInUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<String?> getUserCommune() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_communeKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userInfoKey);
    await prefs.remove(_communeKey);
  }

  static Future<void> updateUserInfo(Map<String, dynamic> newInfo) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserInfo = await getUserInfo();
    if (currentUserInfo != null) {
      currentUserInfo.addAll(newInfo);
      await setUserInfo(currentUserInfo);
    }
  }
}