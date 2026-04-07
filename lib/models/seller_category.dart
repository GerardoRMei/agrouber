class SellerCategory {
  const SellerCategory({
    required this.id,
    required this.documentId,
    required this.name,
    required this.slug,
  });

  final int id;
  final String documentId;
  final String name;
  final String slug;

  factory SellerCategory.fromStrapi(Map<String, dynamic> json) {
    final attributes =
        json['attributes'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return SellerCategory(
      id: (json['id'] as num?)?.toInt() ?? 0,
      documentId:
          (json['documentId'] ?? attributes['documentId'] ?? '').toString(),
      name: (json['name'] ?? attributes['name'] ?? '').toString(),
      slug: (json['slug'] ?? attributes['slug'] ?? '').toString(),
    );
  }
}
