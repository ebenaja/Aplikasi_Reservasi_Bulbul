import 'dart:ui'; // Import penting untuk efek Blur
import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/register_screen.dart';
import 'package:bulbul_reservasi/screens/home_screen.dart';
import 'package:bulbul_reservasi/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final AuthService _authService = AuthService();

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login() async {
    // Logic Login Tetap Sama
    final email = _emailController.text;
    final password = _passwordController.text;

    // Simulasi login sementara
    if (email.isNotEmpty && password.isNotEmpty) {
      // TODO: Ganti dengan _authService.login(email, password) nanti
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Silakan isi email dan password"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Helper untuk gaya Input Field agar rapi dan konsisten
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.15), // Latar transparan
      hintStyle: TextStyle(color: Colors.white70), // Hint text agak pudar
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none, // Hilangkan garis border default
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.white30, width: 1), // Border tipis saat diam
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.white, width: 1.5), // Border putih saat diketik
      ),
    );

    return Scaffold(
      // Extend body agar gambar background memenuhi area status bar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE (Sama dengan Landing Screen)
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/pantai_landingscreen.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. OVERLAY GELAP TIPIS (Agar teks lebih terbaca)
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // 3. FORM CONTENT (Center + Scrollable)
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Judul
                  Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    "Login to BulbulHolidays",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: "Serif",
                    ),
                  ),
                  SizedBox(height: 40),

                  // KARTU KACA (GLASS CARD)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4), // Warna kaca gelap
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white24), // Border kaca tipis
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Label Email
                            Text("Email / Username", 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            SizedBox(height: 8),
                            // Input Email
                            TextField(
                              controller: _emailController,
                              style: TextStyle(color: Colors.white), // Teks input putih
                              decoration: inputDecoration.copyWith(
                                hintText: "Enter your email",
                                prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
                              ),
                            ),
                            
                            SizedBox(height: 20),

                            // Label Password
                            Text("Password", 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            SizedBox(height: 8),
                            // Input Password
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(color: Colors.white),
                              decoration: inputDecoration.copyWith(
                                hintText: "Enter your password",
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                              ),
                            ),

                            SizedBox(height: 10),

                            // Remember Me & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: Colors.white,
                                        checkColor: Colors.black,
                                        side: BorderSide(color: Colors.white70),
                                        onChanged: (val) {
                                          setState(() {
                                            _rememberMe = val ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text("Remember me", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 20),

                            // Tombol Login
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, // Tombol Putih Kontras
                                  foregroundColor: Colors.black, // Teks Hitam
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  "Log In",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Footer Register
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "Don’t have an account? ",
                        style: TextStyle(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: "Register",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          )
                        ],
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
}