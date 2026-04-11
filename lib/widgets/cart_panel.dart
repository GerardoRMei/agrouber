import 'package:agrouber/models/auth_session.dart';
import 'package:agrouber/pages/checkout_page.dart';
import 'package:flutter/material.dart';
import '../models/cart_state.dart';

class CartPanel extends StatelessWidget {
  final CartState cartState;
  final bool isDrawer;
  final AuthSession session;

  const CartPanel({
    super.key,
    required this.cartState,
    required this.session,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0EA),
        borderRadius: isDrawer
            ? BorderRadius.zero
            : const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: cartState,
          builder: (context, child) {
            final items = cartState.items;

            if (items.isEmpty) {
              return _buildEmptyCart(context);
            }

            double subtotal = 0.0;
            for (var item in items) {
              subtotal += item.finalPrice;
            }

            return Column(
              mainAxisSize: isDrawer ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tu Carrito',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F1209),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  fit: isDrawer ? FlexFit.tight : FlexFit.loose,
                  child: ListView.separated(
                    shrinkWrap: !isDrawer,
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      
                      final qtyDisplay = item.quantity.truncateToDouble() == item.quantity 
                          ? item.quantity.toStringAsFixed(0) 
                          : item.quantity.toStringAsFixed(1);

                      return Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(item.product.visual, style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'de ${item.option.sellerName}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9EFE3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$qtyDisplay ${item.unitLabel}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E4F2F)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${item.finalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16, 
                                  color: Color(0xFF4A7A4D), 
                                  fontWeight: FontWeight.w800
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () {
                                  cartState.removeProduct(item);
                                },
                                child: const Text(
                                  'Eliminar',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                const Divider(thickness: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1F1209),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E4F2F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(cartState: cartState, session: session,),
                        ),
                      );
                    },
                    child: const Text(
                      'Proceder al pago',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Column(
      mainAxisSize: isDrawer ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: isDrawer ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (isDrawer) const Spacer(),
        const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Tu carrito está vacío',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '¡Agrega algunos productos frescos del campo!',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Seguir comprando', style: TextStyle(color: Color(0xFF4A7A4D), fontSize: 16)),
          ),
        ),
        if (isDrawer) const Spacer(),
      ],
    );
  }
}