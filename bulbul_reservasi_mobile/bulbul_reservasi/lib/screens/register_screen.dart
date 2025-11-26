import 'dart:convert'; // PENTING: Untuk membaca respon JSON dari server
import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/auth_service.dart';
import 'package:bulbul_reservasi/screens/login_screen.dart';
import 'package:bulbul_reservasi/screens/landing_screen.dart'; // Import Landing

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final Color mainColor = Color(0xFF50C2C9);

  void _register() async {
    FocusManager.instance.primaryFocus?.unfocus(); // Tutup keyboard

    // Validasi Input Awal
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Harap isi semua kolom", Colors.orange);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Password konfirmasi tidak sama", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil API Register
      final response = await _authService.register(name, email, password);

      if (mounted) setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // --- SUKSES ---
        _showSnackBar("Registrasi Berhasil! Silahkan Login", mainColor);
        
        if (mounted) {
          // Pindah ke Login Screen
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => LoginScreen())
          );
        }
      } else {
        // --- GAGAL (BACA ERROR DARI SERVER) ---
        // Contoh: "The email has already been taken."
        String errorMessage = "Registrasi Gagal. Coba lagi.";
        try {
          final body = jsonDecode(response.body);
          if (body['message'] != null) {
            errorMessage = body['message'];
          }
          // Jika Laravel mengirim error validasi field
          if (body['errors'] != null) {
            errorMessage = body['errors'].values.first[0]; 
          }
        } catch (e) {
          print("Error parsing response: $e");
        }
        
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showSnackBar("Terjadi kesalahan koneksi", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // Dekorasi Background
          Positioned(top: -50, left: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: mainColor.withOpacity(0.3)))),
          Positioned(top: -20, left: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: mainColor.withOpacity(0.3)))),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  left: 24, 
                  right: 24, 
                  top: 10, 
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- TOMBOL BACK (AMAN) ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        await Future.delayed(Duration(milliseconds: 100));
                        
                        if (context.mounted) {
                          // Jika tumpukan navigasi kosong, paksa ke LandingScreen
                          // Jika ada, pop biasa
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => LandingScreen()),
                              (route) => false
                            );
                          }
                        }
                      },
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  Text("Welcome Onboard!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 10),
                  Text("Let’s help you meet up your tasks.", style: TextStyle(fontSize: 14, color: Colors.black54)),
                  SizedBox(height: 40),

                  // INPUT FIELDS
                  _buildCustomTextField(controller: _nameController, hintText: "Enter your full name", icon: Icons.person_outline),
                  SizedBox(height: 16),
                  _buildCustomTextField(controller: _emailController, hintText: "Enter your email", keyboardType: TextInputType.emailAddress, icon: Icons.email_outlined),
                  SizedBox(height: 16),
                  _buildCustomTextField(controller: _passwordController, hintText: "Create password", obscureText: true, icon: Icons.lock_outline),
                  SizedBox(height: 16),
                  _buildCustomTextField(controller: _confirmPasswordController, hintText: "Confirm password", obscureText: true, icon: Icons.lock_outline),

                  SizedBox(height: 40),

                  // TOMBOL REGISTER
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24, width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text("Register", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  SizedBox(height: 20),

                  // FOOTER LINK KE LOGIN
                  GestureDetector(
                    onTap: () async {
                       FocusManager.instance.primaryFocus?.unfocus();
                       await Future.delayed(Duration(milliseconds: 100));
                       if (context.mounted) {
                         Navigator.pushReplacement(
                           context, 
                           MaterialPageRoute(builder: (context) => LoginScreen())
                         );
                       }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ", style: TextStyle(color: Colors.black54)),
                        Text("Login", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon, 
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          prefixIcon: Icon(icon, color: mainColor.withOpacity(0.7)), 
        ),
      ),
    );
  }
}