import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:home_network_assistant/app.dart';
import 'package:home_network_assistant/repositories/app_repository.dart';
import 'package:home_network_assistant/services/app_controller.dart';
import 'package:home_network_assistant/services/mock_api_service.dart';
import 'package:home_network_assistant/services/storage_service.dart';

import 'models/fake_asset_bundle.dart';

void main() {
  testWidgets('logs in and shows paged device list', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final controller = AppController(
      repository: AppRepository(
        apiService: MockApiService(
          bundle: FakeAssetBundle({
            'users': [
              {'id': 1, 'login': 'admin', 'password': 'admin123', 'role': 'admin'},
              {'id': 2, 'login': 'user', 'password': 'user123', 'role': 'user'},
            ],
            'devices': List.generate(
              7,
              (index) => {
                'id': index + 1,
                'name': 'Device ${index + 1}',
                'type': 'phone',
                'ipAddress': '192.168.1.${index + 1}',
                'macAddress': 'AA:${index + 1}',
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
            'notifications': [],
            'routerSettings': {
              'ssid': 'Home',
              'password': 'pass',
              'band': '5 GHz',
              'channel': '36',
              'dhcpEnabled': true,
              'guestNetworkEnabled': false,
              'hiddenSsid': false,
              'maxDevices': 20,
            },
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

    expect(find.text('Устройства сети'), findsOneWidget);
    expect(find.text('Device 1'), findsOneWidget);
    expect(find.text('Device 5'), findsOneWidget);
    expect(find.text('Device 6'), findsNothing);
    expect(find.text('Показать ещё 5'), findsOneWidget);

    controller.showMoreDevices();
    await tester.pumpAndSettle();

    expect(find.text('Device 6'), findsOneWidget);
    expect(controller.pagedDevices, hasLength(7));
  });
}
