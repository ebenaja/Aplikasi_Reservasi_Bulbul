// lib/screens/admins/admin_home_screen.dart
import 'dart:async'; // Timer untuk realtime clock
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// Services
import 'package:bulbul_reservasi/services/admin_service.dart';

// Screens (sesuaikan path jika beda di projectmu)
import 'package:bulbul_reservasi/screens/users/login_screen.dart';
import 'package:bulbul_reservasi/screens/admins/manage_facilities_screen.dart';
import 'package:bulbul_reservasi/screens/admins/manage_reservasi_screen.dart';
import 'package:bulbul_reservasi/screens/admins/manage_ulasan_screen.dart';
import 'package:bulbul_reservasi/screens/admins/financial_report_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AdminService _adminService = AdminService();

  // Palette warna
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  final Color bgPage = const Color(0xFFF5F7FA);

  // Admin / Dashboard data
  String _adminName = "Administrator";
  bool _isLoadingStats = true;
  double _totalPendapatan = 0;
  int _totalTransaksi = 0;

  // Realtime clock
  String _timeString = "";
  String _dateString = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _startRealtimeClock();
    _fetchQuickStats();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Ambil nama admin dari SharedPreferences
  Future<void> _loadAdminData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _adminName = prefs.getString('user_name') ?? "Administrator";
        });
      }
    } catch (e) {
      // ignore errors silently
      debugPrint("Load admin data error: $e");
    }
  }

  // Realtime clock
  void _startRealtimeClock() {
    // set initial
    final now = DateTime.now();
    _timeString = DateFormat('HH:mm:ss').format(now);
    _dateString = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      final now = DateTime.now();
      setState(() {
        _timeString = DateFormat('HH:mm:ss').format(now);
        _dateString = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
      });
    });
  }

  // Ambil statistik dari API
  Future<void> _fetchQuickStats() async {
    if (mounted) setState(() => _isLoadingStats = true);
    try {
      final data = await _adminService.getStatistics();
      if (!mounted) return;
      setState(() {
        _totalPendapatan = double.tryParse(data['total_pendapatan']?.toString() ?? '0') ?? 0;
        _totalTransaksi = int.tryParse(data['total_transaksi']?.toString() ?? '0') ?? 0;
        _isLoadingStats = false;
      });
    } catch (e) {
      debugPrint("Error dashboard stats: $e");
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  // Format ke Rupiah
  String formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  // Logout
  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(25),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
              child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 40),
            ),
            const SizedBox(height: 20),
            const Text("Keluar Dashboard?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            const Text("Sesi Anda akan berakhir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: Text("Batal", style: TextStyle(color: Colors.grey[700])),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Navigasi dengan refresh otomatis saat kembali
  Future<void> _navigateTo(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (c) => page));
    // refresh setelah kembali
    await _fetchQuickStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      // Pull-to-refresh (RefreshIndicator) membungkus SingleChildScrollView
      body: RefreshIndicator(
        onRefresh: _fetchQuickStats,
        color: mainColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // HEADER (gradient + clock)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [mainColor, secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.white24,
                                    child: Icon(Icons.admin_panel_settings, color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Halo, $_adminName", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      const Text("Admin Panel", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: _logout,
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                                  child: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 35),

                          // Clock
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  _timeString.isEmpty ? "--:--:--" : _timeString,
                                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _dateString.isEmpty ? "Memuat tanggal..." : _dateString,
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating card (stats)
                  Positioned(
                    bottom: -40,
                    left: 24,
                    right: 24,
                    child: RepaintBoundary( // membantu performance saat bagian lain rebuild
                      child: GestureDetector(
                        onTap: () => _navigateTo(const FinancialReportScreen()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Row(
                            children: [
                              // Profit
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.trending_up_rounded, color: Colors.green, size: 20),
                                        SizedBox(width: 5),
                                        Text("Total Pendapatan", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _isLoadingStats
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                        : Text(
                                            formatRupiah(_totalPendapatan),
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87),
                                          ),
                                  ],
                                ),
                              ),

                              Container(width: 1, height: 40, color: Colors.grey[200]),

                              // Transaksi
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: const [
                                        Text("Transaksi Sukses", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                        SizedBox(width: 5),
                                        Icon(Icons.shopping_bag_outlined, color: Colors.orange, size: 18),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _isLoadingStats
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                        : Text(
                                            "$_totalTransaksi Order",
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 70), // kompensasi space untuk floating card

              // GRID MENU UTAMA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Akses Cepat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 15),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                          () => _navigateTo(const ManageFacilitiesScreen()),
                        ),
                        _buildMenuCard(
                          "Cek Reservasi",
                          "Verifikasi Bayar",
                          Icons.receipt_long_rounded,
                          Colors.blueAccent,
                          () => _navigateTo(const ManageReservasiScreen()),
                        ),
                        _buildMenuCard(
                          "Laporan Keuangan",
                          "Analitik Detail",
                          Icons.pie_chart_rounded,
                          Colors.green,
                          () => _navigateTo(const FinancialReportScreen()),
                        ),
                        _buildMenuCard(
                          "Ulasan User",
                          "Rating & Komentar",
                          Icons.star_rounded,
                          Colors.purpleAccent,
                          () => _navigateTo(const ManageUlasanScreen()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Text("Bulbul Admin Panel v1.0", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET MENU CARD (reuse)
  Widget _buildMenuCard(String title, String subtitle, IconData icon, Color themeColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: themeColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: themeColor, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                  const SizedBox(height: 4),
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
