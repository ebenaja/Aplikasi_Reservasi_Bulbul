import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  
  // WARNA UTAMA (TOSCA)
  final Color mainColor = Color(0xFF50C2C9);

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
  }

  void _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  void _saveUserCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('email', email);
      await prefs.setString('password', password);
    } else {
      await prefs.remove('remember_me');
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  void _showForgotPasswordBottomSheet() {
    // Kode bottom sheet
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Silakan isi email dan password"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 1)); // Simulasi loading

    String displayName = email.split('@')[0];
    displayName = displayName[0].toUpperCase() + displayName.substring(1);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', displayName);

    _saveUserCredentials(email, password);

    setState(() => _isLoading = false);
    
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah bisa back (Datang dari Landing Screen)
    bool canGoBack = Navigator.canPop(context); 

    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      resizeToAvoidBottomInset: false, // Cegah crash keyboard
      body: Stack(
        children: [
          // Dekorasi Background
          Positioned(top: -50, left: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: mainColor.withOpacity(0.3)))),
          Positioned(top: -20, left: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: mainColor.withOpacity(0.3)))),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24, 
                  right: 24, 
                  top: 10, 
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20
                ),
                child: Column(
                  children: [
                    // TOMBOL BACK (Kiri Atas)
                    if (canGoBack)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.black87),
                          onPressed: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            await Future.delayed(Duration(milliseconds: 300));
                            if (context.mounted) Navigator.pop(context);
                          },
                        ),
                      )
                    else
                      SizedBox(height: 48), 
                    
                    SizedBox(height: 10),
                    
                    Text("Welcome Back!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                    SizedBox(height: 10),
                    Text("Let’s help you meet up your tasks.", style: TextStyle(fontSize: 14, color: Colors.black54)),
                    SizedBox(height: 40),
                    
                    _buildCustomTextField(controller: _emailController, hintText: "Enter your email / username", icon: Icons.person_outline),
                    SizedBox(height: 20),
                    _buildCustomTextField(controller: _passwordController, hintText: "Enter your password", icon: Icons.lock_outline, obscureText: _obscurePassword, hasSuffix: true),
                    
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Transform.scale(scale: 0.9, child: Checkbox(value: _rememberMe, activeColor: mainColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), onChanged: (val) { setState(() { _rememberMe = val ?? false; }); })),
                          Text("Remember me", style: TextStyle(color: Colors.black54, fontSize: 13)),
                        ]),
                        TextButton(onPressed: _showForgotPasswordBottomSheet, child: Text("Forgot Password?", style: TextStyle(color: mainColor, fontSize: 13, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    SizedBox(height: 30),

                    // TOMBOL LOGIN (Rounded 30)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading 
                          ? CircularProgressIndicator(color: Colors.white) 
                          : Text("Log In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    SizedBox(height: 20),

                    // --- NAVIGASI FOOTER (KE REGISTER) ---
                    GestureDetector(
                      onTap: () async {
                         // 1. Tutup Keyboard
                         FocusManager.instance.primaryFocus?.unfocus();
                         // 2. Tunggu animasi keyboard
                         await Future.delayed(Duration(milliseconds: 100));
                         
                         // 3. Pindah Halaman (Gunakan PushReplacement agar tidak menumpuk)
                         if (context.mounted) {
                           Navigator.pushReplacement(
                             context, 
                             MaterialPageRoute(builder: (_) => RegisterScreen())
                           );
                         }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, 
                        children: [
                          Text("Don’t have an account? ", style: TextStyle(color: Colors.black54)), 
                          Text("Register", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold))
                        ]
                      )
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Custom Text Field
  Widget _buildCustomTextField({required TextEditingController controller, required String hintText, required IconData icon, bool obscureText = false, bool hasSuffix = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // BULAT 30
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: Icon(icon, color: mainColor.withOpacity(0.7)),
          suffixIcon: hasSuffix ? IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: _togglePasswordVisibility) : null,
        ),
      ),
    );
  }
}