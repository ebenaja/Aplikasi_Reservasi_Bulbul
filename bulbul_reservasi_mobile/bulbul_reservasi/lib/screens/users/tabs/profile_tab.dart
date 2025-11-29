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

  // --- HELPER: STYLE INPUT FIELD BIAR CLEAN ---
  InputDecoration _cleanInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      prefixIcon: Icon(icon, color: mainColor),
      filled: true,
      fillColor: Colors.grey[100], // Background abu muda soft
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.transparent), // Hilangkan garis default
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: mainColor, width: 1.5), // Garis warna tosca saat diklik
      ),
    );
  }

  // --- 1. DIALOG UBAH NAMA (CUSTOM UI) ---
  void _showEditNameDialog() {
    TextEditingController nameController = TextEditingController(text: userName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(child: Text("Ubah Nama", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Masukkan nama lengkap baru Anda.", style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: _cleanInputDecoration("Nama Lengkap", Icons.person_outline),
            ),
          ],
        ),
        actionsPadding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Batal", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- 2. DIALOG GANTI PASSWORD (CUSTOM UI) ---
  void _showChangePasswordDialog() {
    TextEditingController oldPassController = TextEditingController();
    TextEditingController newPassController = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Center(child: Text("Ganti Kata Sandi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Pastikan akun Anda tetap aman.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(height: 20),
                  TextField(
                    controller: oldPassController,
                    obscureText: obscureOld,
                    decoration: _cleanInputDecoration("Sandi Lama", Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setStateDialog(() => obscureOld = !obscureOld),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: newPassController,
                    obscureText: obscureNew,
                    decoration: _cleanInputDecoration("Sandi Baru", Icons.vpn_key_outlined).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setStateDialog(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                ],
              ),
              actionsPadding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                      shadowColor: mainColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (oldPassController.text.isEmpty || newPassController.text.isEmpty) {
                        _showSnackBar("Harap isi semua kolom", Colors.orange);
                        return;
                      }
                      Navigator.pop(context);
                      setState(() => _isLoading = true);

                      var result = await _authService.changePassword(
                        oldPassController.text, 
                        newPassController.text
                      );

                      setState(() => _isLoading = false);
                      if (result['success']) {
                        _showSnackBar("Kata sandi diperbarui!", Colors.green);
                      } else {
                        _showSnackBar(result['message'], Colors.red);
                      }
                    },
                    child: Text("Update Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Batal", style: TextStyle(color: Colors.grey)),
                  ),
                )
              ],
            );
          }
        );
      },
    );
  }

  // --- 3. DIALOG LOGOUT (CUSTOM UI WARNING) ---
  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.all(25),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout_rounded, color: Colors.redAccent, size: 40),
            ),
            SizedBox(height: 20),
            Text("Ingin Keluar?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87)),
            SizedBox(height: 10),
            Text("Anda harus masuk kembali untuk mengakses akun Anda.", 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14)
            ),
            SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Batal", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      setState(() => _isLoading = true);
                      
                      await _authService.logout();
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Ya, Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- PUSAT BANTUAN ---
  Future<void> _contactAdmin() async {
    String phoneNumber = "6283492468871"; 
    String message = "Halo Admin Bulbul Holidays, saya butuh bantuan.";
    final Uri url = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showSnackBar("Gagal membuka WhatsApp", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[50], 
          body: SingleChildScrollView(
            child: Column(
              children: [
                // 1. HEADER 
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 15, offset: Offset(0, 5))],
                  ),
                  padding: EdgeInsets.only(top: 70, bottom: 30, left: 20, right: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey[200], 
                          child: Icon(Icons.person, size: 40, color: Colors.grey[400]),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
                            SizedBox(height: 5),
                            Text(userEmail, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                          child: Icon(Icons.edit, color: Colors.white, size: 20)
                        ),
                        onPressed: _showEditNameDialog,
                        tooltip: "Ubah Nama",
                      )
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // 2. MENU OPTIONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pengaturan Akun", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      SizedBox(height: 10),
                      _buildMenuCard(icon: Icons.person_outline, title: "Ubah Nama Lengkap", subtitle: "Perbarui nama tampilan Anda", onTap: _showEditNameDialog),
                      SizedBox(height: 10),
                      _buildMenuCard(icon: Icons.lock_outline, title: "Ganti Kata Sandi", subtitle: "Amankan akun Anda secara berkala", onTap: _showChangePasswordDialog),
                      
                      SizedBox(height: 25),
                      Text("Lainnya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      SizedBox(height: 10),
                      _buildMenuCard(icon: Icons.headset_mic_outlined, title: "Pusat Bantuan", subtitle: "Hubungi Admin via WhatsApp", onTap: _contactAdmin, isHighlight: true),

                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed: _logout,
                          icon: Icon(Icons.logout, color: Colors.redAccent),
                          label: Text("Keluar Aplikasi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            backgroundColor: Colors.white
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(child: Text("Bulbul Holidays v1.0.0", style: TextStyle(color: Colors.grey[400], fontSize: 12))),
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

  Widget _buildMenuCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, bool isHighlight = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(color: isHighlight ? Colors.green[50] : mainColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: isHighlight ? Colors.green : mainColor, size: 24),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]),
      ),
    );
  }
}