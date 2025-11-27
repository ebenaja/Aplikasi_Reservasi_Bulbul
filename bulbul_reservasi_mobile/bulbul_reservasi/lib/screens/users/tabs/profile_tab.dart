import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bulbul_reservasi/screens/users/login_screen.dart';
import 'package:bulbul_reservasi/services/auth_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final AuthService _authService = AuthService();
  final Color mainColor = Color(0xFF50C2C9);
  
  String userName = "Loading...";
  String userEmail = "user@bulbul.com"; // Dummy email
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load data user dari memori HP
  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "Pengunjung";
      // userEmail = prefs.getString('user_email') ?? "user@bulbul.com"; 
    });
  }

  // Dialog Edit Nama
  void _showEditNameDialog() {
    TextEditingController nameEditController = TextEditingController(text: userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ubah Nama"),
        content: TextField(
          controller: nameEditController,
          decoration: InputDecoration(labelText: "Nama Lengkap"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameEditController.text.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('user_name', nameEditController.text);
                
                setState(() {
                  userName = nameEditController.text;
                });
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Nama berhasil diperbarui!"),
                    backgroundColor: mainColor,
                  )
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            child: Text("Simpan", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // Fungsi Logout
  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin keluar?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext); // Tutup dialog konfirmasi
              
              try {
                // PERBAIKAN DI SINI: onTimeout harus return bool (false) bukan null
                await _authService.logout().timeout(
                  Duration(seconds: 3), 
                  onTimeout: () {
                    print("Logout timeout");
                    return false; // Return false agar tipe datanya sesuai (bool)
                  }
                );
              } catch (e) {
                print("Error logout: $e");
              } finally {
                // Bagian ini tetap jalan walau timeout/error
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_name');
                
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            child: Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // --- HEADER PROFIL ---
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: mainColor.withOpacity(0.4),
                  blurRadius: 10,
                  offset: Offset(0, 5)
                )
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 60, color: Colors.grey[300]),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, color: mainColor, size: 20),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 15),
                Text(
                  userName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 5),
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isVerified ? "Terverifikasi" : "Member Baru",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),

          // --- MENU OPSI ---
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileOption(
                  title: "Ubah Nama Lengkap",
                  icon: Icons.edit_outlined,
                  onTap: _showEditNameDialog,
                ),
                SizedBox(height: 15),
                _buildProfileOption(
                  title: "Konfirmasi Akun / Verifikasi",
                  icon: Icons.verified_user_outlined,
                  trailing: Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Segera Hadir!"), backgroundColor: Colors.orange)
                    );
                  },
                ),
                SizedBox(height: 15),
                _buildProfileOption(
                  title: "Ganti Kata Sandi",
                  icon: Icons.lock_outline,
                  onTap: () {},
                ),
                SizedBox(height: 15),
                _buildProfileOption(
                  title: "Pusat Bantuan",
                  icon: Icons.help_outline,
                  onTap: () {},
                ),
                
                SizedBox(height: 30),
                
                // Tombol Logout
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: Icon(Icons.logout),
                    label: Text("Keluar Aplikasi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.redAccent,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                    ),
                  ),
                ),
                
                SizedBox(height: 20),
                Text("Versi Aplikasi 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Widget Helper Menu
  Widget _buildProfileOption({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2)
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: mainColor, size: 22),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
            trailing ?? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}