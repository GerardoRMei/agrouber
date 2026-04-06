import 'package:flutter/material.dart';

import '../../../account/presentation/screens/seller_account_screen.dart';
import '../../../auth/models/auth_session.dart';
import '../../controllers/seller_flow_controller.dart';
import '../../controllers/seller_products_controller.dart';
import 'seller_product_form_screen.dart';
import 'seller_products_screen.dart';
import 'seller_status_screen.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({
    super.key,
    required this.session,
    required this.onSessionChanged,
    required this.onLogout,
  });

  final AuthSession session;
  final ValueChanged<AuthSession> onSessionChanged;
  final VoidCallback onLogout;

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  late final SellerFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SellerFlowController(initialSession: widget.session);
    _controller.refreshStatus();
  }

  @override
  void didUpdateWidget(covariant SellerHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session != widget.session) {
      _controller.attachSession(widget.session);
    }
  }

  void _openProducts() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellerProductsScreen(session: widget.session),
      ),
    );
  }

  void _openCreateProduct() {
    final productsController = SellerProductsController(session: widget.session);
    productsController.loadCategories();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellerProductFormScreen(controller: productsController),
      ),
    );
  }

  void _openStatus() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellerStatusScreen(
          controller: _controller,
          title: 'Estado de mi cuenta',
        ),
      ),
    );
  }

  void _openAccount() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellerAccountScreen(
          session: widget.session,
          onSessionChanged: widget.onSessionChanged,
          onLogout: widget.onLogout,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi tienda'),
        actions: [
          IconButton(
            onPressed: _openAccount,
            icon: const Icon(Icons.person_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final profile = _controller.sellerProfile;

            if (_controller.isLoading && profile == null) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF284826)),
              );
            }

            return RefreshIndicator(
              onRefresh: _controller.refreshStatus,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Centro de ventas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hola ${widget.session.displayName}, aqui puedes revisar el estado de tu cuenta y administrar los productos de tu tienda.',
                    style: const TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  _SellerOverviewCard(
                    title: profile?.storeName.isNotEmpty == true
                        ? profile!.storeName
                        : 'Tu tienda',
                    statusLabel: profile?.status.name ?? 'sin registro',
                    productCount: profile?.productCount,
                    warehouseLabel: profile?.assignedWarehouse?.name,
                  ),
                  if (_controller.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _controller.errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFF8A2E1B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (profile?.canCreateProducts == true) ...[
                    _SellerActionCard(
                      title: 'Mis productos',
                      description: 'Consulta tu catalogo y revisa la informacion de cada producto.',
                      icon: Icons.inventory_2_outlined,
                      onTap: _openProducts,
                    ),
                    const SizedBox(height: 14),
                    _SellerActionCard(
                      title: 'Registrar producto',
                      description: 'Publica un nuevo producto para que los compradores lo encuentren.',
                      icon: Icons.add_business_outlined,
                      onTap: _openCreateProduct,
                    ),
                    const SizedBox(height: 14),
                  ],
                  _SellerActionCard(
                    title: 'Estado de la cuenta',
                    description: 'Consulta el estado de tu solicitud y los datos principales de tu tienda.',
                    icon: Icons.verified_user_outlined,
                    onTap: _openStatus,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SellerOverviewCard extends StatelessWidget {
  const _SellerOverviewCard({
    required this.title,
    required this.statusLabel,
    this.productCount,
    this.warehouseLabel,
  });

  final String title;
  final String statusLabel;
  final int? productCount;
  final String? warehouseLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1B3020),
            Color(0xFF406548),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Estado de la cuenta: $statusLabel',
            style: const TextStyle(
              color: Color(0xFFE4EEE6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _OverviewPill(
                icon: Icons.inventory_2_outlined,
                label: productCount == null
                    ? 'Sin productos publicados'
                    : '$productCount producto${productCount == 1 ? '' : 's'}',
              ),
              _OverviewPill(
                icon: Icons.warehouse_outlined,
                label: warehouseLabel ?? 'Almacen pendiente',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewPill extends StatelessWidget {
  const _OverviewPill({
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
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerActionCard extends StatelessWidget {
  const _SellerActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE5F0E2),
              foregroundColor: const Color(0xFF284826),
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
