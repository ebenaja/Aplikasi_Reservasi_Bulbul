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
  final Color mainColor = Color(0xFF50C2C9);
  
  bool _isLoading = true;
  
  // Variabel Data
  double totalPendapatan = 0;
  int totalTransaksi = 0;
  List<dynamic> fasilitasPopuler = [];
  List<dynamic> transaksiTerbaru = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final data = await _service.getStatistics();
    if (mounted) {
      setState(() {
        totalPendapatan = double.parse(data['total_pendapatan']?.toString() ?? '0');
        totalTransaksi = int.parse(data['total_transaksi']?.toString() ?? '0');
        fasilitasPopuler = data['fasilitas_populer'] ?? [];
        transaksiTerbaru = data['transaksi_terbaru'] ?? [];
        _isLoading = false;
      });
    }
  }

  // Helper Format Rupiah
  String formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      appBar: AppBar(
        title: Text("Laporan Keuangan", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ringkasan Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  
                  // 1. KARTU RINGKASAN (Revenue & Count)
                  Row(
                    children: [
                      _buildSummaryCard("Total Pendapatan", formatRupiah(totalPendapatan), Icons.monetization_on, Colors.green),
                      SizedBox(width: 15),
                      _buildSummaryCard("Total Transaksi", "$totalTransaksi Pesanan", Icons.shopping_cart, Colors.orange),
                    ],
                  ),

                  SizedBox(height: 30),
                  Text("Fasilitas Terlaris", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),

                  // 2. LIST FASILITAS TERPOPULER
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                    ),
                    child: fasilitasPopuler.isEmpty
                      ? Text("Belum ada data")
                      : Column(
                          children: fasilitasPopuler.map((item) {
                            // Hitung persentase sederhana untuk bar (maksimal anggap 10 pesanan sbg 100% dummy logic)
                            int count = item['total_pesanan'];
                            String nama = item['fasilitas']?['nama_fasilitas'] ?? 'Item Dihapus';
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(nama, style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text("$count Pesanan", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  // Bar Chart Sederhana
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: LinearProgressIndicator(
                                      value: (count / (totalTransaksi == 0 ? 1 : totalTransaksi)), // Persentase relatif total
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                  ),

                  SizedBox(height: 30),
                  Text("Transaksi Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),

                  // 3. LIST RIWAYAT TRANSAKSI TERBARU
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: transaksiTerbaru.length,
                    itemBuilder: (context, index) {
                      final item = transaksiTerbaru[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: mainColor.withOpacity(0.1),
                            child: Icon(Icons.receipt_long, color: mainColor),
                          ),
                          title: Text(item['fasilitas']['nama_fasilitas'] ?? '-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text("${item['user']['nama']} • ${item['tanggal_sewa']}", style: TextStyle(fontSize: 12)),
                          trailing: Text(
                            "Rp ${NumberFormat('#,###', 'id_ID').format(double.parse(item['total_harga']))}",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  if (transaksiTerbaru.isEmpty) Text("Belum ada transaksi.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
    );
  }

  // Widget Helper: Kartu Ringkasan
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}