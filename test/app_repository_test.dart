import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:home_network_assistant/models/network_device.dart';
import 'package:home_network_assistant/models/router_settings.dart';
import 'package:home_network_assistant/repositories/app_repository.dart';
import 'package:home_network_assistant/services/app_controller.dart';
import 'package:home_network_assistant/services/mock_api_service.dart';
import 'package:home_network_assistant/services/storage_service.dart';

import 'models/fake_asset_bundle.dart';

Map<String, dynamic> buildSeed() {
  return {
    'currentProjectId': 1,
    'projects': [
      {
        'id': 1,
        'name': 'Домашняя сеть',
        'description': 'Сеть квартиры',
        'propertyType': 'Квартира',
        'roomCount': 3,
        'provider': 'NetHome',
        'primaryRouterName': 'Router',
      },
    ],
    'users': [
      {
        'id': 1,
        'login': 'admin',
        'password': 'admin123',
        'role': 'admin',
        'lastLogin': null,
        'favoriteDeviceIds': [],
        'savedSettings': {},
      },
      {
        'id': 2,
        'login': 'user',
        'password': 'user123',
        'role': 'user',
        'lastLogin': null,
        'favoriteDeviceIds': [],
        'savedSettings': {},
      },
    ],
    'devices': [
      {
        'id': 1,
        'projectId': 1,
        'name': 'Router',
        'type': 'router',
        'ipAddress': '192.168.1.1',
        'macAddress': 'AA:BB:CC:DD:EE:01',
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
        'projectId': 1,
        'name': 'Laptop',
        'type': 'laptop',
        'ipAddress': '192.168.1.2',
        'macAddress': 'AA:BB:CC:DD:EE:02',
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
    'deviceRequests': [
      {
        'id': 1,
        'projectId': 1,
        'deviceId': 2,
        'requesterLogin': 'user',
        'status': 'pending',
        'createdAt': '2026-05-21T11:00:00.000',
        'updatedAt': '2026-05-21T11:00:00.000',
      },
    ],
    'notifications': [
      {
        'id': 1,
        'projectId': 1,
        'title': 'Request',
        'message': 'New request',
        'targetRole': 'admin',
        'isRead': false,
        'createdAt': '2026-05-21T11:00:00.000',
        'actionType': 'deviceRequest',
        'relatedDeviceId': 2,
      },
    ],
    'routerSettings': [
      {
        'projectId': 1,
        'ssid': 'Home',
        'password': 'pass',
        'band': '5 GHz',
        'channel': '36',
        'dhcpEnabled': true,
        'dhcpRange': '192.168.1.100 - 192.168.1.200',
        'guestNetworkEnabled': false,
        'hiddenSsid': false,
        'maxDevices': 20,
      },
    ],
  };
}

void main() {
  late AppRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = AppRepository(
      apiService: MockApiService(
        bundle: FakeAssetBundle(buildSeed()),
        delay: Duration.zero,
      ),
      storageService: StorageService(),
    );
  });

  test('loads seed data and authenticates users', () async {
    final data = await repository.loadData();

    expect(data.projects, hasLength(1));
    expect(data.devices, hasLength(2));
    expect(repository.authenticate(data.users, 'admin', 'admin123')?.isAdmin, isTrue);
    expect(repository.authenticate(data.users, 'user', 'wrong'), isNull);
  });

  test('migrates old snapshot without projects into default project', () async {
    final oldSeed = {
      'users': buildSeed()['users'],
      'devices': [
        {
          ...((buildSeed()['devices'] as List).first as Map<String, dynamic>)
            ..remove('projectId'),
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
    final oldRepository = AppRepository(
      apiService: MockApiService(bundle: FakeAssetBundle(oldSeed), delay: Duration.zero),
      storageService: StorageService(),
    );

    final data = await oldRepository.loadData();

    expect(data.projects.single.name, 'Домашняя сеть');
    expect(data.currentProjectId, 1);
    expect(data.devices.single.projectId, 1);
    expect(data.routerSettings.single.projectId, 1);
  });

  test('toggles favorite, moves to trash and restores device', () async {
    var data = await repository.loadData();
    final user = data.users.firstWhere((item) => item.login == 'admin');

    data = await repository.toggleFavorite(data, 1, user);
    expect(data.devices.firstWhere((item) => item.id == 1).isFavorite, isTrue);

    data = await repository.moveToTrash(data, 1);
    expect(data.devices.firstWhere((item) => item.id == 1).isDeleted, isTrue);

    data = await repository.restoreDevice(data, 1);
    expect(data.devices.firstWhere((item) => item.id == 1).isDeleted, isFalse);
  });

  test('approve request updates device and request status', () async {
    final controller = AppController(repository: repository);
    await controller.initialize();
    controller.login('admin', 'admin123');
    await controller.selectProject(1);

    await controller.decideDeviceRequest(
      requestId: 1,
      notificationId: 1,
      deviceId: 2,
      approve: true,
    );

    expect(
      controller.data.devices.firstWhere((item) => item.id == 2).status,
      DeviceStatus.active,
    );
    expect(controller.currentProjectRequests.first.status.name, 'approved');
  });

  test('router settings save dhcp range', () async {
    var data = await repository.loadData();
    data = await repository.updateRouterSettings(
      data,
      const RouterSettings(
        projectId: 1,
        ssid: 'NewHome',
        password: 'pass',
        band: '2.4 GHz',
        channel: '11',
        dhcpEnabled: false,
        dhcpRange: '192.168.1.2 - 192.168.1.50',
        guestNetworkEnabled: true,
        hiddenSsid: false,
        maxDevices: 10,
      ),
    );

    expect(data.routerSettings.single.dhcpRange, '192.168.1.2 - 192.168.1.50');
  });
}
