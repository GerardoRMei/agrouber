class MarketplaceProduct {
  final double unitPrice;
  final String name;
  final String categoryName;
  final String priceDisplay;
  final int sellerCount;
  final String visual;

  const MarketplaceProduct({
    required this.unitPrice,
    required this.name,
    required this.categoryName,
    required this.priceDisplay,
    required this.sellerCount,
    required this.visual,
  });
}
