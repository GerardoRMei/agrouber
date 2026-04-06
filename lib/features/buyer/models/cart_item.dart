import '../../../models/marketplace_product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
  });

  final MarketplaceProduct product;
  final int quantity;

  double get total => product.unitPrice * quantity;

  CartItem copyWith({
    MarketplaceProduct? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
