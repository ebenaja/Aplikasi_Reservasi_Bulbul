import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/landing_screen.dart';

void main() {
  runApp(MyApp());
}

// Ubah ke StatefulWidget untuk Precache Gambar
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  // Fungsi ini berjalan otomatis saat aplikasi dimuat
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 1. PRECACHE IMAGE (RAHASIA AGAR TIDAK PATAH-PATAH)
    // Ini memaksa Flutter memuat gambar ke RAM sebelum ditampilkan.
    precacheImage(AssetImage("assets/images/pantai_landingscreens.jpg"), context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bulbul Reservasi',
      debugShowCheckedModeBanner: false,
      
      // 2. SETUP TEMA AGAR SMOOTH
      theme: ThemeData(
        useMaterial3: true, // Rendering lebih efisien
        fontFamily: 'Serif', // Menyesuaikan font yang Anda pakai sebelumnya
        
        // Pengaturan Transisi Halaman Global (Agar slide/pindahnya halus)
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(), // Efek Zoom halus
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      
      home: LandingScreen(),
    );
  }
}