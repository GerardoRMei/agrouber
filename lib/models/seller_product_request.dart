class SellerProductRequest {
  const SellerProductRequest({
    required this.name,
    required this.price,
    required this.unit,
    required this.categoryId,
    required this.stock,
    this.sku,
    this.minOrderQty,
    this.description,
    this.imageIds = const <int>[],
    this.includeImagesField = false,
  });

  final String name;
  final double price;
  final String unit;
  final int categoryId;
  final double stock;
  final String? sku;
  final double? minOrderQty;
  final String? description;
  final List<int> imageIds;
  final bool includeImagesField;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'price': price,
      'unit': unit,
      'category': categoryId,
      'stock': stock,
      if (includeImagesField || imageIds.isNotEmpty) 'images': imageIds,
      if (sku != null && sku!.trim().isNotEmpty) 'sku': sku!.trim(),
      if (minOrderQty != null) 'minOrderQty': minOrderQty,
      if (description != null && description!.trim().isNotEmpty)
        'description': [
          {
            'type': 'paragraph',
            'children': [
              {
                'type': 'text',
                'text': description!.trim(),
              },
            ],
          },
        ],
    };
  }
}
