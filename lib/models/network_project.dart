class NetworkProject {
  const NetworkProject({
    required this.id,
    required this.name,
    required this.description,
    required this.propertyType,
    required this.roomCount,
    required this.provider,
    required this.primaryRouterName,
  });

  final int id;
  final String name;
  final String description;
  final String propertyType;
  final int roomCount;
  final String provider;
  final String primaryRouterName;

  NetworkProject copyWith({
    int? id,
    String? name,
    String? description,
    String? propertyType,
    int? roomCount,
    String? provider,
    String? primaryRouterName,
  }) {
    return NetworkProject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      propertyType: propertyType ?? this.propertyType,
      roomCount: roomCount ?? this.roomCount,
      provider: provider ?? this.provider,
      primaryRouterName: primaryRouterName ?? this.primaryRouterName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'propertyType': propertyType,
      'roomCount': roomCount,
      'provider': provider,
      'primaryRouterName': primaryRouterName,
    };
  }

  factory NetworkProject.fromJson(Map<String, dynamic> json) {
    return NetworkProject(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      propertyType: json['propertyType'] as String,
      roomCount: json['roomCount'] as int,
      provider: json['provider'] as String,
      primaryRouterName: json['primaryRouterName'] as String,
    );
  }
}
