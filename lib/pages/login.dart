import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/login_layout.dart';

bool isUserValid(String email, String password) {
  return mockUsers.any((user) => user.email == email && user.password == password);
}

class WebLoginPage extends StatelessWidget {
  const WebLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 900;
            final double cardWidth = isDesktop ? 1100 : 420;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: cardWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F4EE),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: isDesktop
                      ? const DesktopLoginLayout()
                      : const MobileLoginLayout(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

