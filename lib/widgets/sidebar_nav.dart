import 'package:flutter/material.dart';

class SidebarNav extends StatelessWidget {
  const SidebarNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1F1209),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Campo', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 32),
          _SectionTitle('SHOP'),
          const _NavTile(icon: Icons.home_rounded, label: 'Home', isSelected: true),
          const _NavTile(icon: Icons.shopping_cart_outlined, label: 'Cart', badge: '3'),
          const _NavTile(icon: Icons.inventory_2_outlined, label: 'My Orders'),
          const SizedBox(height: 24),
          _SectionTitle('ACCOUNT'),
          const _NavTile(icon: Icons.person_outline, label: 'Profile'),
          const _NavTile(icon: Icons.settings_outlined, label: 'Settings'),
          const Spacer(),
          const _ModeSwitcher(),
        ],
      ),
    );
  }

  Widget _SectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(color: Color(0xFF8E7F74), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final String? badge;

  const _NavTile({required this.icon, required this.label, this.isSelected = false, this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF446B44) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.white : const Color(0xFFCBBEAF)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFFCBBEAF), fontWeight: FontWeight.w600))),
          if (badge != null) _Badge(text: badge!),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFE09A2C), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF2A1B12), borderRadius: BorderRadius.circular(16)),
      child: const Row(
        children: [
          Icon(Icons.shopping_bag_outlined, color: Color(0xFFB7E0A5)),
          SizedBox(width: 8),
          Text('Buyer mode', style: TextStyle(color: Color(0xFFB7E0A5), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}