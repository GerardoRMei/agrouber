import 'package:flutter/material.dart';
import '../models/cart_state.dart'; // Importa el estado

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CartState cartState; // Recibimos el estado del carrito

  const HomeAppBar({super.key, required this.cartState});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1F1209),
      elevation: 0,
      centerTitle: false,
      title: const Padding(
        padding: EdgeInsets.only(left: 48.0),
        child: Text(
          'Agrouber',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_rounded, color: Colors.white),
          onPressed: () {},
        ),
        _CartAction(cartState: cartState),
        Padding(
          padding: const EdgeInsets.only(right: 64.0),
          child: IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CartAction extends StatelessWidget {
  final CartState cartState;
  
  const _CartAction({required this.cartState});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          Positioned(
            right: -4,
            top: -4,
            child: ListenableBuilder(
              listenable: cartState,
              builder: (context, child) {
                if (cartState.totalItems == 0) return const SizedBox.shrink();
                
                return CircleAvatar(
                  radius: 8,
                  backgroundColor: const Color(0xFFE09A2C),
                  child: Text(
                    '${cartState.totalItems}',
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          )
        ],
      ),
      onPressed: () {
        print("Productos en carrito: ${cartState.totalItems}");
      },
    );
  }
}