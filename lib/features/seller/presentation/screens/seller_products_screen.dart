import 'package:flutter/material.dart';

import '../../../../data/api_client.dart';
import '../../../../shared/theme/agrorun_theme.dart';
import '../../../../shared/widgets/agrorun_wordmark.dart';
import '../../../auth/models/auth_session.dart';
import '../../controllers/seller_products_controller.dart';
import '../../models/seller_product.dart';
import 'seller_product_form_screen.dart';

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({
    super.key,
    required this.session,
  });

  final AuthSession session;

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  late final SellerProductsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SellerProductsController(session: widget.session);
    _controller.loadProducts();
  }

  Future<void> _openCreateProduct() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellerProductFormScreen(controller: _controller),
      ),
    );
  }

  Future<void> _openEditProduct(SellerProduct product) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellerProductFormScreen(
          controller: _controller,
          initialProduct: product,
        ),
      ),
    );
  }

  Future<void> _openProductModal(SellerProduct product) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return _ProductActionsSheet(
              product: product,
              isSubmitting: _controller.isSubmitting,
              errorMessage: _controller.errorMessage,
              onEdit: () async {
                Navigator.of(sheetContext).pop();
                await _openEditProduct(product);
              },
              onToggleActive: () async {
                final ok = await _controller.toggleActive(product);
                if (!mounted || !ok) {
                  return;
                }
                Navigator.of(sheetContext).pop();
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AgrorunWordmark(compact: true),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateProduct,
        backgroundColor: AgrorunPalette.forest,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AgrorunPalette.forest),
            );
          }

          if (_controller.errorMessage != null && _controller.products.isEmpty) {
            return _StateMessage(
              title: 'No pudimos cargar tu catálogo',
              message: _controller.errorMessage!,
              buttonLabel: 'Reintentar',
              onPressed: _controller.loadProducts,
            );
          }

          if (_controller.products.isEmpty) {
            return _StateMessage(
              title: 'Tu catálogo todavía está vacío',
              message:
                  'Publica tu primer producto para empezar a recibir atención dentro de Agrorun.',
              buttonLabel: 'Agregar producto',
              onPressed: _openCreateProduct,
            );
          }

          return RefreshIndicator(
            onRefresh: _controller.loadProducts,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemBuilder: (context, index) {
                final product = _controller.products[index];
                return _ProductTile(
                  product: product,
                  onMore: () => _openProductModal(product),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: _controller.products.length,
            ),
          );
        },
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.onMore,
  });

  final SellerProduct product;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductThumb(product: product),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(width: 8),
                    _StatusChip(isActive: product.isActive),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  product.categoryName ?? 'Producto sin categoria',
                  style: const TextStyle(
                    color: AgrorunPalette.textMuted,
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
                      icon: Icons.inventory_outlined,
                      label: _stockLabel(product.stock),
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
          IconButton(
            onPressed: onMore,
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
    );
  }

  String _stockLabel(double stock) {
    final isWhole = stock.truncateToDouble() == stock;
    return 'Stock ${stock.toStringAsFixed(isWhole ? 0 : 2)}';
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.product});

  final SellerProduct product;

  @override
  Widget build(BuildContext context) {
    final cover = product.coverImage;
    final hasImage = cover != null && cover.hasData;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
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
    );
  }
}

class _ProductThumbFallback extends StatelessWidget {
  const _ProductThumbFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        color: AgrorunPalette.forest,
        size: 30,
      ),
    );
  }
}

class _ProductActionsSheet extends StatelessWidget {
  const _ProductActionsSheet({
    required this.product,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onEdit,
    required this.onToggleActive,
  });

  final SellerProduct product;
  final bool isSubmitting;
  final String? errorMessage;
  final Future<void> Function() onEdit;
  final Future<void> Function() onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7D0C4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (product.images.isNotEmpty) ...[
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: product.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final image = product.images[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        ApiClient().resolveMediaUrl(image.url),
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 88,
                          height: 88,
                          color: const Color(0xFFF1E9DD),
                          child: const Icon(Icons.photo_outlined),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
            ],
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.categoryName ?? 'Producto sin categoria',
              style: const TextStyle(
                color: AgrorunPalette.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetaPill(icon: Icons.sell_outlined, label: product.priceLabel),
                _MetaPill(
                  icon: Icons.inventory_outlined,
                  label: 'Stock ${product.stock.toStringAsFixed(product.stock.truncateToDouble() == product.stock ? 0 : 2)}',
                ),
                _MetaPill(
                  icon: Icons.scale_outlined,
                  label: product.unit ?? 'Sin unidad',
                ),
                if (product.minOrderQty != null)
                  _MetaPill(
                    icon: Icons.shopping_basket_outlined,
                    label:
                        'Min. ${product.minOrderQty!.toStringAsFixed(product.minOrderQty!.truncateToDouble() == product.minOrderQty! ? 0 : 2)}',
                  ),
              ],
            ),
            if ((product.description ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                product.description!,
                style: const TextStyle(height: 1.5),
              ),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: const TextStyle(
                  color: Color(0xFF8A2E1B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSubmitting ? null : onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar producto'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isSubmitting ? null : onToggleActive,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AgrorunPalette.forest,
                        ),
                      )
                    : Icon(
                        product.isActive
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                label: Text(
                  product.isActive ? 'Desactivar producto' : 'Activar producto',
                ),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE4F5E8) : const Color(0xFFFFE6E1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: isActive ? const Color(0xFF1F6A33) : const Color(0xFF922F1E),
          fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF284826)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF284826),
              ),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
