import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bulbul_reservasi/screens/login_screen.dart';
import 'package:bulbul_reservasi/screens/admins/manage_facilities_screen.dart'; // FILE BARU DI BAWAH

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final Color mainColor = Color(0xFF50C2C9);

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout Admin"),
        content: Text("Keluar dari panel admin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); 
              Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false
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
        elevation: 0,
        centerTitle: true,
        title: Text("Dashboard Pengelola", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: _logout, icon: Icon(Icons.logout))],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Statistik
            Text("Laporan Singkat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Row(
              children: [
                _buildStatCard("Pendapatan", "Rp 5.2jt", Colors.green),
                SizedBox(width: 15),
                _buildStatCard("Disewa", "8 Unit", Colors.orange),
              ],
            ),
            
            SizedBox(height: 30),
            Text("Manajemen Sistem", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),

            // 2. Menu Grid
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.0,
              children: [
                _buildAdminMenuCard(
                  "Kelola Fasilitas", 
                  Icons.house_siding, 
                  () {
                    // Navigasi ke Halaman CRUD Fasilitas
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ManageFacilitiesScreen()));
                  }
                ),
                _buildAdminMenuCard("Cek Pembayaran", Icons.verified_user, () {}),
                _buildAdminMenuCard("Laporan Keuangan", Icons.bar_chart, () {}),
                _buildAdminMenuCard("Ulasan User", Icons.star_rate, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          border: Border(left: BorderSide(color: color, width: 5)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenuCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(color: mainColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 35, color: mainColor),
            ),
            SizedBox(height: 15),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}