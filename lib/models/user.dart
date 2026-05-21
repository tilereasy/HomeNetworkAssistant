enum UserRole { admin, user }

UserRole userRoleFromString(String value) {
  return UserRole.values.firstWhere(
    (role) => role.name == value,
    orElse: () => UserRole.user,
  );
}

class User {
  const User({
    required this.id,
    required this.login,
    this.password = '',
    required this.role,
    required this.lastLogin,
    this.favoriteDeviceIds = const [],
    this.savedSettings = const {},
  });

  final int id;
  final String login;
  final String password;
  final UserRole role;
  final DateTime? lastLogin;
  final List<int> favoriteDeviceIds;
  final Map<String, dynamic> savedSettings;

  bool get isAdmin => role == UserRole.admin;

  User copyWith({
    int? id,
    String? login,
    String? password,
    UserRole? role,
    DateTime? lastLogin,
    List<int>? favoriteDeviceIds,
    Map<String, dynamic>? savedSettings,
  }) {
    return User(
      id: id ?? this.id,
      login: login ?? this.login,
      password: password ?? this.password,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
      favoriteDeviceIds: favoriteDeviceIds ?? this.favoriteDeviceIds,
      savedSettings: savedSettings ?? this.savedSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'password': password,
      'role': role.name,
      'lastLogin': lastLogin?.toIso8601String(),
      'favoriteDeviceIds': favoriteDeviceIds,
      'savedSettings': savedSettings,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      login: json['login'] as String,
      password: json['password'] as String? ?? '',
      role: userRoleFromString(json['role'] as String),
      lastLogin: json['lastLogin'] == null
          ? null
          : DateTime.parse(json['lastLogin'] as String),
      favoriteDeviceIds: (json['favoriteDeviceIds'] as List<dynamic>? ?? [])
          .map((item) => item as int)
          .toList(),
      savedSettings: (json['savedSettings'] as Map<String, dynamic>?) ?? const {},
    );
  }
}
