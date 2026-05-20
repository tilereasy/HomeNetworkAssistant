enum DeviceRequestStatus { pending, approved, rejected }

DeviceRequestStatus deviceRequestStatusFromString(String value) {
  return DeviceRequestStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => DeviceRequestStatus.pending,
  );
}

class DeviceRequest {
  const DeviceRequest({
    required this.id,
    required this.projectId,
    required this.deviceId,
    required this.requesterLogin,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int projectId;
  final int deviceId;
  final String requesterLogin;
  final DeviceRequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceRequest copyWith({
    int? id,
    int? projectId,
    int? deviceId,
    String? requesterLogin,
    DeviceRequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeviceRequest(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      deviceId: deviceId ?? this.deviceId,
      requesterLogin: requesterLogin ?? this.requesterLogin,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'deviceId': deviceId,
      'requesterLogin': requesterLogin,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DeviceRequest.fromJson(Map<String, dynamic> json) {
    return DeviceRequest(
      id: json['id'] as int,
      projectId: json['projectId'] as int? ?? 1,
      deviceId: json['deviceId'] as int,
      requesterLogin: json['requesterLogin'] as String,
      status: deviceRequestStatusFromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
