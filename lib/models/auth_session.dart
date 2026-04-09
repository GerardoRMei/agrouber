class AuthSession {
  final String jwt;
  final int userId;
  final String email;
  final String displayName;
  final String role;

  // username ahora ya no es nullable
  final String username;

  final String? firstName;
  final String? phone;
  final String? profileImageUrl;

  const AuthSession({
    required this.jwt,
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.username,
    this.firstName,
    this.phone,
    this.profileImageUrl,
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
      displayName: _resolveDisplayName(
        firstName: firstName,
        username: username,
        email: email,
      ),
      role: _resolveRole(
        explicitRole: json['role'],
        nestedRole: user['role'],
        seller: user['seller'] ?? json['seller'],
      ),
      username: username.isNotEmpty ? username : email,
      firstName: firstName.isEmpty ? null : firstName,
      phone: _optionalString(user['phone']),
      profileImageUrl: _extractMediaUrl(
        user['profileImage'] ?? json['profileImage'],
      ),
    );
  }

  factory AuthSession.fromCurrentUserJson(
    Map<String, dynamic> json, {
    required String jwt,
    String? fallbackRole,
  }) {
    final firstName = (json['firstName'] ?? '').toString().trim();
    final username = (json['username'] ?? '').toString().trim();
    final email = (json['email'] ?? '').toString().trim();

    return AuthSession(
      jwt: jwt,
      userId: (json['id'] as num?)?.toInt() ?? 0,
      email: email,
      displayName: _resolveDisplayName(
        firstName: firstName,
        username: username,
        email: email,
      ),
      role: _resolveRole(
        explicitRole: json['role'],
        nestedRole: json['role'],
        seller: json['seller'],
        fallback: fallbackRole ?? 'customer',
      ),
      username: username.isNotEmpty ? username : email,
      firstName: firstName.isEmpty ? null : firstName,
      phone: _optionalString(json['phone']),
      profileImageUrl: _extractMediaUrl(json['profileImage']),
    );
  }

  AuthSession copyWith({
    String? jwt,
    int? userId,
    String? email,
    String? displayName,
    String? role,
    String? username,
    String? firstName,
    String? phone,
    String? profileImageUrl,
  }) {
    return AuthSession(
      jwt: jwt ?? this.jwt,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  static String _resolveDisplayName({
    required String firstName,
    required String username,
    required String email,
  }) {
    if (firstName.isNotEmpty) return firstName;
    if (username.isNotEmpty) return username;
    if (email.isNotEmpty) return email;
    return 'Usuario';
  }

  static String _resolveRole({
    dynamic explicitRole,
    dynamic nestedRole,
    dynamic seller,
    String fallback = 'customer',
  }) {
    final direct = explicitRole?.toString().trim().toLowerCase() ?? '';
    if (direct.isNotEmpty) {
      return direct;
    }

    if (nestedRole is Map<String, dynamic>) {
      final candidates = <dynamic>[
        nestedRole['type'],
        nestedRole['name'],
        nestedRole['code'],
      ];

      for (final candidate in candidates) {
        final value = candidate?.toString().trim().toLowerCase() ?? '';
        if (value.isNotEmpty) {
          if (value.contains('delivery')) return 'delivery';
          if (value.contains('seller')) return 'seller';
          if (value.contains('customer')) return 'customer';
          if (value.contains('operations')) return 'operations';
          return value;
        }
      }
    }

    if (seller is Map<String, dynamic> && seller.isNotEmpty) {
      return 'seller';
    }

    return fallback;
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