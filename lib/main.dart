import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'app.dart';
import 'repositories/app_repository.dart';
import 'services/app_controller.dart';
import 'services/http_api_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiBaseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  ).isNotEmpty
      ? const String.fromEnvironment('API_BASE_URL')
      : (Platform.isAndroid ? 'http://10.0.2.2:5189' : 'http://127.0.0.1:5189');

  final controller = AppController(
    repository: AppRepository(
      apiService: HttpApiService(baseUrl: apiBaseUrl),
      storageService: StorageService(),
    ),
  );

  runApp(HomeNetworkAssistantApp(controller: controller));
}
