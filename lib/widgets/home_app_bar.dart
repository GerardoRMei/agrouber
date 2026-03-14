import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_rounded, color: Colors.white),
          onPressed: () {},
        ),
        const _CartAction(count: '3'),
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
  final String count;
  const _CartAction({required this.count});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          Positioned(
            right: 0,
            top: 0,
            child: CircleAvatar(
              radius: 7,
              backgroundColor: const Color(0xFFE09A2C),
              child: Text(
                count,
                style: const TextStyle(fontSize: 9, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      onPressed: () {},
    );
  }
}