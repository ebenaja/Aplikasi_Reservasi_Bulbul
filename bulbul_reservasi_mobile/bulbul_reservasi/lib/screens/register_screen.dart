import 'dart:ui'; // PENTING: Import untuk efek Blur
import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/auth_service.dart';
import 'package:bulbul_reservasi/screens/login_screen.dart'; // Pastikan import ini ada untuk navigasi balik

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true; // Untuk fitur lihat/sembunyi password
  final AuthService _authService = AuthService();
  bool _isLoading = false; // Untuk loading indicator saat register

  void _register() async {
    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua kolom')),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Panggil API register
    final response = await _authService.register(name, email, password);

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi Berhasil! Silahkan Login'),
          backgroundColor: Colors.green,
        ),
      );
      // Kembali ke layar login setelah sukses
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi Gagal. Coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Style input yang konsisten dengan Login Screen
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.15),
      hintStyle: TextStyle(color: Colors.white70),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.white30, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.white, width: 1.5),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true, // Agar background full sampai atas
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Create Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/pantai_landingscreen.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. OVERLAY GELAP
          Container(color: Colors.black.withOpacity(0.3)),

          // 3. FORM CONTENT
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Join BulbulHolidays",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: "Serif",
                    ),
                  ),
                  Text(
                    "Sign up to start your journey",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 30),

                  // GLASS CARD CONTAINER
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // NAMA
                            Text("Full Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              style: TextStyle(color: Colors.white),
                              decoration: inputDecoration.copyWith(
                                hintText: "Enter your full name",
                                prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
                              ),
                            ),
                            SizedBox(height: 20),

                            // EMAIL
                            Text("Email Address", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              style: TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: inputDecoration.copyWith(
                                hintText: "Enter your email",
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
                              ),
                            ),
                            SizedBox(height: 20),

                            // PASSWORD
                            Text("Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            SizedBox(height: 8),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(color: Colors.white),
                              decoration: inputDecoration.copyWith(
                                hintText: "Create a password",
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 30),

                            // TOMBOL REGISTER
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, // Putih
                                  foregroundColor: Colors.black, // Teks Hitam
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 5,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: 24, width: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                      )
                                    : Text(
                                        "Register",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // FOOTER LOGIN LINK
                  GestureDetector(
                    onTap: () => Navigator.pop(context), // Kembali ke Login
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: "Login",
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