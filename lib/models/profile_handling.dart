import 'package:flutter/material.dart';
import '../models/auth_session.dart';
import '../pages/change_password_page.dart';
import '../pages/edit_profile_page.dart';

class ProfileHandler {
  const ProfileHandler._();

  static Future<dynamic> onEditProfile(
    BuildContext context,
    AuthSession session,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfilePage(session: session),
      ),
    );
  }

  static Future<dynamic> onChangePassword(
    BuildContext context,
    AuthSession session,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangePasswordPage(session: session),
      ),
    );
  }

  static void onLogout(
    BuildContext context,
    VoidCallback onLogout,
  ) {
    onLogout();
  }
}
