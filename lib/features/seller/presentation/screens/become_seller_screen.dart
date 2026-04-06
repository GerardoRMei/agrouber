import 'package:flutter/material.dart';

import '../../controllers/seller_flow_controller.dart';
import 'seller_profile_form_screen.dart';
import 'seller_status_screen.dart';

class BecomeSellerScreen extends StatelessWidget {
  const BecomeSellerScreen({
    super.key,
    required this.controller,
    this.onOpenStatusFromLogin,
  });

  final SellerFlowController controller;
  final VoidCallback? onOpenStatusFromLogin;

  @override
  Widget build(BuildContext context) {
    controller.goToStep(SellerFlowStep.intro);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de vendedor'),
      ),
      backgroundColor: const Color(0xFFF4F0E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Haz crecer tu tienda en Agrorun',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Comparte la informacion de tu negocio y nosotros nos encargamos de revisar tu solicitud para que puedas empezar a vender.',
                      style: TextStyle(
                        height: 1.5,
                        color: Color(0xFFE4EEE6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _BenefitTile(
                icon: Icons.verified_user_outlined,
                title: 'Revision segura',
                description:
                    'Validamos tu informacion para mantener una experiencia confiable para compradores y vendedores.',
              ),
              const _BenefitTile(
                icon: Icons.inventory_2_outlined,
                title: 'Tu espacio de venta',
                description:
                    'Una vez aprobada tu cuenta podras publicar productos y mantener tu catalogo actualizado.',
              ),
              const _BenefitTile(
                icon: Icons.sync_alt_rounded,
                title: 'Proceso agil',
                description:
                    'Te pediremos solo los datos esenciales para activar tu perfil comercial.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SellerProfileFormScreen(
                          controller: controller,
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF284826),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Comenzar registro'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onOpenStatusFromLogin == null
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => SellerStatusScreen(
                                controller: controller,
                                title: 'Estado de tu solicitud',
                              ),
                            ),
                          );
                        },
                  child: const Text('Ya tengo una solicitud'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
