import 'dart:async'; // Import untuk Timer (Realtime clock)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
// IMPORTS SERVICES
import 'package:bulbul_reservasi/services/admin_service.dart'; // Import Admin Service
// IMPORTS SCREENS
import 'package:bulbul_reservasi/screens/users/login_screen.dart';
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
  final AdminService _adminService = AdminService();
  
  // Palette Warna
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  final Color bgPage = const Color(0xFFF5F7FA);

  String _adminName = "Administrator";
  
  // Variabel Realtime Clock
  String _timeString = "";
  String _dateString = "";
  Timer? _timer;

  // Variabel Quick Stats (Data Keuangan)
  bool _isLoadingStats = true;
  double _totalPendapatan = 0;
  int _totalTransaksi = 0;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _startRealtimeClock(); // Mulai jam
    _fetchQuickStats();    // Ambil data profit
  }

  @override
  void dispose() {
    _timer?.cancel(); // Matikan jam saat keluar halaman agar tidak memory leak
    super.dispose();
  }

  // 1. LOAD NAMA ADMIN
  void _loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _adminName = prefs.getString('user_name') ?? "Administrator";
    });
  }

  // 2. JAM REALTIME
  void _startRealtimeClock() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (mounted) {
        setState(() {
          final now = DateTime.now();
          _timeString = DateFormat('HH:mm:ss').format(now);
          _dateString = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
        });
      }
    });
  }

  // 3. AMBIL DATA PROFIT DARI API
  void _fetchQuickStats() async {
    try {
      final data = await _adminService.getStatistics();
      if (mounted) {
        setState(() {
          _totalPendapatan = double.tryParse(data['total_pendapatan']?.toString() ?? '0') ?? 0;
          _totalTransaksi = int.tryParse(data['total_transaksi']?.toString() ?? '0') ?? 0;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print("Error dashboard stats: $e");
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  // Helper Rupiah
  String formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  // LOGOUT
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
              decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
              child: Icon(Icons.logout_rounded, color: Colors.redAccent, size: 40),
            ),
            SizedBox(height: 20),
            Text("Keluar Dashboard?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            Text("Sesi Anda akan berakhir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: Text("Batal", style: TextStyle(color: Colors.grey[700])),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: Text("Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. HEADER DASHBOARD ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Gradient
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mainColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.white24,
                                  child: Icon(Icons.admin_panel_settings, color: Colors.white),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Halo, $_adminName", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text("Admin Panel", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: _logout,
                              icon: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                                child: Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 20),
                              ),
                            )
                          ],
                        ),
                        
                        SizedBox(height: 35),
                        
                        // Realtime Clock Display
                        Center(
                          child: Column(
                            children: [
                              Text(_timeString.isEmpty ? "--:--:--" : _timeString, 
                                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)
                              ),
                              SizedBox(height: 5),
                              Text(_dateString.isEmpty ? "Memuat tanggal..." : _dateString, 
                                style: TextStyle(color: Colors.white70, fontSize: 14)
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- FLOATING CARD: LIVE PROFIT & STATS ---
                Positioned(
                  bottom: -40,
                  left: 24,
                  right: 24,
                  child: GestureDetector(
                    onTap: () {
                      // Klik card ini langsung ke Laporan Keuangan
                      Navigator.push(context, MaterialPageRoute(builder: (_) => FinancialReportScreen()));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: Offset(0, 10))],
                      ),
                      child: Row(
                        children: [
                          // Kolom Profit
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.trending_up_rounded, color: Colors.green, size: 20),
                                    SizedBox(width: 5),
                                    Text("Total Pendapatan", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                                SizedBox(height: 8),
                                _isLoadingStats 
                                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text(
                                      formatRupiah(_totalPendapatan), 
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)
                                    ),
                              ],
                            ),
                          ),
                          
                          Container(width: 1, height: 40, color: Colors.grey[200]), // Divider Vertical
                          
                          // Kolom Transaksi
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text("Transaksi Sukses", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    SizedBox(width: 5),
                                    Icon(Icons.shopping_bag_outlined, color: Colors.orange, size: 18),
                                  ],
                                ),
                                SizedBox(height: 8),
                                _isLoadingStats 
                                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text(
                                      "$_totalTransaksi Order", 
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)
                                    ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),

            SizedBox(height: 70), // Spasi kompensasi floating card

            // --- 2. GRID MENU UTAMA ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Akses Cepat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 15),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      _buildMenuCard(
                        "Kelola Fasilitas", 
                        "Tambah & Edit Promo", 
                        Icons.holiday_village_rounded, 
                        Colors.orange, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageFacilitiesScreen()))
                      ),
                      _buildMenuCard(
                        "Cek Reservasi", 
                        "Verifikasi Bayar", 
                        Icons.receipt_long_rounded, 
                        Colors.blueAccent, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageReservasiScreen()))
                      ),
                      _buildMenuCard(
                        "Laporan Keuangan", 
                        "Analitik Detail", 
                        Icons.pie_chart_rounded, 
                        Colors.green, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => FinancialReportScreen()))
                      ),
                      _buildMenuCard(
                        "Ulasan User", 
                        "Rating & Komentar", 
                        Icons.star_rounded, 
                        Colors.purpleAccent, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageUlasanScreen()))
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
            Text("Bulbul Admin Panel v1.0", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // WIDGET MENU CARD
  Widget _buildMenuCard(String title, String subtitle, IconData icon, Color themeColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: themeColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: themeColor, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                  SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}