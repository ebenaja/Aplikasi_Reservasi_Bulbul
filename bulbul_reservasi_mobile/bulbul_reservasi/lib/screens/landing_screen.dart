import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/login_screen.dart';
import 'package:bulbul_reservasi/screens/register_screen.dart';

class LandingScreen extends StatelessWidget {
  // Warna Utama (Tosca)
  final Color mainColor = Color(0xFF50C2C9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              // Pastikan nama file benar (Saya hapus 's' sesuai perbaikan sebelumnya)
              'assets/images/pantai_landingscreens.jpg', 
              fit: BoxFit.cover,
              cacheWidth: 800, // Tetap dipertahankan agar ringan
            ),
          ),

          // 2. GRADIENT OVERLAY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: [0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 3. KONTEN
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // JUDUL
                  Text(
                    "BulbulHolidays",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: "Serif",
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4.0,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 12),

                  // SUBJUDUL
                  Text(
                    "Cari Reservasi Mu \ndi Pantai BULBUL kita tercinta.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: 40),

                  // --- TOMBOL 1: GET STARTED ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Gunakan Transisi Smooth ke Register
                        Navigator.push(
                          context,
                          _createSmoothRoute(RegisterScreen()), 
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // --- TOMBOL 2: LOGIN ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {
                        // Gunakan Transisi Smooth ke Login
                        Navigator.push(
                          context,
                          _createSmoothRoute(LoginScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white, width: 2.0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                             Shadow(
                              blurRadius: 2,
                              color: Colors.black26,
                              offset: Offset(0, 1),
                            )
                          ]
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI TRANSISI HALUS (SMOOTH TRANSITION) ---
  Route _createSmoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        
        // Konfigurasi Animasi
        const begin = Offset(0.0, 0.1); // Muncul sedikit dari bawah (10%)
        const end = Offset.zero;        // Ke posisi normal
        const curve = Curves.easeOutQuart; // Gerakan luwes (cepat di awal, pelan di akhir)

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition( // Gabungkan dengan Fade (Muncul perlahan)
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 600), // Durasi 0.6 detik (Pas, tidak terlalu cepat/lambat)
    );
  }
}