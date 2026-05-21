import '../models/app_data.dart';
import '../models/network_device.dart';
import '../models/network_project.dart';
import '../models/router_settings.dart';
import '../models/user.dart';
import '../services/http_api_service.dart';
import '../services/storage_service.dart';

class AppRepository {
  const AppRepository({
    required this.apiService,
    required this.storageService,
  });

  final HttpApiService apiService;
  final StorageService storageService;

  Future<bool> checkBackendConnection() {
    return apiService.checkConnection();
  }

  Future<User?> loadSessionUser() {
    return storageService.loadSessionUser();
  }

  Future<void> clearSession() async {
    await storageService.clearSession();
    await storageService.clearCurrentProjectId();
  }

  Future<User> login(String login, String password) async {
    final user = await apiService.login(login, password);
    await storageService.saveSessionUser(user);
    return user;
  }

  Future<AppData> loadData({required User currentUser}) async {
    final users = await apiService.fetchUsers();
    final projects = await apiService.fetchProjects(userLogin: currentUser.login);

    if (projects.isEmpty) {
      return AppData.empty().copyWith(users: _mergeUsers(users, currentUser));
    }

    final storedProjectId = await storageService.loadCurrentProjectId();
    final selectedProjectId = projects.any((item) => item.id == storedProjectId)
        ? storedProjectId!
        : projects.first.id;
    await storageService.saveCurrentProjectId(selectedProjectId);

    return _loadProjectScopedData(
      projects: projects,
      users: _mergeUsers(users, currentUser),
      currentUser: currentUser,
      projectId: selectedProjectId,
    );
  }

  Future<AppData> setCurrentProject(AppData data, int projectId, User currentUser) async {
    await storageService.saveCurrentProjectId(projectId);
    return _loadProjectScopedData(
      projects: data.projects,
      users: _mergeUsers(data.users, currentUser),
      currentUser: currentUser,
      projectId: projectId,
    );
  }

  Future<AppData> addProject(AppData data, NetworkProject project, User currentUser) async {
    final created = await apiService.createProject(project, userLogin: currentUser.login);
    await storageService.saveCurrentProjectId(created.id);
    final projects = await apiService.fetchProjects(userLogin: currentUser.login);
    return _loadProjectScopedData(
      projects: projects,
      users: _mergeUsers(data.users, currentUser),
      currentUser: currentUser,
      projectId: created.id,
    );
  }

  Future<AppData> addDevice(AppData data, NetworkDevice device, User currentUser) async {
    await apiService.createDevice(
      data.currentProjectId,
      device,
      userLogin: currentUser.login,
    );
    return refreshCurrentProject(data, currentUser);
  }

  Future<AppData> updateDevice(AppData data, NetworkDevice device, User currentUser) async {
    await apiService.updateDevice(device, userLogin: currentUser.login);
    return refreshCurrentProject(data, currentUser);
  }

  Future<AppData> resendDeviceRequest(AppData data, int deviceId, User currentUser) async {
    await apiService.resendDeviceRequest(deviceId, userLogin: currentUser.login);
    return refreshCurrentProject(data, currentUser);
  }

  Future<AppData> toggleFavorite(AppData data, int deviceId, User currentUser) async {
    await apiService.toggleFavorite(deviceId, userLogin: currentUser.login);
    return refreshCurrentProject(data, currentUser);
  }

  Future<AppData> moveToTrash(AppData data, int deviceId, User currentUser) async {
    await apiService.moveToTrash(deviceId, userLogin: currentUser.login);
    return refreshCurrentProject(data, currentUser);
  }

  Future<AppData> restoreDevice(AppData data, int deviceId, User currentUser) async {
    await apiService.restoreDevice(deviceId, userLogin: currentUser.login);
    return refreshCurrentProject(data, currentUser);
  }

  Future<AppData> markNotificationRead(AppData data, int notificationId, User currentUser) async {
    await apiService.markNotificationRead(notificationId, userLogin: currentUser.login);
    return refreshCurrentProject(data, currentUser);
  }

  Future<AppData> decideDeviceRequest(
    AppData data, {
    required int requestId,
    required int notificationId,
    required bool approve,
    required User currentUser,
  }) async {
    if (approve) {
      await apiService.approveRequest(requestId, userLogin: currentUser.login);
    } else {
      await apiService.rejectRequest(requestId, userLogin: currentUser.login);
    }

    if (notificationId > 0) {
      await apiService.markNotificationRead(notificationId, userLogin: currentUser.login);
    }

    return refreshCurrentProject(data, currentUser);
  }

  Future<AppData> updateRouterSettings(
    AppData data,
    RouterSettings routerSettings,
    User currentUser,
  ) async {
    await apiService.updateRouterSettings(routerSettings, userLogin: currentUser.login);
    return refreshCurrentProject(data, currentUser);
  }

  Future<AppData> refreshCurrentProject(AppData data, User currentUser) {
    return _loadProjectScopedData(
      projects: data.projects,
      users: _mergeUsers(data.users, currentUser),
      currentUser: currentUser,
      projectId: data.currentProjectId,
    );
  }

  Future<AppData> _loadProjectScopedData({
    required List<NetworkProject> projects,
    required List<User> users,
    required User currentUser,
    required int projectId,
  }) async {
    final devices = await apiService.fetchDevices(projectId, userLogin: currentUser.login);
    final requests = await apiService.fetchRequests(projectId, userLogin: currentUser.login);
    final notifications = await apiService.fetchNotifications(
      projectId,
      userLogin: currentUser.login,
    );
    final routerSettings = await apiService.fetchRouterSettings(
      projectId,
      userLogin: currentUser.login,
    );

    final favoriteIds = devices.where((item) => item.isFavorite).map((item) => item.id).toList();
    final effectiveCurrentUser = currentUser.copyWith(favoriteDeviceIds: favoriteIds);
    await storageService.saveSessionUser(effectiveCurrentUser);

    return AppData(
      users: _mergeUsers(users, effectiveCurrentUser),
      projects: projects,
      devices: devices,
      deviceRequests: requests,
      notifications: notifications,
      routerSettings: [routerSettings],
      currentProjectId: projectId,
    );
  }

  List<User> _mergeUsers(List<User> users, User currentUser) {
    final merged = users
        .map((item) => item.id == currentUser.id ? currentUser : item)
        .toList();
    if (!merged.any((item) => item.id == currentUser.id)) {
      return [...merged, currentUser];
    }
    return merged;
  }
}
