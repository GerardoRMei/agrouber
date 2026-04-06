import '../../../shared/models/app_media.dart';
import '../../auth/models/auth_session.dart';

class AccountProfile {
  const AccountProfile({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.phone,
    this.roleType,
    this.profileImage,
  });

  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? phone;
  final String? roleType;
  final AppMedia? profileImage;

  String get displayName {
    final normalizedFirstName = firstName?.trim() ?? '';
    if (normalizedFirstName.isNotEmpty) {
      return normalizedFirstName;
    }

    final normalizedUsername = username.trim();
    if (normalizedUsername.isNotEmpty) {
      return normalizedUsername;
    }

    return email.trim();
  }

  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    final source = _unwrap(json);

    return AccountProfile(
      id: (source['id'] as num?)?.toInt() ?? 0,
      username: (source['username'] ?? '').toString(),
      email: (source['email'] ?? '').toString(),
      firstName: _optionalString(source['firstName']),
      phone: _optionalString(source['phone']),
      roleType: _extractRoleType(source['role']),
      profileImage: AppMedia.fromNullable(source['profileImage']),
    );
  }

  AuthSession toSession(AuthSession current) {
    return current.copyWith(
      userId: id == 0 ? current.userId : id,
      email: email,
      displayName: displayName,
      username: username.trim().isEmpty ? current.username : username.trim(),
      firstName: firstName,
      phone: phone,
      roleType: roleType ?? current.roleType,
      profileImageUrl: profileImage?.url,
    );
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> raw) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return raw;
  }

  static String? _optionalString(dynamic value) {
    final normalized = value?.toString().trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  static String? _extractRoleType(dynamic role) {
    if (role is Map<String, dynamic>) {
      final source = _unwrap(role);
      final type = source['type']?.toString().trim() ?? '';
      return type.isEmpty ? null : type;
    }
    return null;
  }
}
