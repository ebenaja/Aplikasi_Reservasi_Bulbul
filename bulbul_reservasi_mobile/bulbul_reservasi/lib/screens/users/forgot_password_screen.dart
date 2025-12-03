import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  // Warna Konsisten
  final Color mainColor = const Color(0xFF50C2C9);
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _submitReset() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final email = _emailController.text;
    final newPass = _newPasswordController.text;

    if (email.isEmpty || newPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mohon isi Email dan Password Baru"), backgroundColor: Colors.orange)
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.resetPassword(email, newPass);

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 50),
              SizedBox(height: 10),
              Text("Berhasil", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(result['message'], textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text("Login Sekarang", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3), // Background Abu Muda
      resizeToAvoidBottomInset: false, // Mencegah background bergeser saat keyboard muncul
      body: Stack(
        children: [
          // --- 1. DEKORASI BACKGROUND (KONSISTEN) ---
          Positioned(
            top: -50, left: -50,
            child: Container(
              width: 150, height: 150,
              decoration: BoxDecoration(shape: BoxShape.circle, color: mainColor.withOpacity(0.3))
            )
          ),
          Positioned(
            top: -20, left: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(shape: BoxShape.circle, color: mainColor.withOpacity(0.3))
            )
          ),

          // --- 2. KONTEN UTAMA ---
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                children: [
                  // Tombol Back
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  
                  SizedBox(height: 20),

                  // Ilustrasi Ikon (Agar Menarik)
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))]
                    ),
                    child: Icon(Icons.lock_reset_rounded, size: 60, color: mainColor),
                  ),

                  SizedBox(height: 30),

                  // Judul & Deskripsi
                  Text(
                    "Lupa Kata Sandi?",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Jangan khawatir! Masukkan email Anda dan buat kata sandi baru untuk memulihkan akun.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                  ),

                  SizedBox(height: 40),

                  // Form Input (Konsisten)
                  _buildCustomTextField(
                    controller: _emailController, 
                    hintText: "Email Terdaftar", 
                    icon: Icons.email_outlined
                  ),
                  
                  SizedBox(height: 20),

                  _buildCustomTextField(
                    controller: _newPasswordController, 
                    hintText: "Kata Sandi Baru", 
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    hasSuffix: true,
                    onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword)
                  ),
                  
                  Spacer(),

                  // Tombol Reset
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: mainColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isLoading 
                        ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : Text("Reset Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  // --- WIDGET INPUT (KONSISTEN DENGAN LOGIN/REGISTER) ---
  Widget _buildCustomTextField({
    required TextEditingController controller, 
    required String hintText, 
    required IconData icon, 
    bool obscureText = false, 
    bool hasSuffix = false,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))]
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: Icon(icon, color: mainColor),
          suffixIcon: hasSuffix 
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey), 
                onPressed: onSuffixTap
              ) 
            : null
        ),
      ),
    );
  }
}