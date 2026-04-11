import 'package:flutter/material.dart';
import '../data/api_client.dart';

class MarketProductCard extends StatelessWidget {
  static final ApiClient _apiClient = ApiClient();
  final String imageUrl;
  final String productName;
  final String priceDisplay;
  final int sellerCount;
  final VoidCallback? onAddToCart;
  final bool isMobile;

  const MarketProductCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.priceDisplay,
    required this.sellerCount,
    this.onAddToCart,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildCompactCard();
    }
    return _buildGridCard();
  }

  String? get _resolvedImageUrl {
    final raw = imageUrl.trim();
    if (raw.isEmpty) return null;
    final hasHttp = raw.startsWith('http://') || raw.startsWith('https://');
    final looksLikeMediaPath = raw.startsWith('/');
    if (!hasHttp && !looksLikeMediaPath) {
      return null;
    }
    return _apiClient.resolveMediaUrl(raw);
  }

  Widget _buildVisual(double size) {
    final resolvedImage = _resolvedImageUrl;
    if (resolvedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          resolvedImage,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, _, __) {
            return Icon(
              Icons.image_not_supported_outlined,
              size: size * 0.45,
              color: const Color(0xFF8F958D),
            );
          },
        ),
      );
    }

    return Text(
      imageUrl,
      style: TextStyle(fontSize: size * 0.45),
    );
  }

  // ==========================================
  // DISEÑO COMPACTO (HORIZONTAL) PARA MÓVILES
  // ==========================================
  Widget _buildCompactCard() {
    return Container(
      height: 120,
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
          Container(
            width: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F0EA),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
            ),
            child: Center(
              child: _buildVisual(90),
            ),
          ),
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
                child: _buildVisual(110),
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
