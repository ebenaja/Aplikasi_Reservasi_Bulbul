import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/users/tabs/beranda_tab.dart';
import 'package:bulbul_reservasi/screens/users/tabs/favorite_tab.dart';
import 'package:bulbul_reservasi/screens/users/tabs/pemesanan_tab.dart';
import 'package:bulbul_reservasi/screens/users/tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex; 
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color mainColor = const Color(0xFF50C2C9);
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; 
  }

  final List<Widget> _pages = [
    const BerandaTab(),
    const FavoriteTab(),
    const PemesananTab(),
    const ProfileTab(),
  ];

  // Data untuk Navigasi
  final List<Map<String, dynamic>> _navItems = [
    {"icon": Icons.home_rounded, "label": "Beranda"},
    {"icon": Icons.favorite_rounded, "label": "Favorit"},
    {"icon": Icons.calendar_month_rounded, "label": "Pesanan"},
    {"icon": Icons.person_rounded, "label": "Akun"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
      
      // Body dengan transisi Fade yang halus
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _pages[_currentIndex],
      ),

      // --- CUSTOM ANIMATED BOTTOM BAR ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_navItems.length, (index) {
              return _buildAnimatedNavItem(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedNavItem(int index) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? mainColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            // Ikon dengan animasi rotasi sedikit/warna
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _navItems[index]['icon'],
                color: isSelected ? mainColor : Colors.grey[400],
                size: 26,
              ),
            ),
            
            // Teks Label (Muncul hanya jika dipilih)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: isSelected ? null : 0, // Lebar 0 jika tidak dipilih
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    _navItems[index]['label'],
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}