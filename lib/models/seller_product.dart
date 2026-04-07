class SellerMedia {
  const SellerMedia({
    required this.id,
    required this.url,
    this.name,
  });

  final int id;
  final String url;
  final String? name;

  bool get hasData => url.trim().isNotEmpty;

  factory SellerMedia.fromJson(Map<String, dynamic> json) {
    final attributes =
        json['attributes'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final source = attributes.isNotEmpty ? attributes : json;

    return SellerMedia(
      id: (json['id'] as num?)?.toInt() ?? (source['id'] as num?)?.toInt() ?? 0,
      url: (source['url'] ?? '').toString(),
      name: source['name']?.toString(),
    );
  }

  static List<SellerMedia> listFrom(dynamic raw) {
    if (raw is List<dynamic>) {
      return raw.whereType<Map<String, dynamic>>().map(SellerMedia.fromJson).toList();
    }

    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List<dynamic>) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(SellerMedia.fromJson)
            .toList();
      }
      if (data is Map<String, dynamic>) {
        return <SellerMedia>[SellerMedia.fromJson(data)];
      }
    }

    return <SellerMedia>[];
  }
}

class SellerProduct {
  const SellerProduct({
    required this.id,
    required this.documentId,
    required this.name,
    required this.price,
    required this.stock,
    required this.isActive,
    this.sku,
    this.unit,
    this.minOrderQty,
    this.categoryId,
    this.categoryName,
    this.description,
    this.images = const <SellerMedia>[],
  });

  final int id;
  final String documentId;
  final String name;
  final double price;
  final double stock;
  final bool isActive;
  final String? sku;
  final String? unit;
  final double? minOrderQty;
  final int? categoryId;
  final String? categoryName;
  final String? description;
  final List<SellerMedia> images;

  String get priceLabel =>
      '\$${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}';

  SellerMedia? get coverImage => images.isEmpty ? null : images.first;

  factory SellerProduct.fromJson(Map<String, dynamic> json) {
    final attributes =
        json['attributes'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final source = attributes.isNotEmpty ? attributes : json;
    final category = source['category'];

    return SellerProduct(
      id: (json['id'] as num?)?.toInt() ?? (source['id'] as num?)?.toInt() ?? 0,
      documentId: (json['documentId'] ?? source['documentId'] ?? '').toString(),
      name: (source['name'] ?? '').toString(),
      price: _asDouble(source['price']),
      stock: _asDouble(source['stock']),
      isActive: source['isActive'] as bool? ?? true,
      sku: _optional(source['sku']),
      unit: _optional(source['unit']),
      minOrderQty:
          source['minOrderQty'] == null ? null : _asDouble(source['minOrderQty']),
      categoryId: _extractCategoryId(category),
      categoryName: _extractCategoryName(category),
      description: _extractDescriptionText(source['description']),
      images: SellerMedia.listFrom(source['images']),
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _optional(dynamic value) {
    final normalized = value?.toString().trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  static int? _extractCategoryId(dynamic rawCategory) {
    if (rawCategory is Map<String, dynamic>) {
      final data = rawCategory['data'];
      if (data is Map<String, dynamic>) {
        return (data['id'] as num?)?.toInt();
      }

      return (rawCategory['id'] as num?)?.toInt();
    }

    return null;
  }

  static String? _extractCategoryName(dynamic rawCategory) {
    if (rawCategory is Map<String, dynamic>) {
      final data = rawCategory['data'];
      if (data is Map<String, dynamic>) {
        final attributes =
            data['attributes'] as Map<String, dynamic>? ?? <String, dynamic>{};
        return _optional(attributes['name'] ?? data['name']);
      }

      return _optional(rawCategory['name']);
    }

    return null;
  }

  static String? _extractDescriptionText(dynamic rawDescription) {
    if (rawDescription is String) {
      final normalized = rawDescription.trim();
      return normalized.isEmpty ? null : normalized;
    }

    if (rawDescription is List<dynamic>) {
      final fragments = <String>[];

      for (final block in rawDescription) {
        if (block is! Map<String, dynamic>) {
          continue;
        }
        final children = block['children'];
        if (children is! List<dynamic>) {
          continue;
        }

        for (final child in children) {
          if (child is! Map<String, dynamic>) {
            continue;
          }
          final text = child['text']?.toString().trim() ?? '';
          if (text.isNotEmpty) {
            fragments.add(text);
          }
        }
      }

      return fragments.isEmpty ? null : fragments.join('\n');
    }

    return null;
  }
}
