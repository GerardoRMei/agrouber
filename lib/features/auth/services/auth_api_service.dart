import '../../../data/api_client.dart';
import '../models/auth_session.dart';

class AuthApiService {
  AuthApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    final session = await _apiClient.login(
      identifier: identifier,
      password: password,
    );

    try {
      final me = await _apiClient.getJson(
        '/api/public-auth/user-info',
        authToken: session.jwt,
        queryParameters: {
          'userId': session.userId.toString(),
        },
      );

      return AuthSession.fromCurrentUserJson(
        me,
        jwt: session.jwt,
      );
    } catch (_) {
      return session;
    }
  }
}
