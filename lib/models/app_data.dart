import 'notification_item.dart';
import 'router_settings.dart';
import 'user.dart';
import 'network_device.dart';

class AppData {
  const AppData({
    required this.users,
    required this.devices,
    required this.notifications,
    required this.routerSettings,
  });

  final List<User> users;
  final List<NetworkDevice> devices;
  final List<NotificationItem> notifications;
  final RouterSettings routerSettings;

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((user) => user.toJson()).toList(),
      'devices': devices.map((device) => device.toJson()).toList(),
      'notifications': notifications.map((item) => item.toJson()).toList(),
      'routerSettings': routerSettings.toJson(),
    };
  }

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      users: (json['users'] as List<dynamic>)
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList(),
      devices: (json['devices'] as List<dynamic>)
          .map((item) => NetworkDevice.fromJson(item as Map<String, dynamic>))
          .toList(),
      notifications: (json['notifications'] as List<dynamic>)
          .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      routerSettings: RouterSettings.fromJson(
        json['routerSettings'] as Map<String, dynamic>,
      ),
    );
  }

  AppData copyWith({
    List<User>? users,
    List<NetworkDevice>? devices,
    List<NotificationItem>? notifications,
    RouterSettings? routerSettings,
  }) {
    return AppData(
      users: users ?? this.users,
      devices: devices ?? this.devices,
      notifications: notifications ?? this.notifications,
      routerSettings: routerSettings ?? this.routerSettings,
    );
  }
}
