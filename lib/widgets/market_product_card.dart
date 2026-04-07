import 'package:flutter/material.dart';

class MarketProductCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String priceDisplay;
  final int sellerCount;
  final VoidCallback? onAddToCart;
  final bool isMobile; // NUEVO: Determina si el diseño debe ser compacto

  const MarketProductCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.priceDisplay,
    required this.sellerCount,
    this.onAddToCart,
    this.isMobile = false, // Por defecto es false
  });

  @override
  Widget build(BuildContext context) {
    // Si es móvil, mostramos un diseño de lista horizontal (compacto)
    if (isMobile) {
      return _buildCompactCard();
    }
    // Si es escritorio/tablet, mostramos el diseño de cuadrícula vertical
    return _buildGridCard();
  }

  // ==========================================
  // DISEÑO COMPACTO (HORIZONTAL) PARA MÓVILES
  // ==========================================
  Widget _buildCompactCard() {
    return Container(
      height: 120, // Altura fija para el modo lista
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen a la izquierda
          Container(
            width: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F0EA),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
            ),
            child: Center(
              child: Text(
                imageUrl,
                style: const TextStyle(fontSize: 45),
              ),
            ),
          ),
          // Información a la derecha
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1209),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    priceDisplay,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4A7A4D),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.storefront, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$sellerCount vend.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildAddButton(),
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

  // ==========================================
  // DISEÑO DE CUADRÍCULA (VERTICAL) ORIGINAL
  // ==========================================
  Widget _buildGridCard() {
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
                  imageUrl,
                  style: const TextStyle(fontSize: 50),
                ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.storefront, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$sellerCount vend.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildAddButton(),
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

  // Extraje el botón porque se repite en ambos diseños
  Widget _buildAddButton() {
    return InkWell(
      onTap: onAddToCart,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E4F2F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.add_shopping_cart,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}