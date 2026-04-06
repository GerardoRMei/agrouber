import 'package:flutter/material.dart';

import '../../../../shared/theme/agrorun_theme.dart';
import '../../controllers/buyer_cart_controller.dart';
import '../../models/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.controller,
    required this.customerName,
  });

  final BuyerCartController controller;
  final String customerName;

  Future<void> _confirmPurchase(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    controller.clear();
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Tu pedido fue registrado. Te notificaremos cuando el vendedor lo confirme.',
        ),
      ),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tu carrito')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (controller.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 36,
                        color: AgrorunPalette.forest,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Tu carrito esta vacio',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Agrega productos para simular una compra completa dentro de Agrorun.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.5,
                        color: AgrorunPalette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AgrorunPalette.forestDark,
                        AgrorunPalette.forest,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido de $customerName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Revisa tu seleccion, ajusta cantidades y confirma el pedido para simular la compra.',
                        style: TextStyle(
                          height: 1.5,
                          color: Color(0xFFE6F0E7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ...controller.items.map(
                  (item) => _CartItemCard(
                    item: item,
                    onIncrease: () => controller.increment(item.product),
                    onDecrease: () => controller.decrement(item.product),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'Subtotal',
                        value: '\$${controller.subtotal.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        label: 'Servicio de la plataforma',
                        value: '\$${controller.serviceFee.toStringAsFixed(2)}',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1),
                      ),
                      _SummaryRow(
                        label: 'Total estimado',
                        value: '\$${controller.total.toStringAsFixed(2)}',
                        emphasize: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => _confirmPurchase(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Confirmar pedido'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
  });

  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '\$${item.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AgrorunPalette.forest,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${item.product.priceDisplay} / ${item.product.categoryName}',
            style: const TextStyle(
              color: AgrorunPalette.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: onDecrease,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 42,
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: onIncrease,
                style: IconButton.styleFrom(
                  backgroundColor: AgrorunPalette.forest,
                ),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: emphasize ? 18 : 15,
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
      color: emphasize ? AgrorunPalette.textPrimary : AgrorunPalette.textMuted,
    );

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}
