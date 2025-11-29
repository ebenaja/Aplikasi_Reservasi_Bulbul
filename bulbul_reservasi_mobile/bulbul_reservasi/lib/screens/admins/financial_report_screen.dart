import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bulbul_reservasi/services/admin_service.dart';

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  _FinancialReportScreenState createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  final AdminService _service = AdminService();
  
  // Palette Warna Profesional
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;

  bool _isLoading = true;
  
  // Variabel Data
  double totalPendapatan = 0;
  int totalTransaksi = 0;
  double rataRataTransaksi = 0; // Metric tambahan
  List<dynamic> fasilitasPopuler = [];
  List<dynamic> transaksiTerbaru = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    try {
      final data = await _service.getStatistics();
      if (mounted) {
        setState(() {
          totalPendapatan = double.tryParse(data['total_pendapatan']?.toString() ?? '0') ?? 0;
          totalTransaksi = int.tryParse(data['total_transaksi']?.toString() ?? '0') ?? 0;
          
          // Hitung Rata-rata per transaksi (Kompleksitas Data)
          if (totalTransaksi > 0) {
            rataRataTransaksi = totalPendapatan / totalTransaksi;
          }

          fasilitasPopuler = data['fasilitas_populer'] ?? [];
          transaksiTerbaru = data['transaksi_terbaru'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error Fetch Stats: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HELPER FORMATTING ---
  String formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      
      // APP BAR GRADIENT
      appBar: AppBar(
        title: Text("Analitik Keuangan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.print_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fitur Cetak Laporan (Segera Hadir)")));
            },
            tooltip: "Cetak Laporan",
          )
        ],
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. FILTER TANGGAL (Visual UI) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Text("Update terakhir: ${DateFormat('HH:mm').format(DateTime.now())}", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!)
                        ),
                        child: Row(
                          children: [
                            Text("Bulan Ini", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                            SizedBox(width: 5),
                            Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[700])
                          ],
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 20),

                  // --- 2. KEY METRICS CARDS (Revenue, Orders, Avg) ---
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatCard("Total Pendapatan", formatRupiah(totalPendapatan), Icons.account_balance_wallet, Colors.green, "+12%"),
                        SizedBox(width: 15),
                        _buildStatCard("Total Pesanan", "$totalTransaksi", Icons.shopping_bag, Colors.orange, "+5"),
                        SizedBox(width: 15),
                        _buildStatCard("Rata-rata Order", formatRupiah(rataRataTransaksi), Icons.analytics, Colors.blue, "~"),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // --- 3. LEADERBOARD (Fasilitas Terlaris) ---
                  Text("Performa Fasilitas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        if (fasilitasPopuler.isEmpty) 
                          Padding(padding: EdgeInsets.all(20), child: Text("Belum ada data penjualan", style: TextStyle(color: Colors.grey))),
                        
                        ...fasilitasPopuler.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var item = entry.value;
                          int count = int.tryParse(item['total_pesanan'].toString()) ?? 0;
                          String nama = item['fasilitas']?['nama_fasilitas'] ?? 'Item Dihapus';
                          
                          // Kalkulasi persentase bar
                          int maxVal = fasilitasPopuler.isEmpty ? 1 : int.tryParse(fasilitasPopuler[0]['total_pesanan'].toString()) ?? 1;
                          double percent = (maxVal == 0) ? 0 : (count / maxVal);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Row(
                              children: [
                                // Rank Badge
                                Container(
                                  width: 30, height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: idx == 0 ? Colors.amber.withOpacity(0.2) : (idx == 1 ? Colors.grey[200] : Colors.orange[50]),
                                    shape: BoxShape.circle
                                  ),
                                  child: Text(
                                    "${idx + 1}", 
                                    style: TextStyle(fontWeight: FontWeight.bold, color: idx == 0 ? Colors.orange[800] : Colors.grey[700])
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(nama, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          Text("$count Terjual", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: mainColor)),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      // Progress Bar Modern
                                      Stack(
                                        children: [
                                          Container(height: 8, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4))),
                                          FractionallySizedBox(
                                            widthFactor: percent,
                                            child: Container(
                                              height: 8, 
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(colors: [mainColor.withOpacity(0.6), mainColor]),
                                                borderRadius: BorderRadius.circular(4)
                                              )
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList()
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // --- 4. TABEL TRANSAKSI TERBARU (Clean List) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Transaksi Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text("Lihat Semua", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 15),

                  transaksiTerbaru.isEmpty
                    ? Center(child: Text("Belum ada transaksi.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: transaksiTerbaru.length,
                        itemBuilder: (context, index) {
                          final item = transaksiTerbaru[index];
                          final harga = double.tryParse(item['total_harga']?.toString() ?? '0') ?? 0;
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: Offset(0, 3))],
                            ),
                            child: Row(
                              children: [
                                // Icon Box
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                                  child: Icon(Icons.arrow_downward_rounded, color: Colors.green, size: 20),
                                ),
                                SizedBox(width: 15),
                                // Info Transaksi
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['fasilitas']['nama_fasilitas'] ?? '-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      SizedBox(height: 4),
                                      Text(
                                        "${item['user']['nama']} • ${formatDate(item['created_at'])}", 
                                        style: TextStyle(fontSize: 11, color: Colors.grey[500])
                                      ),
                                    ],
                                  ),
                                ),
                                // Harga
                                Text(
                                  formatRupiah(harga),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  
                  SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // WIDGET KARTU STATISTIK (Didesain Lebar dan Horizontal Scrollable)
  Widget _buildStatCard(String title, String value, IconData icon, Color color, String growth) {
    return Container(
      width: 160, // Fixed width agar rapi di horizontal scroll
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              // Indikator kenaikan (Dummy visual)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)),
                child: Text(growth, style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          SizedBox(height: 15),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}