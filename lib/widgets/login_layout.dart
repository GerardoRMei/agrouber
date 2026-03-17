import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import 'login_forumSection.dart';
import 'login_heroSection.dart';

class DesktopLoginLayout extends StatelessWidget {
  const DesktopLoginLayout({
    super.key,
    required this.onLoginSuccess,
  });

  final ValueChanged<AuthSession> onLoginSuccess;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          const Expanded(
            flex: 5,
            child: HeroSection(),
          ),
          Expanded(
            flex: 6,
            child: FormSection(onLoginSuccess: onLoginSuccess),
          ),
        ],
      ),
    );
  }
}

class MobileLoginLayout extends StatelessWidget {
  const MobileLoginLayout({
    super.key,
    required this.onLoginSuccess,
  });

  final ValueChanged<AuthSession> onLoginSuccess;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HeroSection(isMobile: true),
        FormSection(
          isMobile: true,
          onLoginSuccess: onLoginSuccess,
        ),
      ],
    );
  }
}
