import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  final String firstName;
  final String email;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  const UserProfile({
    super.key,
    required this.firstName,
    required this.email,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F0EA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Perfil de Usuario',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1209),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: const Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              firstName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F1209),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1F1209),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onEditProfile,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE09A2C),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Editar Perfil'),
            ),
            TextButton(
              onPressed: onChangePassword,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE09A2C),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Cambiar Contraseña'),
            ),
            TextButton(
              onPressed: onLogout,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE09A2C),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}