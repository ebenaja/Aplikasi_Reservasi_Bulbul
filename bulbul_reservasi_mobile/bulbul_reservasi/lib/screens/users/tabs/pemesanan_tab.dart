import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/reservasi_service.dart';
import 'package:bulbul_reservasi/screens/users/add_review_dialog.dart'; // Import Dialog Ulasan

class PemesananTab extends StatefulWidget {
  const PemesananTab({super.key});

  @override
  _PemesananTabState createState() => _PemesananTabState();
}

class _PemesananTabState extends State<PemesananTab> {
  final ReservasiService _reservasiService = ReservasiService();
  final Color mainColor = Color(0xFF50C2C9);
  
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  // Ambil data dari API
  void _fetchHistory() async {
    final data = await _reservasiService.getHistory();
    if (mounted) {
      setState(() {
        _history = data;
        _isLoading = false;
      });
    }
  }

  // Buka Dialog Ulasan
  void _openReviewDialog(int fasilitasId) async {
    await showDialog(
      context: context,
      builder: (context) => AddReviewDialog(fasilitasId: fasilitasId),
    );
    // Opsional: Refresh data setelah ulasan (jika perlu update status)
  }

  // Helper Warna Status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'dibayar': return Colors.blue;
      case 'selesai': return Colors.green;
      case 'batal': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      appBar: AppBar(
        title: Text("Riwayat Pesanan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: mainColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Hapus tombol back karena ini Tab
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey[300]),
                      SizedBox(height: 20),
                      Text("Belum ada riwayat pemesanan", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    final fasilitas = item['fasilitas']; // Data relasi dari Laravel
                    final status = item['status'] ?? 'pending';

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Card: Nama & Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    fasilitas != null ? fasilitas['nama_fasilitas'] : 'Fasilitas Dihapus', 
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(color: _getStatusColor(status), fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                            Divider(height: 20),
                            
                            // Info Detail
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                SizedBox(width: 5),
                                Text("Tgl: ${item['tanggal_sewa']}", style: TextStyle(fontSize: 13)),
                                Spacer(),
                                Text("Rp ${item['total_harga']}", style: TextStyle(fontWeight: FontWeight.bold, color: mainColor, fontSize: 15)),
                              ],
                            ),
                            
                            SizedBox(height: 5),
                            Text("Durasi: ${item['durasi']} (Hari/Jam)", style: TextStyle(fontSize: 12, color: Colors.grey)),

                            SizedBox(height: 15),

                            // TOMBOL AKSI
                            // Tampilkan tombol ulasan hanya jika fasilitas masih ada
                            if (fasilitas != null)
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: OutlinedButton.icon(
                                  onPressed: () => _openReviewDialog(fasilitas['id']),
                                  icon: Icon(Icons.star_rate, size: 18),
                                  label: Text("Beri Ulasan"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.amber[700],
                                    side: BorderSide(color: Colors.amber),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}