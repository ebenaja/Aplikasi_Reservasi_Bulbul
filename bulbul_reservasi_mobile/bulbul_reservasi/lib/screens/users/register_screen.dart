import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/auth_service.dart';
import 'package:bulbul_reservasi/screens/users/login_screen.dart';
import 'package:bulbul_reservasi/screens/users/landing_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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
  final Color mainColor = const Color(0xFF50C2C9);

  // Toggle Password Visibility
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  void _register() async {
    FocusManager.instance.primaryFocus?.unfocus(); 

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
      final response = await _authService.register(name, email, password);

      if (mounted) setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar("Registrasi Berhasil! Silahkan Login", mainColor);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      } else {
        String errorMsg = "Registrasi Gagal.";
        try {
          final body = jsonDecode(response.body);
          if (body['message'] != null) errorMsg = body['message'];
          if (body['errors'] != null && body['errors'].isNotEmpty) {
            errorMsg = body['errors'].values.first[0]; 
          }
        } catch (e) {
          print("Error parsing error: $e");
        }
        _showSnackBar(errorMsg, Colors.red);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showSnackBar("Gagal terhubung ke server.", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // Background Bubbles
          Positioned(top: -50, left: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: mainColor.withOpacity(0.3)))),
          Positioned(top: -20, left: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: mainColor.withOpacity(0.3)))),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 10, 24, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LandingScreen()), (route) => false),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  // Shared hero header
                  Row(
                    children: [
                      Hero(
                        tag: 'app-logo',
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Icon(Icons.beach_access_rounded, color: Color(0xFF50C2C9), size: 24),
                        ),
                      ),
                      SizedBox(width: 12),
                      Hero(
                        tag: 'app-name',
                        child: Material(type: MaterialType.transparency, child: Text('BulbulHolidays', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  Text("Welcome Onboard!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 8),
                  Text("Let’s help you meet up your tasks.", style: TextStyle(fontSize: 14, color: Colors.black54)),
                  SizedBox(height: 30),

                  // Input Fields Modern
                  _buildCustomTextField(
                    controller: _nameController, 
                    hintText: "Full Name", 
                    icon: Icons.person_outline
                  ),
                  SizedBox(height: 16),
                  _buildCustomTextField(
                    controller: _emailController, 
                    hintText: "Email address", 
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress 
                  ),
                  SizedBox(height: 16),
                  _buildCustomTextField(
                    controller: _passwordController, 
                    hintText: "Password", 
                    icon: Icons.lock_outline, 
                    obscureText: _obscurePassword,
                    hasSuffix: true,
                    onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword)
                  ),
                  SizedBox(height: 16),
                  _buildCustomTextField(
                    controller: _confirmPasswordController, 
                    hintText: "Confirm Password", 
                    icon: Icons.lock_outline, 
                    obscureText: _obscureConfirm,
                    hasSuffix: true,
                    onSuffixTap: () => setState(() => _obscureConfirm = !_obscureConfirm)
                  ),

                  SizedBox(height: 30),

                  // Tombol Register
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(backgroundColor: mainColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Register", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),

                  SizedBox(height: 20),
                  
                  // Link ke Login
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen())),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ", style: TextStyle(color: Colors.black54)),
                        Text("Login", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                      ],
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

  // --- WIDGET HELPER INPUT FIELD (Lengkap dengan Toggle Password) ---
  Widget _buildCustomTextField({
    required TextEditingController controller, 
    required String hintText, 
    required IconData icon, 
    bool obscureText = false, 
    TextInputType keyboardType = TextInputType.text,
    bool hasSuffix = false,
    VoidCallback? onSuffixTap
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))]
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
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: Icon(icon, color: Color(0xFF50C2C9).withOpacity(0.7)),
          suffixIcon: hasSuffix 
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: onSuffixTap,
              )
            : null
        ),
      ),
    );
  }
}