import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_data.dart';

class StorageService {
  static const _snapshotKey = 'app_snapshot';

  Future<AppData?> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final snapshot = prefs.getString(_snapshotKey);
    if (snapshot == null) {
      return null;
    }

    return AppData.fromJson(json.decode(snapshot) as Map<String, dynamic>);
  }

  Future<void> saveSnapshot(AppData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_snapshotKey, json.encode(data.toJson()));
  }
}
