import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// PERBAIKAN IMPORT DI SINI: Sesuaikan dengan lokasi file login_screen.dart Anda
import 'package:bulbul_reservasi/screens/users/login_screen.dart'; 
// IMPORT FILE-FILE BARU
import 'package:bulbul_reservasi/screens/admins/manage_facilities_screen.dart';
import 'package:bulbul_reservasi/screens/admins/financial_report_screen.dart';
import 'package:bulbul_reservasi/screens/admins/manage_reservasi_screen.dart';
import 'package:bulbul_reservasi/screens/admins/manage_ulasan_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final Color mainColor = Color(0xFF50C2C9);

  void _logout() { // Ubah nama fungsi jadi _logout (pake underscore biar private dan konsisten)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout Admin"),
        content: Text("Keluar dari panel admin?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Batal")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => LoginScreen()), // Pastikan LoginScreen diimport
                  (route) => false
                );
              }
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
        title: Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _logout, icon: Icon(Icons.logout)) // Panggil _logout
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Bagian Header Sambutan sama seperti sebelumnya) ...
            
            SizedBox(height: 30),
            Text("Menu Pengelola", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 15),

            // GRID MENU ADMIN LENGKAP
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.0,
              children: [
                _buildAdminMenuCard("Kelola Fasilitas", Icons.house_siding, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ManageFacilitiesScreen()));
                }),
                _buildAdminMenuCard("Reservasi & Bayar", Icons.book_online, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ManageReservasiScreen()));
                }),
                _buildAdminMenuCard("Laporan Keuangan dan Statistik", Icons.money, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FinancialReportScreen()));
                }),
                _buildAdminMenuCard("Kelola Ulasan", Icons.star_rate, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ManageUlasanScreen()));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenuCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: Offset(0, 2))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: mainColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, size: 30, color: mainColor)),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}