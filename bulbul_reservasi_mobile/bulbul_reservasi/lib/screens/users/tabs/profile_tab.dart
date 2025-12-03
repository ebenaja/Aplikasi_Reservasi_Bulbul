import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:bulbul_reservasi/screens/users/login_screen.dart'; 
import 'package:bulbul_reservasi/services/auth_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "Pengunjung";
      userEmail = prefs.getString('user_email') ?? "user@bulbul.com";
    });
  }

  // --- DIALOG UBAH NAMA ---
  void _showEditNameDialog() {
    TextEditingController nameController = TextEditingController(text: userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Ubah Nama"),
        content: TextField(
          controller: nameController, 
          decoration: InputDecoration(
            labelText: "Nama Lengkap",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
          )
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              bool success = await _authService.updateProfileName(nameController.text);
              
              setState(() => _isLoading = false);
              if (success) {
                setState(() => userName = nameController.text);
                _showSnackBar("Nama berhasil diperbarui!", Colors.green);
              } else {
                _showSnackBar("Gagal update. Cek koneksi.", Colors.red);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Ganti Kata Sandi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldPass, obscureText: true, decoration: InputDecoration(labelText: "Sandi Lama", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            SizedBox(height: 15),
            TextField(controller: newPass, obscureText: true, decoration: InputDecoration(labelText: "Sandi Baru", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () async {
              if (oldPass.text.isEmpty || newPass.text.isEmpty) return;
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              var res = await _authService.changePassword(oldPass.text, newPass.text);
              
              setState(() => _isLoading = false);
              _showSnackBar(res['message'], res['success'] ? Colors.green : Colors.red);
            },
            child: Text("Simpan", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- DIALOG LOGOUT ---
  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(child: Text("Keluar Aplikasi?", style: TextStyle(fontWeight: FontWeight.bold))),
        content: Text("Anda harus login kembali untuk mengakses akun ini.", textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isLoading = true);
              
              await _authService.logout();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              
              if (mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
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
    String phoneNumber = "6283492468871"; 
    final Uri url = Uri.parse("https://wa.me/$phoneNumber");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showSnackBar("Gagal membuka WhatsApp", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
                  children: [
                    Container(
                      height: 260,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: mainColor,
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
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person, size: 60, color: Colors.grey[300]),
                                ),
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: GestureDetector(
                                    onTap: _showEditNameDialog,
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: mainColor, width: 2)),
                                      child: Icon(Icons.edit, color: mainColor, size: 18),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 15),
                            Text(userName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(height: 5),
                            Text(userEmail, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
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
                      Text("Akun Saya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      SizedBox(height: 15),
                      
                      _buildMenuCard("Edit Profil", "Ubah nama tampilan Anda", Icons.person_outline, _showEditNameDialog),
                      SizedBox(height: 15),
                      _buildMenuCard("Keamanan", "Ganti kata sandi akun", Icons.lock_outline, _showChangePasswordDialog),
                      
                      SizedBox(height: 25),
                      Text("Lainnya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      SizedBox(height: 15),
                      
                      _buildMenuCard("Pusat Bantuan", "Hubungi Admin via WhatsApp", Icons.headset_mic_outlined, _contactAdmin, isHighlight: true),

                      SizedBox(height: 40),
                      
                      // TOMBOL LOGOUT
                      GestureDetector(
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
                      
                      SizedBox(height: 30),
                      Text("Bulbul Holidays v1.0.0", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      SizedBox(height: 20),
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
            child: Center(child: CircularProgressIndicator(color: mainColor)),
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