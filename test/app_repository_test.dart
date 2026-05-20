import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:home_network_assistant/models/network_device.dart';
import 'package:home_network_assistant/repositories/app_repository.dart';
import 'package:home_network_assistant/services/mock_api_service.dart';
import 'package:home_network_assistant/services/storage_service.dart';

import 'models/fake_asset_bundle.dart';

void main() {
  const seedData = {
    'users': [
      {'id': 1, 'login': 'admin', 'password': 'admin123', 'role': 'admin'},
      {'id': 2, 'login': 'user', 'password': 'user123', 'role': 'user'},
    ],
    'devices': [
      {
        'id': 1,
        'name': 'Router',
        'type': 'router',
        'ipAddress': '192.168.1.1',
        'macAddress': 'AA:01',
        'connectionType': 'ethernet',
        'room': 'Прихожая',
        'status': 'active',
        'signalStrength': 100,
        'speedMbps': 1000,
        'description': 'Main',
        'isFavorite': false,
        'isDeleted': false,
        'createdBy': 'admin',
        'createdAt': '2026-05-21T10:00:00.000',
        'isGuest': false,
        'requiresStaticIp': true,
      },
      {
        'id': 2,
        'name': 'Laptop',
        'type': 'laptop',
        'ipAddress': '192.168.1.2',
        'macAddress': 'AA:02',
        'connectionType': 'wifi',
        'room': 'Кабинет',
        'status': 'pending',
        'signalStrength': 70,
        'speedMbps': 300,
        'description': 'Work',
        'isFavorite': false,
        'isDeleted': false,
        'createdBy': 'user',
        'createdAt': '2026-05-21T11:00:00.000',
        'isGuest': false,
        'requiresStaticIp': false,
      },
    ],
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
  };

  late AppRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = AppRepository(
      apiService: MockApiService(
        bundle: FakeAssetBundle(seedData),
        delay: Duration.zero,
      ),
      storageService: StorageService(),
    );
  });

  test('loads seed data and authenticates users', () async {
    final data = await repository.loadData();

    expect(data.devices, hasLength(2));
    expect(repository.authenticate(data.users, 'admin', 'admin123')?.isAdmin, isTrue);
    expect(repository.authenticate(data.users, 'user', 'wrong'), isNull);
  });

  test('toggles favorite, moves to trash and restores device', () async {
    var data = await repository.loadData();

    data = await repository.toggleFavorite(data, 1);
    expect(data.devices.firstWhere((item) => item.id == 1).isFavorite, isTrue);

    data = await repository.moveToTrash(data, 1);
    expect(data.devices.firstWhere((item) => item.id == 1).isDeleted, isTrue);

    data = await repository.restoreDevice(data, 1);
    expect(data.devices.firstWhere((item) => item.id == 1).isDeleted, isFalse);
  });

  test('updates device request status', () async {
    var data = await repository.loadData();
    final device = data.devices.firstWhere((item) => item.id == 2);

    data = await repository.updateDevice(
      data,
      device.copyWith(status: DeviceStatus.active),
    );

    expect(
      data.devices.firstWhere((item) => item.id == 2).status,
      DeviceStatus.active,
    );
  });
}
