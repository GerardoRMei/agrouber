import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterHeroSection extends StatelessWidget {
  final bool isMobile;

  const RegisterHeroSection({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF21492E),
            Color(0xFF162511),
            Color(0xFF1A170F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(28),
          topRight: Radius.circular(isMobile ? 28 : 0),
          bottomLeft: Radius.circular(isMobile ? 0 : 28),
          bottomRight: Radius.zero,
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _GridOverlay()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: isMobile ? 54 : 64,
                    height: isMobile ? 54 : 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF6F685E)),
                    ),
                    child: Center(
                      child: Text(
                        isMobile ? 'YOUR\nLOGO' : 'LOGO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFE5DED2),
                          fontSize: isMobile ? 9 : 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF6F685E)),
                    ),
                    child: const Text(
                      'APP NAME',
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
              SizedBox(height: isMobile ? 24 : 42),
              Text(
                'Join the\nmovement',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: isMobile ? 34 : 52,
                  height: 0.98,
                  color: const Color(0xFFE2A23C),
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Text('Create your account and start buying fresh produce directly from local farmers.',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 16,
                    height: 1.6,
                    color: const Color(0xFFD4CEC3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GridOverlay extends StatelessWidget {
  const _GridOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      size: Size.infinite,
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x66A38A3B).withOpacity(0.12)
      ..strokeWidth = 1;

    const gap = 58.0;

    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}