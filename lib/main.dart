import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/auth/models/auth_session.dart';
import 'features/auth/presentation/screens/auth_entry_screen.dart';
import 'features/seller/presentation/screens/seller_home_page.dart';
import 'pages/buyer_home_page.dart';
import 'shared/theme/agrorun_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const AgrorunApp());
}

class AgrorunApp extends StatefulWidget {
  const AgrorunApp({super.key});

  @override
  State<AgrorunApp> createState() => _AgrorunAppState();
}

class _AgrorunAppState extends State<AgrorunApp> {
  AuthSession? _session;

  void _handleLogin(AuthSession session) {
    setState(() {
      _session = session;
    });
  }

  void _handleSessionChanged(AuthSession session) {
    setState(() {
      _session = session;
    });
  }

  void _handleLogout() {
    setState(() {
      _session = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey<String>(_session == null ? 'guest' : 'user-${_session!.userId}-${_session!.roleType}'),
      debugShowCheckedModeBanner: false,
      title: 'Agrorun',
      theme: AgrorunTheme.light,
      home: _session == null
          ? AuthEntryScreen(onLoginSuccess: _handleLogin)
          : _session!.roleType == 'seller'
              ? SellerHomePage(
                  session: _session!,
                  onSessionChanged: _handleSessionChanged,
                  onLogout: _handleLogout,
                )
              : BuyerHomePage(
                  session: _session!,
                  onSessionChanged: _handleSessionChanged,
                  onLogout: _handleLogout,
                ),
    );
  }
}
