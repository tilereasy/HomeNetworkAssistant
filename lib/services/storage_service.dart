import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class StorageService {
  static const _sessionUserKey = 'session_user';
  static const _currentProjectIdKey = 'current_project_id';

  Future<User?> loadSessionUser() async {
    final prefs = await SharedPreferences.getInstance();
    final snapshot = prefs.getString(_sessionUserKey);
    if (snapshot == null || snapshot.isEmpty) {
      return null;
    }

    return User.fromJson(json.decode(snapshot) as Map<String, dynamic>);
  }

  Future<void> saveSessionUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionUserKey, json.encode(user.toJson()));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionUserKey);
  }

  Future<int?> loadCurrentProjectId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentProjectIdKey);
  }

  Future<void> saveCurrentProjectId(int projectId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentProjectIdKey, projectId);
  }

  Future<void> clearCurrentProjectId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentProjectIdKey);
  }
}
