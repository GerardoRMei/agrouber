import 'package:flutter/material.dart';
import 'login_forumSection.dart';
import 'login_heroSection.dart';


class DesktopLoginLayout extends StatelessWidget {
  const DesktopLoginLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: const [
          Expanded(
            flex: 5,
            child: HeroSection(),
          ),
          Expanded(
            flex: 6,
            child: FormSection(),
          ),
        ],
      ),
    );
  }
}

class MobileLoginLayout extends StatelessWidget {
  const MobileLoginLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        HeroSection(isMobile: true),
        FormSection(isMobile: true),
      ],
    );
  }
}