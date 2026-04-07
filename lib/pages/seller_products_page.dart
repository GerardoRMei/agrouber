import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/seller_api_service.dart';
import '../models/auth_session.dart';
import '../models/seller_product.dart';
import 'seller_product_form_page.dart';

class SellerProductsPage extends StatefulWidget {
  const SellerProductsPage({
    super.key,
    required this.session,
  });

  final AuthSession session;

  @override
  State<SellerProductsPage> createState() => _SellerProductsPageState();
}

class _SellerProductsPageState extends State<SellerProductsPage> {
  final SellerApiService _sellerApiService = SellerApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<SellerProduct> _products = <SellerProduct>[];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _sellerApiService.fetchMyProducts(widget.session);
      if (!mounted) {
        return;
      }

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openCreateProduct() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SellerProductFormPage(session: widget.session),
      ),
    );

    if (created == true && mounted) {
      await _loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto creado correctamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis productos'),
        backgroundColor: const Color(0xFF1F1209),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateProduct,
        backgroundColor: const Color(0xFF284826),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (_isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A7A4D)),
              );
            }

            if (_errorMessage != null && _products.isEmpty) {
              return _StateMessage(
                title: 'No pudimos cargar tu catalogo',
                message: _errorMessage!,
                buttonLabel: 'Reintentar',
                onPressed: _loadProducts,
              );
            }

            if (_products.isEmpty) {
              return _StateMessage(
                title: 'Todavia no tienes productos publicados',
                message: 'Usa el boton de abajo para registrar tu primer producto.',
                buttonLabel: 'Crear producto',
                onPressed: _openCreateProduct,
              );
            }

            return RefreshIndicator(
              onRefresh: _loadProducts,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: _products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return _ProductTile(product: product);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});

  final SellerProduct product;

  @override
  Widget build(BuildContext context) {
    final cover = product.coverImage;
    final hasImage = cover != null && cover.hasData;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 86,
              height: 86,
              color: const Color(0xFFF1E9DD),
              child: hasImage
                  ? Image.network(
                      ApiClient().resolveMediaUrl(cover.url),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _ProductThumbFallback(),
                    )
                  : const _ProductThumbFallback(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _StatusChip(isActive: product.isActive),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  product.categoryName ?? 'Sin categoria',
                  style: const TextStyle(
                    color: Color(0xFF6B6B6B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetaPill(icon: Icons.sell_outlined, label: product.priceLabel),
                    _MetaPill(
                      icon: Icons.inventory_2_outlined,
                      label: 'Stock ${_stockLabel(product.stock)}',
                    ),
                    _MetaPill(
                      icon: Icons.scale_outlined,
                      label: product.unit ?? 'Sin unidad',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stockLabel(double stock) {
    final isWhole = stock.truncateToDouble() == stock;
    return stock.toStringAsFixed(isWhole ? 0 : 2);
  }
}

class _ProductThumbFallback extends StatelessWidget {
  const _ProductThumbFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 34,
        color: Color(0xFF8F877C),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE0F0E2) : const Color(0xFFF0E3E0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: isActive ? const Color(0xFF284826) : const Color(0xFF8A2E1B),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF284826)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  size: 42,
                  color: Color(0xFF284826),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.5, color: Color(0xFF6B6B6B)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF284826),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(buttonLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
