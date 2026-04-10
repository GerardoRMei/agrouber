import 'package:flutter/material.dart';
import 'marketplace_product.dart';

class CartItem {
  final MarketplaceProduct product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartState extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  void addProduct(MarketplaceProduct product) {
    final index = _items.indexWhere((item) => item.product.name == product.name);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    
    notifyListeners(); 
  }
}