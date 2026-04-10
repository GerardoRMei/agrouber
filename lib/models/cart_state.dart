import 'package:agrouber/models/marketplace_product.dart';
import 'package:flutter/material.dart';

class CartItem {
  final MarketplaceProduct product;
  final ProductOption option;
  double quantity;
  String unitLabel;
  double finalPrice;

  CartItem({
    required this.product,
    required this.option,
    required this.quantity,
    required this.unitLabel,
    required this.finalPrice,
  });
}

class CartState extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get totalItems => _items.length;

  void addProduct({
    required MarketplaceProduct product,
    required ProductOption option,
    required double quantity,
    required String unitLabel,
    required double finalPrice,
  }) {
    _items.add(CartItem(
      product: product,
      option: option,
      quantity: quantity,
      unitLabel: unitLabel,
      finalPrice: finalPrice,
    ));
    
    notifyListeners();
  }
}