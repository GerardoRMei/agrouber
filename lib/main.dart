import 'package:flutter/material.dart';
import 'pages/buyer_home_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const CampoApp());
}

class CampoApp extends StatelessWidget {
  const CampoApp({super.key});

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
      home: const BuyerHomePage(), 
    );
  }
}
