class AuthSession {
  const AuthSession({
    required this.jwt,
    required this.userId,
    required this.email,
    required this.displayName,
    this.username,
    this.firstName,
    this.phone,
    this.roleType,
    this.profileImageUrl,
  });

  final String jwt;
  final int userId;
  final String email;
  final String displayName;
  final String? username;
  final String? firstName;
  final String? phone;
  final String? roleType;
  final String? profileImageUrl;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final firstName = (user['firstName'] ?? '').toString().trim();
    final username = (user['username'] ?? '').toString().trim();
    final email = (user['email'] ?? '').toString().trim();
    final role = user['role'];
    String? roleType;

    if (role is Map<String, dynamic>) {
      final value = role['type']?.toString().trim();
      if (value != null && value.isNotEmpty) {
        roleType = value;
      }
    }

    return AuthSession(
      jwt: (json['jwt'] ?? '').toString(),
      userId: (user['id'] as num?)?.toInt() ?? 0,
      email: email,
      displayName: firstName.isNotEmpty
          ? firstName
          : (username.isNotEmpty ? username : email),
      username: username.isEmpty ? null : username,
      firstName: firstName.isEmpty ? null : firstName,
      phone: _optionalString(user['phone']),
      roleType: roleType,
      profileImageUrl: _extractMediaUrl(user['profileImage']),
    );
  }

  factory AuthSession.fromCurrentUserJson(
    Map<String, dynamic> json, {
    required String jwt,
  }) {
    final firstName = (json['firstName'] ?? '').toString().trim();
    final username = (json['username'] ?? '').toString().trim();
    final email = (json['email'] ?? '').toString().trim();
    final role = json['role'];
    String? roleType;

    if (role is Map<String, dynamic>) {
      final value = role['type']?.toString().trim();
      if (value != null && value.isNotEmpty) {
        roleType = value;
      }
    }

    return AuthSession(
      jwt: jwt,
      userId: (json['id'] as num?)?.toInt() ?? 0,
      email: email,
      displayName: firstName.isNotEmpty
          ? firstName
          : (username.isNotEmpty ? username : email),
      username: username.isEmpty ? null : username,
      firstName: firstName.isEmpty ? null : firstName,
      phone: _optionalString(json['phone']),
      roleType: roleType,
      profileImageUrl: _extractMediaUrl(json['profileImage']),
    );
  }

  AuthSession copyWith({
    String? jwt,
    int? userId,
    String? email,
    String? displayName,
    String? username,
    String? firstName,
    String? phone,
    String? roleType,
    String? profileImageUrl,
  }) {
    return AuthSession(
      jwt: jwt ?? this.jwt,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      phone: phone ?? this.phone,
      roleType: roleType ?? this.roleType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  static String? _optionalString(dynamic value) {
    final normalized = value?.toString().trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  static String? _extractMediaUrl(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        final url = data['url']?.toString().trim() ?? '';
        return url.isEmpty ? null : url;
      }

      final url = raw['url']?.toString().trim() ?? '';
      return url.isEmpty ? null : url;
    }

    return null;
  }
}
