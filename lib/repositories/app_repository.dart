import '../models/app_data.dart';
import '../models/device_request.dart';
import '../models/network_device.dart';
import '../models/network_project.dart';
import '../models/notification_item.dart';
import '../models/router_settings.dart';
import '../models/user.dart';
import '../services/mock_api_service.dart';
import '../services/storage_service.dart';

class AppRepository {
  const AppRepository({
    required this.apiService,
    required this.storageService,
  });

  final MockApiService apiService;
  final StorageService storageService;

  Future<AppData> loadData() async {
    final stored = await storageService.loadSnapshot();
    if (stored != null) {
      return stored;
    }

    final seed = await apiService.fetchSeedData();
    await storageService.saveSnapshot(seed);
    return seed;
  }

  User? authenticate(List<User> users, String login, String password) {
    for (final user in users) {
      if (user.login == login && user.password == password) {
        return user;
      }
    }
    return null;
  }

  Future<AppData> save(AppData data) async {
    await storageService.saveSnapshot(data);
    return data;
  }

  Future<AppData> upsertUser(AppData data, User user) async {
    final users = data.users.map((item) => item.id == user.id ? user : item).toList();
    return save(data.copyWith(users: users));
  }

  Future<AppData> addProject(AppData data, NetworkProject project, RouterSettings settings) async {
    return save(
      data.copyWith(
        projects: [...data.projects, project],
        routerSettings: [...data.routerSettings, settings],
        currentProjectId: project.id,
      ),
    );
  }

  Future<AppData> setCurrentProject(AppData data, int projectId) async {
    return save(data.copyWith(currentProjectId: projectId));
  }

  Future<AppData> addDevice(AppData data, NetworkDevice device) async {
    return save(data.copyWith(devices: [...data.devices, device]));
  }

  Future<AppData> updateDevice(AppData data, NetworkDevice device) async {
    final devices = data.devices.map((item) => item.id == device.id ? device : item).toList();
    return save(data.copyWith(devices: devices));
  }

  Future<AppData> toggleFavorite(AppData data, int deviceId, User user) async {
    final devices = data.devices
        .map(
          (item) => item.id == deviceId
              ? item.copyWith(isFavorite: !item.isFavorite)
              : item,
        )
        .toList();
    final updatedDevice = devices.firstWhere((item) => item.id == deviceId);
    final favoriteIds = [...user.favoriteDeviceIds];
    if (updatedDevice.isFavorite) {
      if (!favoriteIds.contains(deviceId)) {
        favoriteIds.add(deviceId);
      }
    } else {
      favoriteIds.remove(deviceId);
    }
    final users = data.users
        .map(
          (item) => item.id == user.id ? item.copyWith(favoriteDeviceIds: favoriteIds) : item,
        )
        .toList();
    return save(data.copyWith(devices: devices, users: users));
  }

  Future<AppData> moveToTrash(AppData data, int deviceId) async {
    final devices = data.devices
        .map(
          (item) => item.id == deviceId
              ? item.copyWith(isDeleted: true, isFavorite: false)
              : item,
        )
        .toList();
    return save(data.copyWith(devices: devices));
  }

  Future<AppData> restoreDevice(AppData data, int deviceId) async {
    final devices = data.devices
        .map((item) => item.id == deviceId ? item.copyWith(isDeleted: false) : item)
        .toList();
    return save(data.copyWith(devices: devices));
  }

  Future<AppData> addDeviceRequest(AppData data, DeviceRequest request) async {
    return save(data.copyWith(deviceRequests: [...data.deviceRequests, request]));
  }

  Future<AppData> updateDeviceRequest(AppData data, DeviceRequest request) async {
    final requests = data.deviceRequests
        .map((item) => item.id == request.id ? request : item)
        .toList();
    return save(data.copyWith(deviceRequests: requests));
  }

  Future<AppData> markNotificationRead(AppData data, int notificationId) async {
    final notifications = data.notifications
        .map(
          (item) => item.id == notificationId ? item.copyWith(isRead: true) : item,
        )
        .toList();
    return save(data.copyWith(notifications: notifications));
  }

  Future<AppData> addNotification(AppData data, NotificationItem notification) async {
    return save(data.copyWith(notifications: [notification, ...data.notifications]));
  }

  Future<AppData> updateRouterSettings(
    AppData data,
    RouterSettings routerSettings,
  ) async {
    final settings = data.routerSettings
        .map((item) => item.projectId == routerSettings.projectId ? routerSettings : item)
        .toList();
    return save(data.copyWith(routerSettings: settings));
  }
}
