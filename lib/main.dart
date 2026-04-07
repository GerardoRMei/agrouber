import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/auth_session.dart';
import 'pages/buyer_home_page.dart';
import 'pages/login.dart';
import 'pages/rider_page.dart';
import 'pages/seller_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const CampoApp());
}

class CampoApp extends StatefulWidget {
  const CampoApp({super.key});

  @override
  State<CampoApp> createState() => _CampoAppState();
}

class _CampoAppState extends State<CampoApp> {
  AuthSession? _session;

  void _handleLogin(AuthSession session) {
    setState(() {
      _session = session;
    });
  }

  Widget _buildHomeForSession(AuthSession session) {
    switch (session.role) {
      case 'seller':
        return SellerHomePage(session: session);
      case 'delivery':
        return RiderPage(session: session);
      case 'customer':
      default:
        return BuyerHomePage(session: session);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F0EA),
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      home: _session == null
          ? WebLoginPage(onLoginSuccess: _handleLogin)
          : _buildHomeForSession(_session!),
    );
  }
}