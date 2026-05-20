import 'package:flutter/material.dart';

import '../models/app_data.dart';
import '../models/device_request.dart';
import '../models/network_device.dart';
import '../models/network_project.dart';
import '../models/notification_item.dart';
import '../models/router_settings.dart';
import '../models/user.dart';
import '../repositories/app_repository.dart';

enum AppSection {
  projects,
  devices,
  myDevices,
  favorites,
  requests,
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
  AppSection _section = AppSection.projects;
  int _visibleDevicesCount = 5;
  String? _loginError;
  String _deviceTypeFilter = 'all';
  String _deviceRoomFilter = 'all';

  AppData get data => _data!;
  User? get currentUser => _currentUser;
  AppSection get section => _section;
  int get visibleDevicesCount => _visibleDevicesCount;
  String? get loginError => _loginError;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  String get deviceTypeFilter => _deviceTypeFilter;
  String get deviceRoomFilter => _deviceRoomFilter;

  Future<void> initialize() async {
    _data = await repository.loadData();
    notifyListeners();
  }

  NetworkProject get currentProject {
    return data.projects.firstWhere((item) => item.id == data.currentProjectId);
  }

  RouterSettings get currentRouterSettings {
    return data.routerSettings.firstWhere(
      (item) => item.projectId == currentProject.id,
      orElse: () => data.routerSettings.first,
    );
  }

  List<String> get deviceTypeOptions {
    final values = currentProjectDevices.map((device) => device.type).toSet().toList()..sort();
    return ['all', ...values];
  }

  List<String> get roomOptions {
    final values = currentProjectDevices.map((device) => device.room).toSet().toList()..sort();
    return ['all', ...values];
  }

  List<NetworkDevice> get currentProjectDevices {
    return data.devices.where((device) => device.projectId == currentProject.id).toList();
  }

  List<NetworkDevice> get activeDevices {
    return currentProjectDevices.where((device) => !device.isDeleted).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<NetworkDevice> get myDevices {
    final login = currentUser?.login;
    return activeDevices.where((device) => device.createdBy == login).toList();
  }

  List<NetworkDevice> get trashDevices {
    return currentProjectDevices.where((device) => device.isDeleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<NetworkDevice> get favoriteDevices {
    return activeDevices.where((device) => device.isFavorite).toList();
  }

  List<DeviceRequest> get currentProjectRequests {
    return data.deviceRequests.where((request) => request.projectId == currentProject.id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<DeviceRequest> get myRequests {
    final login = currentUser?.login;
    return currentProjectRequests.where((request) => request.requesterLogin == login).toList();
  }

  List<NotificationItem> get visibleNotifications {
    final role = _currentUser?.role;
    if (role == null) {
      return const [];
    }

    return data.notifications
        .where((item) => item.targetRole == role && item.projectId == currentProject.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int get unreadNotificationsCount {
    return visibleNotifications.where((item) => !item.isRead).length;
  }

  List<NetworkDevice> get filteredDevices {
    return activeDevices.where((device) {
      final typeOk = _deviceTypeFilter == 'all' || device.type == _deviceTypeFilter;
      final roomOk = _deviceRoomFilter == 'all' || device.room == _deviceRoomFilter;
      return typeOk && roomOk;
    }).toList();
  }

  List<NetworkDevice> get pagedDevices {
    final devices = filteredDevices;
    final count = _visibleDevicesCount.clamp(0, devices.length);
    return devices.take(count).toList();
  }

  void setSection(AppSection section) {
    _section = section;
    notifyListeners();
  }

  void setDeviceFilters({String? type, String? room}) {
    if (type != null) {
      _deviceTypeFilter = type;
    }
    if (room != null) {
      _deviceRoomFilter = room;
    }
    _visibleDevicesCount = 5;
    notifyListeners();
  }

  void resetDeviceFilters() {
    _deviceTypeFilter = 'all';
    _deviceRoomFilter = 'all';
    _visibleDevicesCount = 5;
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

    final updatedUser = user.copyWith(lastLogin: DateTime.now());
    _data = data.copyWith(
      users: data.users.map((item) => item.id == updatedUser.id ? updatedUser : item).toList(),
    );
    repository.save(data);
    _currentUser = updatedUser;
    _loginError = null;
    _section = AppSection.projects;
    _visibleDevicesCount = 5;
    repository.upsertUser(data, _currentUser!);
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _section = AppSection.projects;
    _visibleDevicesCount = 5;
    _loginError = null;
    notifyListeners();
  }

  int nextProjectId() {
    return data.projects.fold<int>(0, (maxId, item) => item.id > maxId ? item.id : maxId) + 1;
  }

  int nextDeviceId() {
    return data.devices.fold<int>(0, (maxId, item) => item.id > maxId ? item.id : maxId) + 1;
  }

  int nextRequestId() {
    return data.deviceRequests.fold<int>(0, (maxId, item) => item.id > maxId ? item.id : maxId) + 1;
  }

  int nextNotificationId() {
    return data.notifications.fold<int>(0, (maxId, item) => item.id > maxId ? item.id : maxId) + 1;
  }

  Future<void> selectProject(int projectId) async {
    _data = await repository.setCurrentProject(data, projectId);
    _section = AppSection.devices;
    _visibleDevicesCount = 5;
    resetDeviceFilters();
  }

  Future<void> createProject(NetworkProject project, RouterSettings settings) async {
    _data = await repository.addProject(data, project, settings);
    _section = AppSection.devices;
    _visibleDevicesCount = 5;
    resetDeviceFilters();
  }

  Future<void> addDevice(NetworkDevice draft) async {
    final actor = _currentUser!;
    final device = draft.copyWith(
      id: nextDeviceId(),
      projectId: currentProject.id,
      createdBy: actor.login,
      createdAt: DateTime.now(),
      status: actor.isAdmin ? draft.status : DeviceStatus.pending,
    );
    _data = await repository.addDevice(data, device);

    if (!actor.isAdmin) {
      final request = DeviceRequest(
        id: nextRequestId(),
        projectId: currentProject.id,
        deviceId: device.id,
        requesterLogin: actor.login,
        status: DeviceRequestStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _data = await repository.addDeviceRequest(data, request);
      _data = await repository.addNotification(
        data,
        NotificationItem(
          id: nextNotificationId(),
          projectId: currentProject.id,
          title: 'Новый запрос на устройство',
          message:
              'Пользователь ${actor.login} хочет добавить устройство "${device.name}"',
          targetRole: UserRole.admin,
          isRead: false,
          createdAt: DateTime.now(),
          actionType: NotificationActionType.deviceRequest,
          relatedDeviceId: device.id,
        ),
      );
    }

    notifyListeners();
  }

  Future<void> updateDevice(NetworkDevice device) async {
    _data = await repository.updateDevice(data, device);
    notifyListeners();
  }

  Future<void> resendDeviceRequest(NetworkDevice device) async {
    final updated = device.copyWith(status: DeviceStatus.pending);
    _data = await repository.updateDevice(data, updated);
    final request = DeviceRequest(
      id: nextRequestId(),
      projectId: currentProject.id,
      deviceId: device.id,
      requesterLogin: currentUser!.login,
      status: DeviceRequestStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _data = await repository.addDeviceRequest(data, request);
    _data = await repository.addNotification(
      data,
      NotificationItem(
        id: nextNotificationId(),
        projectId: currentProject.id,
        title: 'Повторный запрос на устройство',
        message:
            'Пользователь ${currentUser!.login} повторно отправил запрос на "${device.name}"',
        targetRole: UserRole.admin,
        isRead: false,
        createdAt: DateTime.now(),
        actionType: NotificationActionType.deviceRequest,
        relatedDeviceId: device.id,
      ),
    );
    notifyListeners();
  }

  Future<void> toggleFavorite(int deviceId) async {
    _data = await repository.toggleFavorite(data, deviceId, currentUser!);
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
    required int requestId,
    required int notificationId,
    required int deviceId,
    required bool approve,
  }) async {
    final device = data.devices.firstWhere((item) => item.id == deviceId);
    final request = data.deviceRequests.firstWhere((item) => item.id == requestId);
    _data = await repository.updateDevice(
      data,
      device.copyWith(status: approve ? DeviceStatus.active : DeviceStatus.rejected),
    );
    _data = await repository.updateDeviceRequest(
      data,
      request.copyWith(
        status: approve ? DeviceRequestStatus.approved : DeviceRequestStatus.rejected,
        updatedAt: DateTime.now(),
      ),
    );
    _data = await repository.markNotificationRead(data, notificationId);
    _data = await repository.addNotification(
      data,
      NotificationItem(
        id: nextNotificationId(),
        projectId: currentProject.id,
        title: approve ? 'Запрос одобрен' : 'Запрос отклонён',
        message: approve
            ? 'Устройство "${device.name}" одобрено администратором.'
            : 'Устройство "${device.name}" отклонено администратором.',
        targetRole: UserRole.user,
        isRead: false,
        createdAt: DateTime.now(),
        actionType: NotificationActionType.info,
        relatedDeviceId: device.id,
      ),
    );
    notifyListeners();
  }

  Future<void> saveRouterSettings(RouterSettings settings) async {
    _data = await repository.updateRouterSettings(data, settings);
    notifyListeners();
  }
}
