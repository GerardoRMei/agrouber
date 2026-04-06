import 'package:flutter/material.dart';

import 'register_formSection.dart';
import 'register_heroSection.dart';

class DesktopRegisterLayout extends StatelessWidget {
  const DesktopRegisterLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: RegisterHeroSection(),
          ),
          Expanded(
            flex: 6,
            child: RegisterFormSection(
              isMobile: false,
              onBackToLogin: () {Navigator.of(context).pop();},
            ),
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
      children: [
        RegisterHeroSection(isMobile: true),
        RegisterFormSection(isMobile: true, onBackToLogin: () {Navigator.of(context).pop();},),
      ],
    );
  }
}