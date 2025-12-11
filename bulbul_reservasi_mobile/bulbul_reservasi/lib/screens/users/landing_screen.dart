import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/users/login_screen.dart';
import 'package:bulbul_reservasi/screens/users/register_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  final Color mainColor = const Color(0xFF50C2C9);
  
  // Animasi simpel agar teks muncul perlahan
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.2, 1.0, curve: Curves.easeIn)),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.2, 1.0, curve: Curves.easeOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE (Full Screen)
          Positioned.fill(
            child: Image.asset(
              'assets/images/pantai_landingscreens.jpg', 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey); // Fallback jika gambar error
              },
            ),
          ),

          // 2. GRADIENT OVERLAY (Agar teks terbaca jelas)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1), // Atas terang dikit
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.9), // Bawah gelap
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 3. KONTEN UTAMA
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- LOGO BAGIAN ATAS ---
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'app-logo',
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1)
                            ),
                            child: Icon(Icons.beach_access_rounded, color: Colors.white, size: 28),
                          ),
                        ),
                        SizedBox(width: 10),
                        Hero(
                          tag: 'app-name',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              "BulbulHolidays",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- TEXT & BUTTONS BAGIAN BAWAH ---
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HEADLINE MENARIK
                          Text(
                            "Temukan Surga\nTersembunyi",
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900, // Lebih tebal
                              color: Colors.white,
                              height: 1.1,
                              fontFamily: 'Serif', // Font elegan
                            ),
                          ),
                          
                          SizedBox(height: 15),

                          // SUBTITLE
                          Text(
                            "Nikmati keindahan Pantai Bulbul dengan fasilitas terbaik. Pesan pondok, tenda, dan wahana impianmu sekarang.",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.85),
                              height: 1.5,
                            ),
                          ),

                          SizedBox(height: 40),

                          // --- TOMBOL 1: REGISTER (UTAMA) ---
                          SizedBox(
                            width: double.infinity,
                            height: 60, // Lebih tinggi biar gagah
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, _createSmoothRoute(RegisterScreen()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: mainColor.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20), // Rounded modern
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Mulai Petualangan",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward_rounded, size: 20)
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          // --- TOMBOL 2: LOGIN (GLASSMORPHISM) ---
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(context, _createSmoothRoute(LoginScreen()));
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.1), // Transparan
                                side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                "Masuk Akun",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI TRANSISI HALUS ---
  Route _createSmoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1); 
        const end = Offset.zero;       
        const curve = Curves.easeOutQuart; 

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        // Combine slide, fade and a subtle scale for a modern feel
        final curved = CurvedAnimation(parent: animation, curve: curve);
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
              child: child,
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 600),
    );
  }
}