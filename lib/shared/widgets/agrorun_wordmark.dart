import 'package:flutter/material.dart';

import '../theme/agrorun_theme.dart';

class AgrorunWordmark extends StatelessWidget {
  const AgrorunWordmark({
    super.key,
    this.showTagline = false,
    this.compact = false,
    this.alignment = CrossAxisAlignment.start,
  });

  final bool showTagline;
  final bool compact;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final titleSize = compact ? 24.0 : 34.0;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
            children: const [
              TextSpan(
                text: 'Agro',
                style: TextStyle(color: AgrorunPalette.forest),
              ),
              TextSpan(
                text: 'run',
                style: TextStyle(color: AgrorunPalette.orange),
              ),
            ],
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 2),
          const Text(
            'Del campo a tu mesa',
            style: TextStyle(
              color: AgrorunPalette.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
