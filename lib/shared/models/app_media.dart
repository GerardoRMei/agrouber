class AppMedia {
  const AppMedia({
    required this.id,
    required this.url,
  });

  final int id;
  final String url;

  bool get hasData => id > 0 && url.trim().isNotEmpty;

  factory AppMedia.fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return const AppMedia(id: 0, url: '');
    }

    final source = _unwrap(raw);

    return AppMedia(
      id: (source['id'] as num?)?.toInt() ?? 0,
      url: (source['url'] ?? '').toString(),
    );
  }

  static AppMedia? fromNullable(dynamic raw) {
    final media = AppMedia.fromJson(raw);
    return media.hasData ? media : null;
  }

  static List<AppMedia> listFrom(dynamic raw) {
    if (raw is List<dynamic>) {
      return raw.map(AppMedia.fromJson).where((media) => media.hasData).toList();
    }

    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List<dynamic>) {
        return data
            .map(AppMedia.fromJson)
            .where((media) => media.hasData)
            .toList();
      }

      final single = AppMedia.fromNullable(data ?? raw);
      return single == null ? <AppMedia>[] : <AppMedia>[single];
    }

    return <AppMedia>[];
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> raw) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return raw;
  }
}
