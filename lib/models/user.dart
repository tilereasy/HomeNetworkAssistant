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
    required this.password,
    required this.role,
  });

  final int id;
  final String login;
  final String password;
  final UserRole role;

  bool get isAdmin => role == UserRole.admin;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'password': password,
      'role': role.name,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      login: json['login'] as String,
      password: json['password'] as String,
      role: userRoleFromString(json['role'] as String),
    );
  }
}
