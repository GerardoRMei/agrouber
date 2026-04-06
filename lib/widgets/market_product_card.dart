import 'package:flutter/material.dart';

import '../shared/theme/agrorun_theme.dart';

class MarketProductCard extends StatelessWidget {
  const MarketProductCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.priceDisplay,
    required this.sellerCount,
    required this.categoryName,
    required this.onAddToCart,
    required this.quantityInCart,
  });

  final String imageUrl;
  final String productName;
  final String priceDisplay;
  final int sellerCount;
  final String categoryName;
  final VoidCallback onAddToCart;
  final int quantityInCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
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
                gradient: LinearGradient(
                  colors: [
                    AgrorunPalette.cream,
                    AgrorunPalette.creamStrong,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        categoryName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AgrorunPalette.forest,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      imageUrl,
                      style: const TextStyle(fontSize: 54),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
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
                      color: AgrorunPalette.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    priceDisplay,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AgrorunPalette.forest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        size: 16,
                        color: AgrorunPalette.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sellerCount == 1 ? '1 vendedor disponible' : '$sellerCount vendedores disponibles',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AgrorunPalette.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onAddToCart,
                      icon: Icon(quantityInCart > 0 ? Icons.add_shopping_cart : Icons.shopping_cart_checkout),
                      label: Text(
                        quantityInCart > 0 ? 'Agregar otra vez ($quantityInCart)' : 'Agregar al carrito',
                      ),
                    ),
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
