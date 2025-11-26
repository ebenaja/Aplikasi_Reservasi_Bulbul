import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bulbul_reservasi/screens/login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final Color mainColor = Color(0xFF50C2C9);

  // Fungsi Logout Admin
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout Admin"),
        content: Text("Keluar dari panel admin?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Hapus sesi
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => LoginScreen()), 
                (route) => false
              );
            },
            child: Text("Logout", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [IconButton(onPressed: _logout, icon: Icon(Icons.logout))],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 100, color: mainColor),
            SizedBox(height: 20),
            Text("Selamat Datang, Admin!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Menu pengelolaan akan tampil disini.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}