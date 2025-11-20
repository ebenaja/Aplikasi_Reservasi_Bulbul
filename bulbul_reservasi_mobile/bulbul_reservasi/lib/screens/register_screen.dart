import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/auth_service.dart';
import 'package:bulbul_reservasi/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Tambahan sesuai gambar

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Warna Utama (Tosca/Cyan sesuai gambar)
  final Color mainColor = Color(0xFF50C2C9);

  void _register() async {
    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validasi dasar
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Harap isi semua kolom", Colors.orange);
      setState(() => _isLoading = false);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Password tidak sama", Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    // Panggil API register
    // Note: Sesuaikan parameter authService Anda jika belum mendukung confirmPassword
    final response = await _authService.register(name, email, password);

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      _showSnackBar("Registrasi Berhasil! Silahkan Login", mainColor);
      Navigator.pop(context); // Kembali ke Login
    } else {
      _showSnackBar("Registrasi Gagal. Coba lagi.", Colors.red);
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
      // Background abu-abu muda bersih
      backgroundColor: Color(0xFFF0F4F3),
      body: Stack(
        children: [
          // 1. HIASAN BULAT DI POJOK KIRI ATAS
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mainColor.withOpacity(0.3), // Warna muda transparan
              ),
            ),
          ),
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mainColor.withOpacity(0.3), // Warna muda transparan
              ),
            ),
          ),

          // 2. KONTEN UTAMA
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tombol Back di pojok kiri
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Judul
                  Text(
                    "Welcome Onboard!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Let’s help you meet up your tasks.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  
                  SizedBox(height: 40),

                  // Form Input (Dibuat Custom Widget di bawah agar rapi)
                  _buildCustomTextField(
                    controller: _nameController,
                    hintText: "Enter your full name",
                  ),
                  SizedBox(height: 16),
                  
                  _buildCustomTextField(
                    controller: _emailController,
                    hintText: "Enter your email",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  
                  _buildCustomTextField(
                    controller: _passwordController,
                    hintText: "Create password",
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  
                  _buildCustomTextField(
                    controller: _confirmPasswordController,
                    hintText: "Confirm password",
                    obscureText: true,
                  ),

                  SizedBox(height: 40),

                  // Tombol Register
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor, // Warna Tosca
                        foregroundColor: Colors.white,
                        elevation: 0, // Flat style tapi berwarna
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // Kalau mau kotak total
                          // Atau gunakan ini jika mau agak membulat seperti gambar:
                          // borderRadius: BorderRadius.circular(10), 
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Footer Link
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          "Login",
                          style: TextStyle(
                            color: mainColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  // Widget Helper untuk membuat TextField putih bersih seperti gambar
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // Sudut membulat penuh
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Bayangan tipis
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
          border: InputBorder.none, // Hilangkan garis border default
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
    );
  }
}