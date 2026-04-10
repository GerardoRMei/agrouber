import 'package:flutter/material.dart';
import '../models/auth_session.dart';
import 'UserProfile.dart';
import '../models/profile_handling.dart';

class RiderHeader extends StatelessWidget {
  final AuthSession session;
  final VoidCallback onLogout;
  const RiderHeader({super.key, required this.session, required this.onLogout});

  void _openUserProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserProfile(
        username: session.username.isNotEmpty
            ? session.username
            : session.email,
        email: session.email,
        onEditProfile: () {
          Navigator.pop(context);
          ProfileHandler.onEditProfile(context, session);
        },
        onChangePassword: () {
          Navigator.pop(context);
          ProfileHandler.onChangePassword(context, session);
        },
        onLogout: () {
          Navigator.pop(context);
          ProfileHandler.onLogout(context, onLogout);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF2F4B2F), // verde oscuro consistente
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'AgroRun',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.notifications_none, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Padding(
          padding: EdgeInsets.only(right: 20),
          child: IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {_openUserProfile(context);},
          ),
        ),
        ],
      ),
    );
  }
}