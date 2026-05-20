import 'package:flutter/material.dart';

import 'app.dart';
import 'repositories/app_repository.dart';
import 'services/app_controller.dart';
import 'services/mock_api_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = AppController(
    repository: AppRepository(
      apiService: const MockApiService(),
      storageService: StorageService(),
    ),
  );

  runApp(HomeNetworkAssistantApp(controller: controller));
}
