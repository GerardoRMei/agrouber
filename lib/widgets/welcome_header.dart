import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  final String userName;
  const WelcomeHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $userName',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const Text(
          'What are you looking for today?',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}