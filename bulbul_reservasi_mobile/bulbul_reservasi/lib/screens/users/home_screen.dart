import 'package:flutter/material.dart';
// Import file-file tab
import 'package:bulbul_reservasi/screens/users/tabs/beranda_tab.dart';
import 'package:bulbul_reservasi/screens/users/tabs/profile_tab.dart';
import 'package:bulbul_reservasi/screens/users/tabs/favorite_tab.dart';
import 'package:bulbul_reservasi/screens/users/tabs/pemesanan_tab.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color mainColor = Color(0xFF50C2C9);
  int _currentIndex = 0;

  // Daftar Halaman
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BerandaTab(),      // Index 0
      FavoriteTab(),     // Index 1
      PemesananTab(),    // Index 2
      ProfileTab(),      // Index 3
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      
      // --- BODY DENGAN ANIMASI TRANSISI (SMOOTH FADE) ---
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 400), // Durasi animasi
        switchInCurve: Curves.easeOut,         // Gerakan masuk halus
        switchOutCurve: Curves.easeIn,         // Gerakan keluar halus
        
        // Jenis Transisi: Fade (Memudar)
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        
        // Child yang berubah-ubah sesuai index
        // KeyedSubtree PENTING agar Flutter tahu kalau halamannya beda
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: mainColor,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Beranda"),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: "Favorit"),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: "Pemesanan"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Akun"),
            ],
          ),
        ),
      ),
    );
  }
}