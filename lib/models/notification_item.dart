import 'user.dart';

enum NotificationActionType { deviceRequest, info }

NotificationActionType notificationActionTypeFromString(String value) {
  return NotificationActionType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => NotificationActionType.info,
  );
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.projectId,
    required this.title,
    required this.message,
    required this.targetRole,
    required this.isRead,
    required this.createdAt,
    required this.actionType,
    required this.relatedDeviceId,
  });

  final int id;
  final int projectId;
  final String title;
  final String message;
  final UserRole targetRole;
  final bool isRead;
  final DateTime createdAt;
  final NotificationActionType actionType;
  final int? relatedDeviceId;

  NotificationItem copyWith({
    int? id,
    int? projectId,
    String? title,
    String? message,
    UserRole? targetRole,
    bool? isRead,
    DateTime? createdAt,
    NotificationActionType? actionType,
    int? relatedDeviceId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      message: message ?? this.message,
      targetRole: targetRole ?? this.targetRole,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      actionType: actionType ?? this.actionType,
      relatedDeviceId: relatedDeviceId ?? this.relatedDeviceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'message': message,
      'targetRole': targetRole.name,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'actionType': actionType.name,
      'relatedDeviceId': relatedDeviceId,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      projectId: json['projectId'] as int? ?? 1,
      title: json['title'] as String,
      message: json['message'] as String,
      targetRole: userRoleFromString(json['targetRole'] as String),
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      actionType: notificationActionTypeFromString(json['actionType'] as String),
      relatedDeviceId: json['relatedDeviceId'] as int?,
    );
  }
}
