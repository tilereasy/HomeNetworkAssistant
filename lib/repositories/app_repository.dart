import '../models/app_data.dart';
import '../models/network_device.dart';
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

  Future<AppData> addDevice(AppData data, NetworkDevice device) async {
    final updatedDevices = [...data.devices, device];
    final updated = data.copyWith(devices: updatedDevices);
    await storageService.saveSnapshot(updated);
    return updated;
  }

  Future<AppData> updateDevice(AppData data, NetworkDevice device) async {
    final updatedDevices = data.devices
        .map((item) => item.id == device.id ? device : item)
        .toList();
    final updated = data.copyWith(devices: updatedDevices);
    await storageService.saveSnapshot(updated);
    return updated;
  }

  Future<AppData> toggleFavorite(AppData data, int deviceId) async {
    final updatedDevices = data.devices
        .map(
          (item) => item.id == deviceId
              ? item.copyWith(isFavorite: !item.isFavorite)
              : item,
        )
        .toList();
    final updated = data.copyWith(devices: updatedDevices);
    await storageService.saveSnapshot(updated);
    return updated;
  }

  Future<AppData> moveToTrash(AppData data, int deviceId) async {
    final updatedDevices = data.devices
        .map(
          (item) => item.id == deviceId
              ? item.copyWith(isDeleted: true, isFavorite: false)
              : item,
        )
        .toList();
    final updated = data.copyWith(devices: updatedDevices);
    await storageService.saveSnapshot(updated);
    return updated;
  }

  Future<AppData> restoreDevice(AppData data, int deviceId) async {
    final updatedDevices = data.devices
        .map((item) => item.id == deviceId ? item.copyWith(isDeleted: false) : item)
        .toList();
    final updated = data.copyWith(devices: updatedDevices);
    await storageService.saveSnapshot(updated);
    return updated;
  }

  Future<AppData> markNotificationRead(AppData data, int notificationId) async {
    final updatedNotifications = data.notifications
        .map(
          (item) => item.id == notificationId ? item.copyWith(isRead: true) : item,
        )
        .toList();
    final updated = data.copyWith(notifications: updatedNotifications);
    await storageService.saveSnapshot(updated);
    return updated;
  }

  Future<AppData> addNotification(AppData data, NotificationItem notification) async {
    final updatedNotifications = [notification, ...data.notifications];
    final updated = data.copyWith(notifications: updatedNotifications);
    await storageService.saveSnapshot(updated);
    return updated;
  }

  Future<AppData> updateRouterSettings(
    AppData data,
    RouterSettings routerSettings,
  ) async {
    final updated = data.copyWith(routerSettings: routerSettings);
    await storageService.saveSnapshot(updated);
    return updated;
  }
}
