import 'package:flutter/material.dart';
// Importamos los nuevos archivos que creamos
import 'pages/buyer_home_page.dart';

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
        fontFamily: 'Arial',
      ),
      home: const BuyerHomePage(), 
    );
  }
}
