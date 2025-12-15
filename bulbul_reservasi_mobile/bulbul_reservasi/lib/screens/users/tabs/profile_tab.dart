import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bulbul_reservasi/utils/whatsapp_helper.dart';
import 'package:animate_do/animate_do.dart'; 
// --- IMPORT HARUS ADA ---
import 'package:bulbul_reservasi/screens/users/login_screen.dart'; 
import 'package:bulbul_reservasi/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final AuthService _authService = AuthService();
  final Color mainColor = const Color(0xFF50C2C9);
  
  String userName = "Loading...";
  String userEmail = "";
  bool _isLoading = false;
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker(); 

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfileImage();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "Pengunjung";
      userEmail = prefs.getString('user_email') ?? "user@bulbul.com";
    });
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
      );
      
      if (pickedFile != null) {
        setState(() => _profileImage = File(pickedFile.path));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', pickedFile.path);
        _showSnackBar('Foto profil berhasil disimpan', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Gagal memilih foto: $e', Colors.red);
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() => _profileImage = File(imagePath));
    }
  }

  // --- DIALOG UBAH NAMA ---
  void _showEditNameDialog() {
    TextEditingController nameController = TextEditingController(text: userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Ubah Nama", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController, 
          decoration: InputDecoration(
            labelText: "Nama Lengkap",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            filled: true,
            fillColor: Colors.grey[100]
          )
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              // Simulasi update
              await Future.delayed(Duration(seconds: 1)); 

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_name', nameController.text);
              
              if (mounted) {
                setState(() {
                   userName = nameController.text;
                   _isLoading = false;
                });
                _showSnackBar("Nama berhasil diperbarui!", Colors.green);
              }
            },
            child: Text("Simpan", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- DIALOG GANTI PASSWORD ---
  void _showChangePasswordDialog() {
    TextEditingController oldPass = TextEditingController();
    TextEditingController newPass = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Ganti Kata Sandi", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPasswordField(oldPass, "Sandi Lama"),
            SizedBox(height: 15),
            _buildPasswordField(newPass, "Sandi Baru"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) ),
            onPressed: () async {
              Navigator.pop(context);
              if (oldPass.text.isEmpty || newPass.text.length < 8) {
                _showSnackBar('Masukkan sandi lama dan minimal 8 karakter untuk sandi baru.', Colors.orange);
                return;
              }
              setState(() => _isLoading = true);
              final result = await _authService.changePassword(oldPass.text, newPass.text);
              setState(() => _isLoading = false);
              if (result['success'] == true) {
                _showSnackBar(result['message'] ?? 'Kata sandi berhasil diubah', Colors.green);
              } else {
                _showSnackBar(result['message'] ?? 'Gagal mengubah kata sandi', Colors.red);
              }
            },
            child: Text("Simpan", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[100]
      )
    );
  }

  // --- DIALOG LOGOUT ---
  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.logout, size: 50, color: Colors.redAccent),
            SizedBox(height: 10),
            Text("Keluar Aplikasi?", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text("Anda harus login kembali untuk mengakses akun ini.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.pop(dialogContext); // Tutup Dialog
              setState(() => _isLoading = true);
              
              // Logout dengan Timeout agar tidak macet
              try {
                await _authService.logout().timeout(
                  Duration(seconds: 3),
                  onTimeout: () => false, // Return false jika timeout (Fix Error Null)
                );
              } catch (e) {
                print("Logout error: $e");
              }

              // Hapus data lokal
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              
              if (mounted) {
                // Navigasi ke Login Screen
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => const LoginScreen()), // PASTIKAN LoginScreen ADA DI IMPORT
                  (route) => false
                );
              }
            },
            child: Text("Ya, Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- PUSAT BANTUAN ---
  Future<void> _contactAdmin() async {
    const String phoneNumber = '6282286250726'; // Ganti dengan nomor admin (format internasional tanpa +)
    await WhatsAppHelper.openWhatsApp(context: context, phone: phoneNumber, message: 'Halo Admin, saya butuh bantuan terkait reservasi.');
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: color, 
        behavior: SnackBarBehavior.floating, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Color(0xFFF5F7FA), 
          body: SingleChildScrollView(
            child: Column(
              children: [
                // 1. HEADER PROFILE
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [mainColor, Color(0xFF2E8B91)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                        boxShadow: [BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 15, offset: Offset(0, 5))],
                      ),
                    ),
                    Positioned(top: -50, left: -50, child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.1))),
                    Positioned(top: 40, right: -30, child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1))),
                    
                    Positioned.fill(
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeInDown(
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: _pickProfileImage,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                      ),
                                      child: CircleAvatar(
                                        radius: 55,
                                        backgroundColor: Colors.white,
                                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                                        child: _profileImage == null
                                          ? Icon(Icons.person, size: 65, color: Colors.grey[300])
                                          : null,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0, right: 0,
                                    child: GestureDetector(
                                      onTap: _pickProfileImage,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
                                        ),
                                        child: Icon(Icons.camera_alt, color: mainColor, size: 20),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 15),
                            FadeInUp(delay: Duration(milliseconds: 200), child: Text(userName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
                            FadeInUp(delay: Duration(milliseconds: 300), child: Text(userEmail, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 25),

                // 2. MENU LIST
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInLeft(child: Text("Akun Saya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]))),
                      SizedBox(height: 15),
                      
                      FadeInUp(delay: Duration(milliseconds: 100), child: _buildMenuCard("Edit Profil", "Ubah nama tampilan Anda", Icons.person_outline, _showEditNameDialog)),
                      SizedBox(height: 15),
                      FadeInUp(delay: Duration(milliseconds: 200), child: _buildMenuCard("Keamanan", "Ganti kata sandi akun", Icons.lock_outline, _showChangePasswordDialog)),
                      
                      SizedBox(height: 30),
                      FadeInLeft(delay: Duration(milliseconds: 300), child: Text("Lainnya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]))),
                      SizedBox(height: 15),
                      
                      FadeInUp(delay: Duration(milliseconds: 400), child: _buildMenuCard("Pusat Bantuan", "Hubungi Admin via WhatsApp", Icons.headset_mic_outlined, _contactAdmin, isHighlight: true)),

                      SizedBox(height: 40),
                      
                      // TOMBOL LOGOUT
                      FadeInUp(
                        delay: Duration(milliseconds: 500),
                        child: GestureDetector(
                          onTap: _logout,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                              boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4))]
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, color: Colors.redAccent),
                                SizedBox(width: 10),
                                Text("Keluar Aplikasi", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // LOADING OVERLAY
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: mainColor),
                    SizedBox(height: 15),
                    Text("Memproses...", style: TextStyle(fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMenuCard(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isHighlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHighlight ? Colors.green[50] : mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isHighlight ? Colors.green : mainColor, size: 24),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}