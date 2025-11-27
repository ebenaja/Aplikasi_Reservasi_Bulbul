import 'package:flutter/material.dart';
// 1. WAJIB IMPORT INI UNTUK FORMAT TANGGAL INDONESIA
import 'package:intl/date_symbol_data_local.dart'; 

// Import screen Anda (sesuaikan jika path berubah, tapi ini sesuai kode Anda)
import 'package:bulbul_reservasi/screens/users/landing_screen.dart'; 

void main() async {
  // 2. Pastikan binding siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Inisialisasi Data Tanggal untuk Bahasa Indonesia ('id_ID')
  // Ini yang memperbaiki Error Layar Merah di PaymentScreen
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Precache gambar agar tidak berkedip saat loading
    precacheImage(const AssetImage("assets/images/pantai_landingscreens.jpg"), context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bulbul Reservasi',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Serif',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      
      home: LandingScreen(),
    );
  }
}