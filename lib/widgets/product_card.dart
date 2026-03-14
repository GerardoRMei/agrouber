import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  Color _tagColor(String tag) {
    if (tag == '2 days') return const Color(0xFFE39B2D);
    return const Color(0xFF4A7A4D);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: _ProductImageHeader(product: product, tagColor: _tagColor(product.tag)),
          ),
          Expanded(
            flex: 4,
            child: _ProductInfoFooter(product: product),
          ),
        ],
      ),
    );
  }
}

class _ProductImageHeader extends StatelessWidget {
  const _ProductImageHeader({required this.product, required this.tagColor});
  final Product product;
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFE9EFE3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(14)),
              child: Text(
                product.tag,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          Center(child: Text(product.image, style: const TextStyle(fontSize: 58))),
        ],
      ),
    );
  }
}

class _ProductInfoFooter extends StatelessWidget {
  const _ProductInfoFooter({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(product.producer, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${product.price} ${product.unit}', 
                style: const TextStyle(color: Color(0xFF3D6A43), fontWeight: FontWeight.w800, fontSize: 18)),
              const _AddButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: const Color(0xFF2E4F2F), borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}