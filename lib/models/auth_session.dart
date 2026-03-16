class AuthSession {
  final String jwt;
  final int userId;
  final String email;
  final String displayName;

  const AuthSession({
    required this.jwt,
    required this.userId,
    required this.email,
    required this.displayName,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final firstName = (user['firstName'] ?? '').toString().trim();
    final username = (user['username'] ?? '').toString().trim();
    final email = (user['email'] ?? '').toString().trim();

    return AuthSession(
      jwt: (json['jwt'] ?? '').toString(),
      userId: (user['id'] as num?)?.toInt() ?? 0,
      email: email,
      displayName: firstName.isNotEmpty
          ? firstName
          : (username.isNotEmpty ? username : email),
    );
  }
}
