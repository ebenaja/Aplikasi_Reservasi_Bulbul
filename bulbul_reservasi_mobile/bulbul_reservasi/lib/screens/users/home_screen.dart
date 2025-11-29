import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/users/tabs/beranda_tab.dart';
import 'package:bulbul_reservasi/screens/users/tabs/profile_tab.dart';
import 'package:bulbul_reservasi/screens/users/tabs/favorite_tab.dart';
import 'package:bulbul_reservasi/screens/users/tabs/pemesanan_tab.dart';

class HomeScreen extends StatefulWidget {
  // Tambahkan parameter ini
  final int initialIndex; 
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color mainColor = Color(0xFF50C2C9);
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Set index awal sesuai parameter (misal: 2 jika dari reservasi sukses)
    _currentIndex = widget.initialIndex; 
  }

  final List<Widget> _pages = [
    BerandaTab(),      
    FavoriteTab(),  
    PemesananTab(),   
    ProfileTab(),   
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
              BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: "Pemesanan"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Akun"),
            ],
          ),
        ),
      ),
    );
  }
}