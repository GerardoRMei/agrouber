import 'package:flutter/material.dart';

class MarketProductCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String priceDisplay;
  final int sellerCount;

  const MarketProductCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.priceDisplay,
    required this.sellerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F0EA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Center(
                child: Text(
                  imageUrl, // Usando el sistema de emojis, cambiar cuando se usen imgs de verdad
                  style: const TextStyle(fontSize: 50),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1209),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priceDisplay,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4A7A4D),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.storefront, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$sellerCount vendedores',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}