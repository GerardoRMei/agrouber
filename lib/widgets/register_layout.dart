import 'package:flutter/material.dart';

import 'register_formSection.dart';
import 'register_heroSection.dart';

class DesktopRegisterLayout extends StatelessWidget {
  const DesktopRegisterLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: const [
          Expanded(
            flex: 5,
            child: RegisterHeroSection(),
          ),
          Expanded(
            flex: 6,
            child: RegisterFormSection(),
          ),
        ],
      ),
    );
  }
}

class MobileRegisterLayout extends StatelessWidget {
  const MobileRegisterLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        RegisterHeroSection(isMobile: true),
        RegisterFormSection(isMobile: true),
      ],
    );
  }
}