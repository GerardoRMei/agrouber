import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  final bool isMobile;

  const HeroSection({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF24140B),
            Color(0xFF274326),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(28),
          bottomLeft: isMobile ? Radius.zero : const Radius.circular(28),
          topRight: const Radius.circular(28),
          bottomRight: isMobile ? Radius.zero : Radius.zero,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF6F685E)),
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Image(
                      image: AssetImage('logoAgrorun.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF6F685E)),
                ),
                child: const Text(
                  'AgroRun',
                  style: TextStyle(
                    color: Color(0xFFE5DED2),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 26 : 42),
          Text(
            'Bienvenido de vuelta a AgroRun',
            style: TextStyle(
              fontSize: isMobile ? 34 : 48,
              height: 1.0,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFE2A23C),
            ),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              'Inicia sesión para gestionar pedidos, revisar compras y conectarte directamente con productores agrícolas.',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                height: 1.6,
                color: const Color(0xFFD4CEC3),
              ),
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
