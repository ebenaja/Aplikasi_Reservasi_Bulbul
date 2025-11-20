import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bulbul_reservasi/screens/login_screen.dart';
import 'package:bulbul_reservasi/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final Color mainColor = Color(0xFF50C2C9);
  
  String userName = "Loading..."; 
  
  // Index untuk Bottom Navigation Bar (0 = Beranda)
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName(); 
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "Pengunjung";
    });
  }

  // --- FUNGSI LOGOUT ANTI-MACET ---
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
              Navigator.pop(dialogContext);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(color: mainColor),
                ),
              );

              try {
                await _authService.logout().timeout(
                  Duration(seconds: 3), 
                  onTimeout: () {
                    debugPrint("Logout kelamaan, paksa keluar.");
                    return; 
                  }
                );
              } catch (e) {
                debugPrint("Error logout: $e");
              } finally {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_name');

                if (mounted) {
                  Navigator.of(context).pop(); 
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
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      
      // --- BODY (Berganti sesuai menu yang dipilih) ---
      body: _currentIndex == 0
          ? _buildHomeContent() // Tampilkan Dashboard jika index 0
          : _buildPlaceholderPage(), // Tampilkan halaman lain jika index 1,2,3
      
      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), // Melengkung atas kiri
            topRight: Radius.circular(30), // Melengkung atas kanan
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12, // Bayangan halus
              blurRadius: 10, 
              spreadRadius: 2
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed, // Fixed karena ada 4 item
            selectedItemColor: mainColor, // Warna Tosca saat aktif
            unselectedItemColor: Colors.grey, // Warna Abu saat tidak aktif
            showUnselectedLabels: true,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: TextStyle(fontSize: 12),
            items: [
              // 1. Beranda
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home), // Icon terisi saat aktif
                label: "Beranda",
              ),
              // 2. Favorit
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: "Favorit",
              ),
              // 3. Pemesanan
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: "Pemesanan",
              ),
              // 4. Akun Saya
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: "Akun Saya",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HALAMAN DASHBOARD UTAMA (Dipisah agar rapi) ---
  Widget _buildHomeContent() {
    return Stack(
      children: [
        // 1. HEADER BACKGROUND
        Container(
          height: 220,
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
                  offset: Offset(0, 5))
            ],
          ),
        ),
        Positioned(
          top: -50, left: -50,
          child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.1)),
        ),
        Positioned(
          top: 20, right: -20,
          child: CircleAvatar(radius: 50, backgroundColor: Colors.white.withOpacity(0.1)),
        ),

        // 2. MAIN CONTENT GRID
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP BAR
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selamat Datang,",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontFamily: "Serif"),
                        ),
                        Text(
                          userName,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    // Tombol Logout di Header
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.logout, color: Colors.white),
                        onPressed: _logout,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Layanan Utama",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 30),

              // GRID MENU
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _buildMenuCard(
                          title: "Reservasi",
                          subtitle: "Sewa Pondok, dll",
                          icon: Icons.beach_access,
                          color: Colors.orangeAccent,
                          onTap: () => _showSnackBar("Masuk ke Reservasi")),
                      _buildMenuCard(
                          title: "Pembayaran",
                          subtitle: "Upload bukti",
                          icon: Icons.payment,
                          color: Colors.blueAccent,
                          onTap: () => _showSnackBar("Masuk ke Pembayaran")),
                      _buildMenuCard(
                          title: "Ulasan",
                          subtitle: "Beri rating",
                          icon: Icons.star_rate_rounded,
                          color: Colors.amber,
                          onTap: () => _showSnackBar("Masuk ke Ulasan")),
                      _buildMenuCard(
                          title: "Kelola Fasilitas",
                          subtitle: "Admin Only",
                          icon: Icons.edit_note,
                          color: Colors.purpleAccent,
                          onTap: () => _showSnackBar("Menu Admin")),
                      _buildMenuCard(
                          title: "Laporan",
                          subtitle: "Statistik Keuangan",
                          icon: Icons.bar_chart,
                          color: Colors.green,
                          onTap: () => _showSnackBar("Menu Admin")),
                      _buildMenuCard(
                          title: "Profil Saya",
                          subtitle: "Data Diri",
                          icon: Icons.person,
                          color: Colors.grey,
                          onTap: () => _showSnackBar("Masuk ke Profil")),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget Placeholder untuk halaman Favorit, Pemesanan, Akun
  Widget _buildPlaceholderPage() {
    List<String> titles = ["Beranda", "Favorit Saya", "Riwayat Pemesanan", "Akun Saya"];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 80, color: Colors.grey[300]),
          SizedBox(height: 20),
          Text(
            "${titles[_currentIndex]}",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: mainColor),
          ),
          Text("Halaman ini sedang dikembangkan", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5))
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              Spacer(),
              Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              SizedBox(height: 4),
              Text(subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[600], height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: mainColor,
        duration: Duration(seconds: 1),
      ),
    );
  }
}