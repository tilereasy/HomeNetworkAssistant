import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:home_network_assistant/models/network_device.dart';
import 'package:home_network_assistant/models/router_settings.dart';
import 'package:home_network_assistant/models/user.dart';
import 'package:home_network_assistant/repositories/app_repository.dart';
import 'package:home_network_assistant/services/app_controller.dart';
import 'package:home_network_assistant/services/http_api_service.dart';
import 'package:home_network_assistant/services/storage_service.dart';

import 'models/fake_api_backend.dart';

Map<String, dynamic> buildSeed() {
  return {
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
        'savedSettings': {'theme': 'light'},
      },
      {
        'id': 2,
        'login': 'user',
        'password': 'user123',
        'role': 'user',
        'lastLogin': null,
        'favoriteDeviceIds': [],
        'savedSettings': {'theme': 'light'},
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
        'createdAt': '2026-05-21T10:00:00.000Z',
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
        'createdAt': '2026-05-21T11:00:00.000Z',
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
        'createdAt': '2026-05-21T11:00:00.000Z',
        'updatedAt': '2026-05-21T11:00:00.000Z',
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
        'createdAt': '2026-05-21T11:00:00.000Z',
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
  late User adminUser;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final backend = FakeApiBackend(buildSeed());
    repository = AppRepository(
      apiService: HttpApiService(
        baseUrl: 'http://localhost',
        client: MockClient(backend.handle),
      ),
      storageService: StorageService(),
    );
    adminUser = const User(
      id: 1,
      login: 'admin',
      role: UserRole.admin,
      lastLogin: null,
      savedSettings: {'theme': 'light'},
    );
  });

  test('logs in and loads project data from http api', () async {
    final loggedInUser = await repository.login('admin', 'admin123');
    final data = await repository.loadData(currentUser: loggedInUser);

    expect(loggedInUser.isAdmin, isTrue);
    expect(data.projects, hasLength(1));
    expect(data.devices, hasLength(2));
    expect(data.currentProjectId, 1);
  });

  test('toggles favorite, moves to trash and restores device via http api', () async {
    var data = await repository.loadData(currentUser: adminUser);

    data = await repository.toggleFavorite(data, 1, adminUser);
    expect(data.devices.firstWhere((item) => item.id == 1).isFavorite, isTrue);

    data = await repository.moveToTrash(data, 1, adminUser);
    expect(data.devices.firstWhere((item) => item.id == 1).isDeleted, isTrue);

    data = await repository.restoreDevice(data, 1, adminUser);
    expect(data.devices.firstWhere((item) => item.id == 1).isDeleted, isFalse);
  });

  test('approve request updates device and request status from http api', () async {
    final controller = AppController(repository: repository);
    await controller.initialize();
    await controller.login('admin', 'admin123');
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

  test('router settings save dhcp range through http api', () async {
    var data = await repository.loadData(currentUser: adminUser);
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
      adminUser,
    );

    expect(data.routerSettings.single.dhcpRange, '192.168.1.2 - 192.168.1.50');
  });

  test('user resend request creates new pending request entry', () async {
    final controller = AppController(repository: repository);
    await controller.initialize();
    await controller.login('user', 'user123');
    await controller.selectProject(1);

    await controller.resendDeviceRequest(
      controller.data.devices.firstWhere((item) => item.id == 2),
    );

    expect(
      controller.myRequests.where((item) => item.deviceId == 2),
      hasLength(2),
    );
    expect(
      controller.data.devices.firstWhere((item) => item.id == 2).status,
      DeviceStatus.pending,
    );
  });
}
