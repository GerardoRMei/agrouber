import 'package:agrouber/models/product_unit.dart';

class Product {
  final String name;
  final String producer;
  final String price;
  final ProductUnit unit;
  final String image;
  final String tag;
  final String category;

  const Product({
    required this.name,
    required this.producer,
    required this.price,
    required this.unit,
    required this.image,
    required this.tag,
    required this.category,
  });
}