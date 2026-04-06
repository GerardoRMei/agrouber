import 'package:flutter/material.dart';

import '../../controllers/seller_flow_controller.dart';
import '../../controllers/seller_products_controller.dart';
import '../../models/seller_profile.dart';
import 'seller_product_form_screen.dart';
import 'seller_products_screen.dart';

class SellerStatusScreen extends StatelessWidget {
  const SellerStatusScreen({
    super.key,
    required this.controller,
    required this.title,
  });

  final SellerFlowController controller;
  final String title;

  @override
  Widget build(BuildContext context) {
    controller.goToStep(SellerFlowStep.status);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: const Color(0xFFF4F0E8),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final profile = controller.sellerProfile;

            return RefreshIndicator(
              onRefresh: controller.refreshStatus,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _StatusHero(profile: profile),
                  const SizedBox(height: 20),
                  if (controller.statusHint != null)
                    _InfoCard(message: controller.statusHint!),
                  if (controller.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _ErrorCard(message: controller.errorMessage!),
                  ],
                  const SizedBox(height: 20),
                  _StatusDetails(profile: profile),
                  if (profile?.canCreateProducts == true &&
                      controller.authSession != null) ...[
                    const SizedBox(height: 20),
                    _ApprovedActions(
                      controller: controller,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: controller.isLoading
                        ? null
                        : controller.canRefreshStatus
                            ? controller.refreshStatus
                            : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF284826),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: controller.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: Text(
                      controller.canRefreshStatus
                          ? 'Actualizar informacion'
                          : 'Inicia sesion para actualizar la informacion',
                    ),
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

class _ApprovedActions extends StatelessWidget {
  const _ApprovedActions({required this.controller});

  final SellerFlowController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestiona tu tienda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tu cuenta ya esta lista para publicar productos y mantener tu catalogo al dia.',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SellerProductsScreen(
                    session: controller.authSession!,
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF284826),
            ),
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Ver mis productos'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              final productsController = SellerProductsController(
                session: controller.authSession!,
              );
              productsController.loadCategories();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SellerProductFormScreen(
                    controller: productsController,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Registrar producto'),
          ),
        ],
      ),
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.profile});

  final SellerProfile? profile;

  @override
  Widget build(BuildContext context) {
    final status = profile?.status ?? SellerStatus.none;
    final palette = _paletteFor(status);
    final title = switch (status) {
      SellerStatus.pending => 'Solicitud en revision',
      SellerStatus.approved => 'Cuenta aprobada',
      SellerStatus.rejected => 'Solicitud rechazada',
      SellerStatus.none => 'Aun no tienes una solicitud',
    };
    final description = switch (status) {
      SellerStatus.pending =>
        'Ya recibimos tu informacion. Nuestro equipo la esta revisando y te avisaremos cuando haya una respuesta.',
      SellerStatus.approved =>
        'Tu cuenta esta activa y ya puedes publicar productos para comenzar a vender en Agrorun.',
      SellerStatus.rejected =>
        'Por ahora no pudimos aprobar tu solicitud. Cuando hagamos nuevos ajustes al flujo podras volver a intentarlo.',
      SellerStatus.none =>
        'No encontramos una solicitud de vendedor asociada a esta cuenta.',
    };

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(palette.icon, size: 38, color: palette.foreground),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: palette.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              height: 1.5,
              color: palette.foreground.withOpacity(0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDetails extends StatelessWidget {
  const _StatusDetails({required this.profile});

  final SellerProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles de la cuenta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(label: 'Tienda', value: profile?.storeName ?? 'Sin dato'),
          _DetailRow(
            label: 'Estado',
            value: profile?.status.name ?? SellerStatus.none.name,
          ),
          _DetailRow(
            label: 'Productos',
            value: profile?.productCount?.toString() ?? 'Sin dato',
          ),
          _DetailRow(
            label: 'Telefono',
            value: profile?.contactPhone ?? 'Sin dato',
          ),
          _DetailRow(
            label: 'Direccion',
            value: profile?.address?.fullLabel ?? 'Sin dato',
          ),
          _DetailRow(
            label: 'Almacen',
            value: profile?.assignedWarehouse?.fullLabel ?? 'Pendiente de asignacion',
          ),
          _DetailRow(
            label: 'Entrega',
            value: profile?.deliveryInstructions ?? 'Estamos preparando tus indicaciones de entrega.',
          ),
          _DetailRow(
            label: 'Descripcion',
            value: profile?.description ?? 'Sin dato',
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6D6D6D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
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
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF274D7E),
          fontWeight: FontWeight.w600,
        ),
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
        color: const Color(0xFFFFEDE6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF8A2E1B),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusPalette {
  const _StatusPalette({
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
}

_StatusPalette _paletteFor(SellerStatus status) {
  return switch (status) {
    SellerStatus.pending => const _StatusPalette(
        background: Color(0xFFFFF2DA),
        foreground: Color(0xFF8C5A07),
        icon: Icons.hourglass_top_rounded,
      ),
    SellerStatus.approved => const _StatusPalette(
        background: Color(0xFFE4F5E8),
        foreground: Color(0xFF1F6A33),
        icon: Icons.verified_rounded,
      ),
    SellerStatus.rejected => const _StatusPalette(
        background: Color(0xFFFFE6E1),
        foreground: Color(0xFF922F1E),
        icon: Icons.cancel_outlined,
      ),
    SellerStatus.none => const _StatusPalette(
        background: Color(0xFFECE9E2),
        foreground: Color(0xFF4F564D),
        icon: Icons.help_outline_rounded,
      ),
  };
}
