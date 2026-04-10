import 'package:flutter/material.dart';

import '../data/seller_api_service.dart';
import '../models/auth_session.dart';
import '../models/seller_profile.dart';
import 'seller_product_form_page.dart';
import 'seller_products_page.dart';
import '../widgets/UserProfile.dart';
import '../models/profile_handling.dart';

class SellerHomePage extends StatefulWidget {
  
  const SellerHomePage({
    super.key,
    required this.session,
    required this.onLogout,
  });

  final AuthSession session;
  final VoidCallback onLogout;

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  final SellerApiService _sellerApiService = SellerApiService();

  bool _isLoading = true;
  String? _errorMessage;
  String? _statusHint;
  SellerProfile? _profile;
  void _openUserProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserProfile(
        username: widget.session.username.isNotEmpty
            ? widget.session.username
            : widget.session.email,
        email: widget.session.email,
        onEditProfile: () {
          Navigator.pop(context);
          ProfileHandler.onEditProfile(context, widget.session);
        },
        onChangePassword: () {
          Navigator.pop(context);
          ProfileHandler.onChangePassword(context, widget.session);
        },
        onLogout: () {
          Navigator.pop(context);
          ProfileHandler.onLogout(context, widget.onLogout);
        },
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _loadSellerData();
  }

  Future<void> _loadSellerData() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final me = await _sellerApiService.fetchSellerStatus(widget.session);
    final dashboard =
        await _sellerApiService.fetchSellerDashboard(widget.session);
    final warehouse =
        await _sellerApiService.fetchWarehouseAssignment(widget.session);
    final productsCount =
        await _sellerApiService.fetchMyProductsCount(widget.session);

    final effectiveStatus =
        dashboard.status != SellerStatus.none ? dashboard.status : me.status;

    final merged = dashboard.copyWith(
      id: me.id,
      documentId: me.documentId,
      storeName: me.storeName.isNotEmpty ? me.storeName : dashboard.storeName,
      description: me.description,
      contactPhone: me.contactPhone,
      isVerified: me.isVerified,
      address: me.address,
      status: effectiveStatus,
      productCount: dashboard.productCount ?? me.productCount ?? productsCount,
      assignedWarehouse: warehouse.assignedWarehouse ?? me.assignedWarehouse,
      warehouseAssignmentStatus:
          warehouse.warehouseAssignmentStatus != WarehouseAssignmentStatus.none
              ? warehouse.warehouseAssignmentStatus
              : me.warehouseAssignmentStatus,
      deliveryInstructions:
          warehouse.deliveryInstructions ??
          me.deliveryInstructions ??
          dashboard.deliveryInstructions,
      canCreateProducts:
          dashboard.canCreateProducts ?? (effectiveStatus == SellerStatus.approved),
      canDeliverToWarehouse:
          dashboard.canDeliverToWarehouse ?? false,
      canEditProfile:
          dashboard.canEditProfile ?? true,
    );

    if (!mounted) return;

    setState(() {
      _profile = merged;
      _statusHint = merged.deliveryInstructions ??
          'Actualizamos la informacion mas reciente de tu cuenta.';
      _isLoading = false;
    });
  } catch (error) {
    if (!mounted) return;

    setState(() {
      _errorMessage = error.toString();
      _isLoading = false;
    });
  }
}

  Future<void> _openProducts() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellerProductsPage(session: widget.session),
      ),
    );
    if (mounted) {
      await _loadSellerData();
    }
  }

  Future<void> _openCreateProduct() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SellerProductFormPage(session: widget.session),
      ),
    );

    if (created == true && mounted) {
      await _loadSellerData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto registrado correctamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final canCreateProducts = profile?.canCreateProducts == true;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1209),
        foregroundColor: Colors.white,
        title: const Text(
          'Mi tienda',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        
        actions: [
          Padding(
          padding: EdgeInsets.only(right: 16),
          child: IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {_openUserProfile(context);},
          ),
        ),
          IconButton(
            onPressed: _isLoading ? null : _loadSellerData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (_isLoading && profile == null) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A7A4D)),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadSellerData,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth >= 900 ? 48 : 20,
                  vertical: 24,
                ),
                children: [
                  Text(
                    'Hola ${widget.session.displayName}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Aqui puedes revisar el estado de tu cuenta de seller y administrar tu catalogo.',
                    style: TextStyle(
                      height: 1.5,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SellerOverviewCard(profile: profile),
                  if (_statusHint != null) ...[
                    const SizedBox(height: 16),
                    _InfoCard(message: _statusHint!),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _ErrorCard(message: _errorMessage!),
                  ],
                  const SizedBox(height: 20),
                  _buildActionGrid(canCreateProducts),
                  const SizedBox(height: 20),
                  _StatusDetailsCard(profile: profile),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionGrid(bool canCreateProducts) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _ActionCard(
          title: 'Mis productos',
          description: canCreateProducts
              ? 'Consulta tu catalogo actual y revisa precios, stock y estado.'
              : 'Tu catalogo estara disponible en cuanto tu cuenta quede aprobada.',
          icon: Icons.inventory_2_outlined,
          enabled: canCreateProducts,
          onTap: canCreateProducts ? _openProducts : null,
        ),
        _ActionCard(
          title: 'Registrar producto',
          description: canCreateProducts
              ? 'Publica un nuevo producto para que aparezca en el marketplace.'
              : 'Esta opcion se habilita cuando approvalStatus sea approved.',
          icon: Icons.add_business_outlined,
          enabled: canCreateProducts,
          onTap: canCreateProducts ? _openCreateProduct : null,
        ),
      ],
    );
  }
}

class _SellerOverviewCard extends StatelessWidget {
  const _SellerOverviewCard({required this.profile});

  final SellerProfile? profile;

  @override
  Widget build(BuildContext context) {
    final storeTitle = profile?.storeName.isNotEmpty == true
        ? profile!.storeName
        : 'Tu tienda';
    final statusLabel = _statusText(profile?.status ?? SellerStatus.none);
    final warehouseLabel = profile?.assignedWarehouse?.name ?? 'Almacen pendiente';
    final productsLabel = profile?.productCount == null
        ? 'Sin productos publicados'
        : '${profile!.productCount} producto${profile!.productCount == 1 ? '' : 's'}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
            storeTitle,
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _OverviewPill(
                icon: Icons.inventory_2_outlined,
                label: productsLabel,
              ),
              _OverviewPill(
                icon: Icons.warehouse_outlined,
                label: warehouseLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusText(SellerStatus status) {
    switch (status) {
      case SellerStatus.pending:
        return 'pendiente';
      case SellerStatus.approved:
        return 'aprobada';
      case SellerStatus.rejected:
        return 'rechazada';
      case SellerStatus.none:
        return 'sin registro';
    }
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

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: enabled ? onTap : null,
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: enabled ? Colors.transparent : const Color(0xFFE6DED4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: enabled
                    ? const Color(0xFFE5F0E2)
                    : const Color(0xFFF1ECE4),
                foregroundColor: enabled
                    ? const Color(0xFF284826)
                    : const Color(0xFF8F877C),
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
              Icon(
                enabled
                    ? Icons.chevron_right_rounded
                    : Icons.lock_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDetailsCard extends StatelessWidget {
  const _StatusDetailsCard({required this.profile});

  final SellerProfile? profile;

  @override
  Widget build(BuildContext context) {
    final status = profile?.status ?? SellerStatus.none;
    final address = profile?.address?.fullLabel ?? 'Sin direccion registrada';
    final warehouse = profile?.assignedWarehouse?.fullLabel ?? 'Sin almacen asignado';
    final contactPhone = profile?.contactPhone ?? 'Sin telefono registrado';
    final deliveryInstructions =
        profile?.deliveryInstructions ?? 'Sin instrucciones logisticas por ahora';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado de la cuenta',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow(label: 'Approval status', value: _statusLabel(status)),
          _DetailRow(label: 'Telefono de contacto', value: contactPhone),
          _DetailRow(label: 'Direccion de la tienda', value: address),
          _DetailRow(label: 'Almacen asignado', value: warehouse),
          _DetailRow(label: 'Indicaciones logisticas', value: deliveryInstructions),
        ],
      ),
    );
  }

  String _statusLabel(SellerStatus status) {
    switch (status) {
      case SellerStatus.pending:
        return 'Pendiente';
      case SellerStatus.approved:
        return 'Aprobado';
      case SellerStatus.rejected:
        return 'Rechazado';
      case SellerStatus.none:
        return 'Sin solicitud';
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Color(0xFF8F877C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4E9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF284826)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                height: 1.45,
                color: Color(0xFF284826),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9E8E3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFF8A2E1B)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                height: 1.45,
                color: Color(0xFF8A2E1B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
