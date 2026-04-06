class AuthSession {
  final String jwt;
  final int userId;
  final String email;
  final String displayName;
  final String role;

  const AuthSession({
    required this.jwt,
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final firstName = (user['firstName'] ?? '').toString().trim();
    final username = (user['username'] ?? '').toString().trim();
    final email = (user['email'] ?? '').toString().trim();
    final role = (json['role'] ?? '').toString().trim();

    return AuthSession(
      jwt: (json['jwt'] ?? '').toString(),
      userId: (user['id'] as num?)?.toInt() ?? 0,
      email: email,
      displayName: firstName.isNotEmpty
          ? firstName
          : (username.isNotEmpty ? username : email),
      role: role,
    );
  }

  AuthSession copyWith({
    String? jwt,
    int? userId,
    String? email,
    String? displayName,
    String? role,
  }) {
    return AuthSession(
      jwt: jwt ?? this.jwt,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
    );
  }
}