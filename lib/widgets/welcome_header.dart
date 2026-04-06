import 'package:flutter/material.dart';

import '../shared/theme/agrorun_theme.dart';

class WelcomeHeader extends StatelessWidget {
  final String userName;
  const WelcomeHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, $userName',
          maxLines: isMobile ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isMobile ? 22 : 30,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: AgrorunPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Descubre productos frescos de productores y tiendas cercanas.',
          style: TextStyle(
            color: AgrorunPalette.textMuted,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
