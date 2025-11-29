import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan sudah 'flutter pub add intl'
import 'package:bulbul_reservasi/services/reservasi_service.dart';
import 'package:bulbul_reservasi/screens/users/add_review_dialog.dart';

class PemesananTab extends StatefulWidget {
  const PemesananTab({super.key});

  @override
  _PemesananTabState createState() => _PemesananTabState();
}

class _PemesananTabState extends State<PemesananTab> {
  final ReservasiService _reservasiService = ReservasiService();
  final Color mainColor = const Color(0xFF50C2C9);
  
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  // 1. Fetch Data
  void _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final data = await _reservasiService.getHistory();
      if (mounted) {
        setState(() {
          _history = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper: Format Rupiah
  String formatRupiah(var price) {
    double priceDouble = double.tryParse(price.toString()) ?? 0.0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(priceDouble);
  }

  // Helper: Format Tanggal
  String formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  // Helper: Style Input Field (Konsisten dengan ProfileTab)
  InputDecoration _cleanInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      prefixIcon: Icon(icon, color: mainColor),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: mainColor, width: 1.5),
      ),
    );
  }

  // 2. Dialog Konfirmasi Pembayaran (Modern UI)
  void _showKonfirmasiDialog(int reservasiId) {
    TextEditingController refController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(child: Text("Konfirmasi Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Masukkan ID Transaksi / Bukti Transfer Anda.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(height: 20),
            TextField(
              controller: refController,
              decoration: _cleanInputDecoration("No. Referensi / ID", Icons.receipt_long),
            ),
          ],
        ),
        actionsPadding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    if (refController.text.isEmpty) return;
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sedang memproses..."), duration: Duration(seconds: 1)));

                    bool success = await _reservasiService.konfirmasiPembayaran(reservasiId, refController.text);

                    if (success) {
                      _fetchHistory(); // Refresh data
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Berhasil dikirim! Menunggu verifikasi admin."), backgroundColor: Colors.green));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengirim konfirmasi."), backgroundColor: Colors.red));
                    }
                  },
                  child: Text("Kirim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // 3. Dialog Ulasan
  void _openReviewDialog(int fasilitasId) async {
    await showDialog(
      context: context,
      builder: (context) => AddReviewDialog(fasilitasId: fasilitasId),
    );
  }

  // Helper Image Builder
  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Image.asset("assets/images/pantai_landingscreens.jpg", fit: BoxFit.cover);
    } else if (path.startsWith("http")) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.grey));
    } else {
      return Image.asset(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.image_not_supported, color: Colors.grey));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background bersih
      appBar: AppBar(
        title: Text(
          "Riwayat Pesanan", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)
        ),
        backgroundColor: mainColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _history.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async => _fetchHistory(),
                  color: mainColor,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildHistoryCard(_history[index]),
                      );
                    },
                  ),
                ),
    );
  }

  // Widget Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(color: mainColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_rounded, size: 60, color: mainColor),
          ),
          SizedBox(height: 20),
          Text("Belum ada pesanan", style: TextStyle(fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Pesanan Anda akan muncul di sini.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  // Widget Kartu Pesanan (Modern & Clean)
  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final fasilitas = item['fasilitas'];
    final status = item['status'] ?? 'pending';
    final totalHarga = formatRupiah(item['total_harga']);
    final tanggal = formatDate(item['created_at']);
    final String? imgUrl = fasilitas != null ? fasilitas['foto'] : null;
    final String title = fasilitas != null ? fasilitas['nama_fasilitas'] : 'Item Dihapus';

    // Tentukan Warna & Label Status
    Color statusColor;
    String statusText;
    
    switch (status.toLowerCase()) {
      case 'success':
      case 'selesai':
        statusColor = Colors.green;
        statusText = "Selesai";
        break;
      case 'paid':
        statusColor = Colors.blueAccent;
        statusText = "Menunggu Verifikasi";
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = "Belum Bayar";
        break;
      case 'cancelled':
      case 'batal':
        statusColor = Colors.redAccent;
        statusText = "Dibatalkan";
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER GAMBAR & STATUS
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(height: 150, width: double.infinity, child: _buildImage(imgUrl)),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(20)), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.center, colors: [Colors.black.withOpacity(0.3), Colors.transparent]))),
              ),
              // Status Badge (Kanan Atas)
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                  child: Text(statusText, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
            ],
          ),

          // BODY KARTU
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 5),
                Row(children: [Icon(Icons.calendar_today, size: 14, color: Colors.grey), SizedBox(width: 6), Text(tanggal, style: TextStyle(fontSize: 12, color: Colors.grey))]),
                
                SizedBox(height: 12),
                Divider(color: Colors.grey[200]),
                SizedBox(height: 12),

                // FOOTER: HARGA & TOMBOL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Tagihan", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(totalHarga, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),

                    // Logika Tombol Berdasarkan Status
                    if (status == 'pending')
                      ElevatedButton(
                        onPressed: () => _showKonfirmasiDialog(item['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          elevation: 0
                        ),
                        child: Text("Bayar", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    else if (status == 'success' || status == 'selesai')
                      OutlinedButton(
                        onPressed: () => _openReviewDialog(fasilitas != null ? fasilitas['id'] : 0),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: mainColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        ),
                        child: Text("Ulas", style: TextStyle(color: mainColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    else if (status == 'paid')
                      Container(
                         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                         decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                         child: Row(children: [Icon(Icons.access_time, size: 14, color: Colors.grey), SizedBox(width: 5), Text("Diproses", style: TextStyle(fontSize: 12, color: Colors.grey[700]))]),
                      )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}