enum ConnectionType { wifi, ethernet }

enum DeviceStatus { active, inactive, issue, pending, rejected }

ConnectionType connectionTypeFromString(String value) {
  return ConnectionType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => ConnectionType.wifi,
  );
}

DeviceStatus deviceStatusFromString(String value) {
  return DeviceStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => DeviceStatus.inactive,
  );
}

class NetworkDevice {
  const NetworkDevice({
    required this.id,
    required this.projectId,
    required this.name,
    required this.type,
    required this.ipAddress,
    required this.macAddress,
    required this.connectionType,
    required this.room,
    required this.status,
    required this.signalStrength,
    required this.speedMbps,
    required this.description,
    required this.isFavorite,
    required this.isDeleted,
    required this.createdBy,
    required this.createdAt,
    required this.isGuest,
    required this.requiresStaticIp,
  });

  final int id;
  final int projectId;
  final String name;
  final String type;
  final String ipAddress;
  final String macAddress;
  final ConnectionType connectionType;
  final String room;
  final DeviceStatus status;
  final int signalStrength;
  final int speedMbps;
  final String description;
  final bool isFavorite;
  final bool isDeleted;
  final String createdBy;
  final DateTime createdAt;
  final bool isGuest;
  final bool requiresStaticIp;

  bool get isPending => status == DeviceStatus.pending;

  NetworkDevice copyWith({
    int? id,
    int? projectId,
    String? name,
    String? type,
    String? ipAddress,
    String? macAddress,
    ConnectionType? connectionType,
    String? room,
    DeviceStatus? status,
    int? signalStrength,
    int? speedMbps,
    String? description,
    bool? isFavorite,
    bool? isDeleted,
    String? createdBy,
    DateTime? createdAt,
    bool? isGuest,
    bool? requiresStaticIp,
  }) {
    return NetworkDevice(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      type: type ?? this.type,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      connectionType: connectionType ?? this.connectionType,
      room: room ?? this.room,
      status: status ?? this.status,
      signalStrength: signalStrength ?? this.signalStrength,
      speedMbps: speedMbps ?? this.speedMbps,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isGuest: isGuest ?? this.isGuest,
      requiresStaticIp: requiresStaticIp ?? this.requiresStaticIp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'type': type,
      'ipAddress': ipAddress,
      'macAddress': macAddress,
      'connectionType': connectionType.name,
      'room': room,
      'status': status.name,
      'signalStrength': signalStrength,
      'speedMbps': speedMbps,
      'description': description,
      'isFavorite': isFavorite,
      'isDeleted': isDeleted,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isGuest': isGuest,
      'requiresStaticIp': requiresStaticIp,
    };
  }

  factory NetworkDevice.fromJson(Map<String, dynamic> json) {
    return NetworkDevice(
      id: json['id'] as int,
      projectId: json['projectId'] as int? ?? 1,
      name: json['name'] as String,
      type: json['type'] as String,
      ipAddress: json['ipAddress'] as String,
      macAddress: json['macAddress'] as String,
      connectionType: connectionTypeFromString(json['connectionType'] as String),
      room: json['room'] as String,
      status: deviceStatusFromString(json['status'] as String),
      signalStrength: json['signalStrength'] as int,
      speedMbps: json['speedMbps'] as int,
      description: json['description'] as String,
      isFavorite: json['isFavorite'] as bool,
      isDeleted: json['isDeleted'] as bool,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isGuest: json['isGuest'] as bool? ?? false,
      requiresStaticIp: json['requiresStaticIp'] as bool? ?? false,
    );
  }
}
