import 'package:flutter/material.dart';

import '../models/app_data.dart';
import '../models/network_device.dart';
import '../models/notification_item.dart';
import '../models/router_settings.dart';
import '../models/user.dart';
import '../repositories/app_repository.dart';

enum AppSection {
  devices,
  favorites,
  trash,
  networkMap,
  routerSettings,
  recommendations,
  notifications,
  profile,
  about,
}

class AppController extends ChangeNotifier {
  AppController({required this.repository});

  final AppRepository repository;

  AppData? _data;
  User? _currentUser;
  AppSection _section = AppSection.devices;
  int _visibleDevicesCount = 5;
  String? _loginError;

  AppData get data => _data!;
  User? get currentUser => _currentUser;
  AppSection get section => _section;
  int get visibleDevicesCount => _visibleDevicesCount;
  String? get loginError => _loginError;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> initialize() async {
    _data = await repository.loadData();
    notifyListeners();
  }

  List<NetworkDevice> get activeDevices {
    return data.devices.where((device) => !device.isDeleted).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<NetworkDevice> get trashDevices {
    return data.devices.where((device) => device.isDeleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<NetworkDevice> get favoriteDevices {
    return activeDevices.where((device) => device.isFavorite).toList();
  }

  List<NotificationItem> get visibleNotifications {
    final role = _currentUser?.role;
    if (role == null) {
      return const [];
    }

    return data.notifications
        .where((item) => item.targetRole == role)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int get unreadNotificationsCount {
    return visibleNotifications.where((item) => !item.isRead).length;
  }

  List<NetworkDevice> get pagedDevices {
    final devices = activeDevices;
    final count = _visibleDevicesCount.clamp(0, devices.length);
    return devices.take(count).toList();
  }

  void setSection(AppSection section) {
    _section = section;
    notifyListeners();
  }

  void showMoreDevices() {
    _visibleDevicesCount += 5;
    notifyListeners();
  }

  bool login(String login, String password) {
    final user = repository.authenticate(data.users, login, password);
    if (user == null) {
      _loginError = 'Неверный логин или пароль';
      notifyListeners();
      return false;
    }

    _currentUser = user;
    _loginError = null;
    _section = AppSection.devices;
    _visibleDevicesCount = 5;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _section = AppSection.devices;
    _visibleDevicesCount = 5;
    _loginError = null;
    notifyListeners();
  }

  int nextDeviceId() {
    return data.devices.fold<int>(
          0,
          (maxId, device) => device.id > maxId ? device.id : maxId,
        ) +
        1;
  }

  int nextNotificationId() {
    return data.notifications.fold<int>(
          0,
          (maxId, item) => item.id > maxId ? item.id : maxId,
        ) +
        1;
  }

  Future<void> addDevice(NetworkDevice draft) async {
    final actor = _currentUser!;
    final device = actor.isAdmin
        ? draft.copyWith(
            id: nextDeviceId(),
            createdBy: actor.login,
            createdAt: DateTime.now(),
          )
        : draft.copyWith(
            id: nextDeviceId(),
            createdBy: actor.login,
            createdAt: DateTime.now(),
            status: DeviceStatus.pending,
          );

    _data = await repository.addDevice(data, device);

    if (!actor.isAdmin) {
      final notification = NotificationItem(
        id: nextNotificationId(),
        title: 'Новый запрос на устройство',
        message:
            'Пользователь ${actor.login} хочет добавить устройство "${device.name}"',
        targetRole: UserRole.admin,
        isRead: false,
        createdAt: DateTime.now(),
        actionType: NotificationActionType.deviceRequest,
        relatedDeviceId: device.id,
      );
      _data = await repository.addNotification(data, notification);
    }

    notifyListeners();
  }

  Future<void> updateDevice(NetworkDevice device) async {
    _data = await repository.updateDevice(data, device);
    notifyListeners();
  }

  Future<void> toggleFavorite(int deviceId) async {
    _data = await repository.toggleFavorite(data, deviceId);
    notifyListeners();
  }

  Future<void> moveToTrash(int deviceId) async {
    _data = await repository.moveToTrash(data, deviceId);
    notifyListeners();
  }

  Future<void> restoreDevice(int deviceId) async {
    _data = await repository.restoreDevice(data, deviceId);
    notifyListeners();
  }

  Future<void> markNotificationRead(int notificationId) async {
    _data = await repository.markNotificationRead(data, notificationId);
    notifyListeners();
  }

  Future<void> decideDeviceRequest({
    required int notificationId,
    required int deviceId,
    required bool approve,
  }) async {
    final device = data.devices.firstWhere((item) => item.id == deviceId);
    final updatedDevice = device.copyWith(
      status: approve ? DeviceStatus.active : DeviceStatus.rejected,
    );
    _data = await repository.updateDevice(data, updatedDevice);
    _data = await repository.markNotificationRead(data, notificationId);
    notifyListeners();
  }

  Future<void> saveRouterSettings(RouterSettings settings) async {
    _data = await repository.updateRouterSettings(data, settings);
    notifyListeners();
  }
}
