import 'device_request.dart';
import 'network_device.dart';
import 'network_project.dart';
import 'notification_item.dart';
import 'router_settings.dart';
import 'user.dart';

class AppData {
  const AppData({
    required this.users,
    required this.projects,
    required this.devices,
    required this.deviceRequests,
    required this.notifications,
    required this.routerSettings,
    required this.currentProjectId,
  });

  final List<User> users;
  final List<NetworkProject> projects;
  final List<NetworkDevice> devices;
  final List<DeviceRequest> deviceRequests;
  final List<NotificationItem> notifications;
  final List<RouterSettings> routerSettings;
  final int currentProjectId;

  factory AppData.empty() {
    return const AppData(
      users: [],
      projects: [],
      devices: [],
      deviceRequests: [],
      notifications: [],
      routerSettings: [],
      currentProjectId: 0,
    );
  }

  factory AppData.fromJson(Map<String, dynamic> json) {
    final projectsJson = json['projects'] as List<dynamic>?;
    final projects = projectsJson == null || projectsJson.isEmpty
        ? const [
            NetworkProject(
              id: 1,
              name: 'Домашняя сеть',
              description: 'Сеть квартиры',
              propertyType: 'Квартира',
              roomCount: 4,
              provider: 'Домашний провайдер',
              primaryRouterName: 'Основной роутер',
            ),
          ]
        : projectsJson
            .map((item) => NetworkProject.fromJson(item as Map<String, dynamic>))
            .toList();

    final routerSettingsJson = json['routerSettings'];
    final routerSettings = routerSettingsJson is List<dynamic>
        ? routerSettingsJson
            .map((item) => RouterSettings.fromJson(item as Map<String, dynamic>))
            .toList()
        : [
            RouterSettings.fromJson(
              (routerSettingsJson as Map<String, dynamic>?) ??
                  const {
                    'ssid': 'HomeMesh',
                    'password': 'safehome2026',
                    'band': '5 GHz',
                    'channel': '36',
                    'dhcpEnabled': true,
                    'dhcpRange': '192.168.1.100 - 192.168.1.200',
                    'guestNetworkEnabled': true,
                    'hiddenSsid': false,
                    'maxDevices': 40,
                  },
            ),
          ];

    return AppData(
      users: (json['users'] as List<dynamic>)
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList(),
      projects: projects,
      devices: (json['devices'] as List<dynamic>)
          .map((item) => NetworkDevice.fromJson(item as Map<String, dynamic>))
          .toList(),
      deviceRequests: (json['deviceRequests'] as List<dynamic>? ?? [])
          .map((item) => DeviceRequest.fromJson(item as Map<String, dynamic>))
          .toList(),
      notifications: (json['notifications'] as List<dynamic>)
          .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      routerSettings: routerSettings,
      currentProjectId: json['currentProjectId'] as int? ?? projects.first.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((user) => user.toJson()).toList(),
      'projects': projects.map((project) => project.toJson()).toList(),
      'devices': devices.map((device) => device.toJson()).toList(),
      'deviceRequests': deviceRequests.map((request) => request.toJson()).toList(),
      'notifications': notifications.map((item) => item.toJson()).toList(),
      'routerSettings': routerSettings.map((item) => item.toJson()).toList(),
      'currentProjectId': currentProjectId,
    };
  }

  AppData copyWith({
    List<User>? users,
    List<NetworkProject>? projects,
    List<NetworkDevice>? devices,
    List<DeviceRequest>? deviceRequests,
    List<NotificationItem>? notifications,
    List<RouterSettings>? routerSettings,
    int? currentProjectId,
  }) {
    return AppData(
      users: users ?? this.users,
      projects: projects ?? this.projects,
      devices: devices ?? this.devices,
      deviceRequests: deviceRequests ?? this.deviceRequests,
      notifications: notifications ?? this.notifications,
      routerSettings: routerSettings ?? this.routerSettings,
      currentProjectId: currentProjectId ?? this.currentProjectId,
    );
  }
}
