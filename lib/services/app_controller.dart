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
  String? _operationError;
  bool _isBusy = false;
  String _deviceTypeFilter = 'all';
  String _deviceRoomFilter = 'all';

  AppData get data => _data!;
  User? get currentUser => _currentUser;
  AppSection get section => _section;
  int get visibleDevicesCount => _visibleDevicesCount;
  String? get loginError => _loginError;
  String? get operationError => _operationError;
  bool get isBusy => _isBusy;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  String get deviceTypeFilter => _deviceTypeFilter;
  String get deviceRoomFilter => _deviceRoomFilter;

  Future<void> initialize() async {
    _currentUser = await repository.loadSessionUser();
    if (_currentUser == null) {
      _data = AppData.empty();
      notifyListeners();
      return;
    }

    _data = await repository.loadData(currentUser: _currentUser!);
    _currentUser = data.users.firstWhere(
      (item) => item.id == _currentUser!.id,
      orElse: () => _currentUser!,
    );
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
    if (data.currentProjectId == 0) {
      return const [];
    }
    return data.deviceRequests.where((request) => request.projectId == data.currentProjectId).toList()
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
        .where((item) => item.targetRole == role && item.projectId == data.currentProjectId)
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

  Future<bool> login(String login, String password) async {
    _setBusy(true);
    try {
      final user = await repository.login(login, password);
      _currentUser = user;
      _data = await repository.loadData(currentUser: user);
      _currentUser = data.users.firstWhere(
        (item) => item.id == user.id,
        orElse: () => user,
      );
      _loginError = null;
      _operationError = null;
      _section = AppSection.projects;
      _visibleDevicesCount = 5;
      notifyListeners();
      return true;
    } catch (error) {
      _loginError = 'Неверный логин или пароль';
      _operationError = error.toString();
      notifyListeners();
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _data = AppData.empty();
    _section = AppSection.projects;
    _visibleDevicesCount = 5;
    _loginError = null;
    _operationError = null;
    await repository.clearSession();
    notifyListeners();
  }

  int nextProjectId() {
    return data.projects.fold<int>(0, (maxId, item) => item.id > maxId ? item.id : maxId) + 1;
  }

  int nextDeviceId() {
    return data.devices.fold<int>(0, (maxId, item) => item.id > maxId ? item.id : maxId) + 1;
  }

  Future<void> selectProject(int projectId) async {
    await _runMutation(() async {
      _data = await repository.setCurrentProject(data, projectId, currentUser!);
      _currentUser = data.users.firstWhere(
        (item) => item.id == currentUser!.id,
        orElse: () => currentUser!,
      );
      _section = AppSection.devices;
      _visibleDevicesCount = 5;
      _deviceTypeFilter = 'all';
      _deviceRoomFilter = 'all';
      notifyListeners();
    });
  }

  Future<void> createProject(NetworkProject project, RouterSettings settings) async {
    await _runMutation(() async {
      _data = await repository.addProject(data, project, currentUser!);
      _currentUser = data.users.firstWhere(
        (item) => item.id == currentUser!.id,
        orElse: () => currentUser!,
      );
      _section = AppSection.devices;
      _visibleDevicesCount = 5;
      _deviceTypeFilter = 'all';
      _deviceRoomFilter = 'all';
      notifyListeners();
    });
  }

  Future<void> addDevice(NetworkDevice draft) async {
    await _runMutation(() async {
      final actor = _currentUser!;
      final device = draft.copyWith(
        id: nextDeviceId(),
        projectId: currentProject.id,
        createdBy: actor.login,
        createdAt: DateTime.now(),
        status: actor.isAdmin ? draft.status : DeviceStatus.pending,
      );
      _data = await repository.addDevice(data, device, actor);
      _currentUser = data.users.firstWhere(
        (item) => item.id == actor.id,
        orElse: () => actor,
      );
      notifyListeners();
    });
  }

  Future<void> updateDevice(NetworkDevice device) async {
    await _runMutation(() async {
      _data = await repository.updateDevice(data, device, currentUser!);
      notifyListeners();
    });
  }

  Future<void> resendDeviceRequest(NetworkDevice device) async {
    await _runMutation(() async {
      _data = await repository.resendDeviceRequest(data, device.id, currentUser!);
      notifyListeners();
    });
  }

  Future<void> toggleFavorite(int deviceId) async {
    await _runMutation(() async {
      _data = await repository.toggleFavorite(data, deviceId, currentUser!);
      _currentUser = data.users.firstWhere(
        (item) => item.id == currentUser!.id,
        orElse: () => currentUser!,
      );
      notifyListeners();
    });
  }

  Future<void> moveToTrash(int deviceId) async {
    await _runMutation(() async {
      _data = await repository.moveToTrash(data, deviceId, currentUser!);
      notifyListeners();
    });
  }

  Future<void> restoreDevice(int deviceId) async {
    await _runMutation(() async {
      _data = await repository.restoreDevice(data, deviceId, currentUser!);
      notifyListeners();
    });
  }

  Future<void> markNotificationRead(int notificationId) async {
    await _runMutation(() async {
      _data = await repository.markNotificationRead(data, notificationId, currentUser!);
      notifyListeners();
    });
  }

  Future<void> decideDeviceRequest({
    required int requestId,
    required int notificationId,
    required int deviceId,
    required bool approve,
  }) async {
    await _runMutation(() async {
      _data = await repository.decideDeviceRequest(
        data,
        requestId: requestId,
        notificationId: notificationId,
        approve: approve,
        currentUser: currentUser!,
      );
      notifyListeners();
    });
  }

  Future<void> saveRouterSettings(RouterSettings settings) async {
    await _runMutation(() async {
      _data = await repository.updateRouterSettings(data, settings, currentUser!);
      notifyListeners();
    });
  }

  Future<void> _runMutation(Future<void> Function() action) async {
    _setBusy(true);
    _operationError = null;
    try {
      await action();
    } catch (error) {
      _operationError = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}
