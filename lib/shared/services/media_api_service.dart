import 'package:image_picker/image_picker.dart';

import '../../data/api_client.dart';
import '../../features/auth/models/auth_session.dart';
import '../models/app_media.dart';

class MediaApiService {
  MediaApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AppMedia> uploadSingleImage({
    required AuthSession session,
    required XFile file,
  }) async {
    final media = await uploadImages(
      session: session,
      files: <XFile>[file],
    );

    if (media.isEmpty) {
      throw const ApiException('No pudimos subir la imagen.');
    }

    return media.first;
  }

  Future<List<AppMedia>> uploadImages({
    required AuthSession session,
    required List<XFile> files,
  }) async {
    if (files.isEmpty) {
      return <AppMedia>[];
    }

    final response = await _apiClient.uploadFiles(
      '/api/upload',
      files: files,
      authToken: session.jwt,
    );

    return response.map(AppMedia.fromJson).where((media) => media.hasData).toList();
  }
}
