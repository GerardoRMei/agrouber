import 'package:agrouber/models/product_unit.dart';

class ProductOption {
  final String sellerName;
  final double price;
  final int productId;
  final int? sellerId;

  const ProductOption({
    required this.sellerName,
    required this.price,
    required this.productId,
    this.sellerId,
  });
}

class MarketplaceProduct {
  final String name;
  final String categoryName;
  final String priceDisplay;
  final int sellerCount;
  final ProductUnit unit;
  final String visual;
  final List<ProductOption> options;

  const MarketplaceProduct({
    required this.name,
    required this.categoryName,
    required this.priceDisplay,
    required this.sellerCount,
    required this.unit,
    required this.visual,
    required this.options,
  });
}
