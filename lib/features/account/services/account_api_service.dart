import '../../../data/api_client.dart';
import '../../auth/models/auth_session.dart';
import '../models/account_profile.dart';

class AccountApiService {
  AccountApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AccountProfile> fetchProfile(AuthSession session) async {
    final response = await _apiClient.getJson(
      '/api/public-auth/user-info',
      authToken: session.jwt,
      queryParameters: {
        'userId': session.userId.toString(),
      },
    );

    return AccountProfile.fromJson(response);
  }

  Future<AccountProfile> updateProfile({
    required AuthSession session,
    required String firstName,
    required String username,
    required String email,
    required String phone,
    int? profileImageId,
  }) async {
    final body = <String, dynamic>{
      'firstName': firstName.trim(),
      'username': username.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      if (profileImageId != null) 'profileImage': profileImageId,
    };

    await _apiClient.putDynamic(
      '/api/users/${session.userId}',
      authToken: session.jwt,
      body: body,
    );

    return fetchProfile(session);
  }

  Future<void> changePassword({
    required AuthSession session,
    required String password,
  }) async {
    await _apiClient.putDynamic(
      '/api/users/${session.userId}',
      authToken: session.jwt,
      body: {
        'password': password,
      },
    );
  }
}
