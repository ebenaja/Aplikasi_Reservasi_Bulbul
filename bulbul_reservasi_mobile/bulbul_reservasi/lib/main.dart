import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/landing_screen.dart'; // Import LandingScreen
import 'package:bulbul_reservasi/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Laravel Auth',
      debugShowCheckedModeBanner: false,
      home: LandingScreen(),  // Ganti jadi LandingScreen()
    );
  }
}