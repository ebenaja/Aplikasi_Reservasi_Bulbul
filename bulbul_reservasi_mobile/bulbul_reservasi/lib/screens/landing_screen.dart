import 'dart:ui'; // PENTING: Untuk efek Blur (ImageFilter)
import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/login_screen.dart';
import 'package:bulbul_reservasi/screens/register_screen.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stack memungkinkan kita menumpuk widget (Gambar di bawah, Container di atas)
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE
          // Menggunakan Positioned.fill agar gambar memenuhi seluruh layar
          Positioned.fill(
            child: Image.asset(
              'assets/images/pantai_landingscreen.jpg', // Pastikan path sesuai
              fit: BoxFit.cover,
            ),
          ),

          // 2. BOTTOM GLASS CONTAINER
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              // Membuat sudut atas melengkung
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              child: BackdropFilter(
                // Efek blur kaca
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  width: double.infinity,
                  // Tinggi container (diatur cukup besar agar tidak overflow/garis kuning)
                  height: 400, 
                  decoration: BoxDecoration(
                    // Gradasi Hitam Transparan (atas bening, bawah pekat)
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3), // Atas: Hitam 30%
                        Colors.black.withOpacity(0.8), // Bawah: Hitam 80%
                      ],
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Judul
                      Text(
                        "BulbulHolidays",
                        style: TextStyle(
                          fontFamily: "Serif",
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          letterSpacing: 1.2,
                          color: Colors.white, // Teks Putih
                        ),
                      ),
                      SizedBox(height: 10),
                      
                      // Subjudul
                      Text(
                        "Find your rental home with comfort\nSimplicity, location, Economy.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70, // Putih agak transparan
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 30),
                      
                      // Tombol Get Started
                      SizedBox(
                        width: double.infinity, // Lebar penuh
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Arahkan ke HomeScreen nantinya
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Tombol Putih
                            foregroundColor: Colors.black, // Teks Hitam
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Tombol Login (Teks Saja)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54),
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.black.withOpacity(0.3)
                          ),
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Link Register (Opsional, tetap ada tapi disesuaikan warnanya)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterScreen()),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Don’t have an account? ",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                            children: [
                              TextSpan(
                                text: "Register",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}