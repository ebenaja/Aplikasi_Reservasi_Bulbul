import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

import 'package:bulbul_reservasi/services/reservasi_service.dart';
import 'package:bulbul_reservasi/utils/image_picker_helper.dart';

class PemesananTab extends StatefulWidget {
  const PemesananTab({super.key});

  @override
  _PemesananTabState createState() => _PemesananTabState();
}

class _PemesananTabState extends State<PemesananTab> {
  final ReservasiService _reservasiService = ReservasiService();
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  // Agar data refresh saat tab dibuka kembali
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final data = await _reservasiService.getHistory();
    if (mounted) {
      setState(() {
        _history = data;
        _isLoading = false;
      });
    }
  }

  void _uploadBukti(int reservasiId) async {
    // Tampilkan dialog pilihan sumber gambar
    File? imageFile = await ImagePickerHelper.pickImageWithOptions(context);
    
    if (imageFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mengupload bukti...")));
      bool success = await _reservasiService.uploadBukti(reservasiId, imageFile);
      
      if (mounted) {
        if (success) {
          _fetchHistory();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil! Menunggu Verifikasi."), backgroundColor: Colors.green));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal Upload."), backgroundColor: Colors.red));
        }
      }
    }
  }

  // Helper Gambar
  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Image.asset("assets/images/pantai_landingscreens.jpg", fit: BoxFit.cover);
    } else if (path.startsWith("http")) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[200], child: Icon(Icons.broken_image, color: Colors.grey)));
    } else {
      return Image.asset(path, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Riwayat Pesanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [mainColor, secondaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _history.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey[300]),
                    SizedBox(height: 10),
                    Text("Belum ada pesanan", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ))
              : RefreshIndicator(
                  onRefresh: _fetchHistory,
                  color: mainColor,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      // Animasi muncul satu per satu
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 100),
                        child: _buildHistoryCard(item)
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    final fasilitas = item['fasilitas'];
    final status = (item['status'] ?? 'pending').toString().toLowerCase();
    
    // Format Rupiah
    final totalHarga = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(double.tryParse(item['total_harga'].toString()) ?? 0);
    
    // Format Tanggal
    String tanggalSewa = "-";
    try {
      tanggalSewa = DateFormat('dd MMM yyyy').format(DateTime.parse(item['tanggal_sewa']));
    } catch (e) {}

    // Logika Status
    Color statusColor;
    String statusText;
    
    if (status == 'pending') {
      statusColor = Colors.orange;
      statusText = "Belum Bayar";
    } else if (status == 'menunggu') {
      statusColor = Colors.blue;
      statusText = "Verifikasi";
    } else if (status == 'selesai' || status == 'dibayar') {
      statusColor = Colors.green;
      statusText = "Selesai";
    } else {
      statusColor = Colors.red;
      statusText = "Batal";
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          // BAGIAN ATAS: Info Utama
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Kecil
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 70, height: 70,
                    child: _buildImage(fasilitas != null ? fasilitas['foto'] : null),
                  ),
                ),
                SizedBox(width: 12),
                
                // Teks Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              fasilitas != null ? fasilitas['nama_fasilitas'] : 'Item dihapus',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Badge Status
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                          )
                        ],
                      ),
                      SizedBox(height: 5),
                      Text("Tanggal: $tanggalSewa", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      SizedBox(height: 5),
                      Text(totalHarga, style: TextStyle(color: mainColor, fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // BAGIAN BAWAH: Tombol Aksi
          if (status == 'pending')
            Container(
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text("Segera lakukan pembayaran", style: TextStyle(color: Colors.orange[800], fontSize: 12))),
                  ElevatedButton(
                    onPressed: () => _uploadBukti(item['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: Size(80, 30),
                      padding: EdgeInsets.symmetric(horizontal: 10)
                    ),
                    child: Text("Bayar", style: TextStyle(color: Colors.white, fontSize: 12)),
                  )
                ],
              ),
            )
          else if (status == 'menunggu')
             Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[100]!))
              ),
              child: Center(
                child: Text("Sedang diperiksa oleh Admin...", style: TextStyle(color: Colors.blue, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            )
        ],
      ),
    );
  }
}