import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/app_data.dart';

class MockApiService {
  const MockApiService({
    this.bundle,
    this.assetPath = 'assets/data/seed_data.json',
    this.delay = const Duration(milliseconds: 1200),
  });

  final AssetBundle? bundle;
  final String assetPath;
  final Duration delay;

  Future<AppData> fetchSeedData() async {
    await Future<void>.delayed(delay);
    final activeBundle = bundle ?? rootBundle;
    final jsonString = await activeBundle.loadString(assetPath);
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return AppData.fromJson(jsonMap);
  }
}
