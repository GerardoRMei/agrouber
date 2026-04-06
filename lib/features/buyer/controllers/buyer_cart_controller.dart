import 'package:flutter/foundation.dart';

import '../../../models/marketplace_product.dart';
import '../models/cart_item.dart';

class BuyerCartController extends ChangeNotifier {
  final Map<String, CartItem> _items = <String, CartItem>{};

  List<CartItem> get items => _items.values.toList()
    ..sort((a, b) => a.product.name.compareTo(b.product.name));

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.values.fold(0, (sum, item) => sum + item.total);

  double get serviceFee => _items.isEmpty ? 0 : 39;

  double get total => subtotal + serviceFee;

  bool get isEmpty => _items.isEmpty;

  void addProduct(MarketplaceProduct product) {
    final current = _items[product.name];
    if (current == null) {
      _items[product.name] = CartItem(product: product, quantity: 1);
    } else {
      _items[product.name] = current.copyWith(quantity: current.quantity + 1);
    }
    notifyListeners();
  }

  void increment(MarketplaceProduct product) => addProduct(product);

  void decrement(MarketplaceProduct product) {
    final current = _items[product.name];
    if (current == null) {
      return;
    }

    if (current.quantity <= 1) {
      _items.remove(product.name);
    } else {
      _items[product.name] = current.copyWith(quantity: current.quantity - 1);
    }
    notifyListeners();
  }

  int quantityFor(MarketplaceProduct product) => _items[product.name]?.quantity ?? 0;

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
