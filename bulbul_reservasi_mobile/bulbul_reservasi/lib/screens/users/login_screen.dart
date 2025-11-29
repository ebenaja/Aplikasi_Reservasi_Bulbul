import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// PASTIKAN IMPORT INI SESUAI STRUKTUR FOLDER ANDA
import 'package:bulbul_reservasi/screens/users/register_screen.dart';
import 'package:bulbul_reservasi/screens/users/home_screen.dart';
import 'package:bulbul_reservasi/screens/admins/admin_home_screen.dart'; 
import 'package:bulbul_reservasi/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller & State
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  
  final AuthService _authService = AuthService();
  final Color mainColor = const Color(0xFF50C2C9);

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
  }

  // --- LOGIKA REMEMBER ME ---
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

  // --- LOGIKA LOGIN UTAMA ---
  void _login() async {
    // 1. Hilangkan fokus keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 2. Validasi Input
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Silakan isi email dan password"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Panggil Service Login
      final response = await _authService.login(email, password);

      if (mounted) setState(() => _isLoading = false);

      if (response['status'] == 200) {
        // --- LOGIN SUKSES ---
        String role = response['role']; // "admin" atau "user"
        String name = response['name'];
        String token = response['token'];

        // Simpan Data Sesi
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', name);
        await prefs.setString('user_role', role);
        await prefs.setString('user_token', token);

        // Simpan Remember Me jika dicentang
        _saveUserCredentials(email, password);

        // Navigasi Sesuai Role
        if (mounted) {
          if (role == 'admin') {
            Navigator.pushReplacement(context, _createSmoothRoute(AdminHomeScreen()));
          } else {
            Navigator.pushReplacement(context, _createSmoothRoute(HomeScreen()));
          }
        }
      } else {
        // --- LOGIN GAGAL ---
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Email atau password salah"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan koneksi"), backgroundColor: Colors.red),
      );
    }
  }

  // --- HELPER NAVIGASI HALUS ---
  Route _createSmoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.05); 
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart; 
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: Duration(milliseconds: 600),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canGoBack = Navigator.canPop(context); 

    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      resizeToAvoidBottomInset: false, // Agar background tidak terdorong keyboard
      body: Stack(
        children: [
          // Background Bubbles
          Positioned(top: -50, left: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: mainColor.withOpacity(0.3)))),
          Positioned(top: -20, left: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: mainColor.withOpacity(0.3)))),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 24, right: 24, top: 10, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
                child: Column(
                  children: [
                    // Header Navigasi
                    if (canGoBack)
                      Align(
                        alignment: Alignment.centerLeft, 
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.black87), 
                          onPressed: () => Navigator.pop(context)
                        )
                      )
                    else
                      SizedBox(height: 40), 
                    
                    // Judul
                    SizedBox(height: 10),
                    Text("Welcome Back!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                    SizedBox(height: 10),
                    Text("Silakan masuk untuk melanjutkan.", style: TextStyle(fontSize: 14, color: Colors.black54)),
                    SizedBox(height: 40),
                    
                    // Input Email
                    _buildCustomTextField(
                      controller: _emailController, 
                      hintText: "Masukkan Email", 
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress
                    ),
                    SizedBox(height: 20),
                    
                    // Input Password (Dengan Toggle Mata)
                    _buildCustomTextField(
                      controller: _passwordController, 
                      hintText: "Masukkan Password", 
                      icon: Icons.lock_outline, 
                      obscureText: _obscurePassword, 
                      hasSuffix: true,
                      onSuffixTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      }
                    ),
                    
                    SizedBox(height: 10),
                    
                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.9, 
                              child: Checkbox(
                                value: _rememberMe, 
                                activeColor: mainColor, 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
                                onChanged: (val) { setState(() { _rememberMe = val ?? false; }); }
                              )
                            ), 
                            Text("Ingat Saya", style: TextStyle(color: Colors.black54, fontSize: 13))
                          ]
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hubungi Admin untuk reset password.")));
                          }, 
                          child: Text("Lupa Password?", style: TextStyle(color: mainColor, fontSize: 13, fontWeight: FontWeight.bold))
                        ),
                      ]
                    ),
                    SizedBox(height: 30),

                    // TOMBOL LOGIN
                    SizedBox(
                      width: double.infinity, 
                      height: 55, 
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor, 
                          foregroundColor: Colors.white, 
                          elevation: 5, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                        ), 
                        child: _isLoading 
                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : Text("Masuk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                      )
                    ),

                    SizedBox(height: 20),
                    
                    // LINK KE REGISTER
                    GestureDetector(
                      onTap: () async { 
                        FocusManager.instance.primaryFocus?.unfocus(); 
                        await Future.delayed(Duration(milliseconds: 100)); 
                        if (context.mounted) Navigator.pushReplacement(context, _createSmoothRoute(RegisterScreen())); 
                      }, 
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, 
                        children: [
                          Text("Belum punya akun? ", style: TextStyle(color: Colors.black54)), 
                          Text("Daftar", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold))
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

  // --- WIDGET INPUT FIELD MODERN ---
  Widget _buildCustomTextField({
    required TextEditingController controller, 
    required String hintText, 
    required IconData icon, 
    bool obscureText = false, 
    bool hasSuffix = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 5))]
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), // Borderless look
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: Icon(icon, color: Color(0xFF50C2C9)), 
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