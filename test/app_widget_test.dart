import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:home_network_assistant/app.dart';
import 'package:home_network_assistant/repositories/app_repository.dart';
import 'package:home_network_assistant/services/app_controller.dart';
import 'package:home_network_assistant/services/mock_api_service.dart';
import 'package:home_network_assistant/services/storage_service.dart';

import 'app_repository_test.dart';
import 'models/fake_asset_bundle.dart';

void main() {
  testWidgets('logs in, selects project and shows paged device list', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final controller = AppController(
      repository: AppRepository(
        apiService: MockApiService(
          bundle: FakeAssetBundle({
            ...buildSeed(),
            'devices': List.generate(
              7,
              (index) => {
                'id': index + 1,
                'projectId': 1,
                'name': 'Device ${index + 1}',
                'type': 'phone',
                'ipAddress': '192.168.1.${index + 1}',
                'macAddress': 'AA:BB:CC:DD:EE:${(index + 1).toString().padLeft(2, '0')}',
                'connectionType': 'wifi',
                'room': 'Гостиная',
                'status': 'active',
                'signalStrength': 80,
                'speedMbps': 200,
                'description': 'Device',
                'isFavorite': false,
                'isDeleted': false,
                'createdBy': 'admin',
                'createdAt': '2026-05-21T10:00:00.000',
                'isGuest': false,
                'requiresStaticIp': false,
              },
            ),
            'deviceRequests': [],
            'notifications': [],
          }),
          delay: Duration.zero,
        ),
        storageService: StorageService(),
      ),
    );

    await tester.pumpWidget(HomeNetworkAssistantApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(find.text('Проекты сети'), findsOneWidget);
    await tester.tap(find.text('Домашняя сеть'));
    await tester.pumpAndSettle();

    expect(find.text('Устройства сети'), findsOneWidget);
    expect(find.text('Device 1'), findsOneWidget);
    expect(find.text('Device 5'), findsOneWidget);
    expect(find.text('Device 6'), findsNothing);

    controller.showMoreDevices();
    await tester.pumpAndSettle();

    expect(controller.pagedDevices, hasLength(7));
  });

  testWidgets('user login shows sent requests section in drawer', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final controller = AppController(
      repository: AppRepository(
        apiService: MockApiService(
          bundle: FakeAssetBundle(buildSeed()),
          delay: Duration.zero,
        ),
        storageService: StorageService(),
      ),
    );

    await tester.pumpWidget(HomeNetworkAssistantApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user');
    await tester.enterText(find.byType(TextFormField).at(1), 'user123');
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Отправленные запросы'), findsOneWidget);
    expect(find.text('Мои устройства'), findsOneWidget);
  });
}
