import 'package:flutter/material.dart';

import '../widgets/register_layout.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFEDE8E0),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? 430 : 1150,
            ),
            margin: EdgeInsets.all(isMobile ? 0 : 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F1EA),
              borderRadius: BorderRadius.circular(isMobile ? 26 : 30),
              boxShadow: isMobile
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 32,
                        offset: const Offset(0, 18),
                      ),
                    ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: isMobile
                  ? const MobileRegisterLayout()
                  : const DesktopRegisterLayout(),
            ),
          ),
        ),
      ),
    );
  }
}