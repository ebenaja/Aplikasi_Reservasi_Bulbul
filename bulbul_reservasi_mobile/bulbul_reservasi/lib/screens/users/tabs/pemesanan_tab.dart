import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/reservasi_service.dart';
import 'package:bulbul_reservasi/screens/users/add_review_dialog.dart';

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

  // Input Nomor Referensi (Konfirmasi Bayar)
  void _showKonfirmasiDialog(int reservasiId) {
    TextEditingController _refController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi Pembayaran"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Masukkan Nomor Referensi / ID Transaksi:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(height: 10),
            TextField(
              controller: _refController,
              decoration: InputDecoration(labelText: "No. Referensi", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () async {
              if (_refController.text.isEmpty) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sedang memproses...")));

              bool success = await _reservasiService.konfirmasiPembayaran(reservasiId, _refController.text);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Konfirmasi Berhasil!"), backgroundColor: Colors.green));
                _fetchHistory();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal konfirmasi."), backgroundColor: Colors.red));
              }
            },
            child: Text("Kirim", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // Dialog Ulasan
  void _openReviewDialog(int fasilitasId) async {
    await showDialog(
      context: context,
      builder: (context) => AddReviewDialog(fasilitasId: fasilitasId),
    );
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
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _history.isEmpty
              ? Center(child: Text("Belum ada riwayat pemesanan"))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    final fasilitas = item['fasilitas'];
                    final status = item['status'] ?? 'pending';
                    bool isPending = status == 'pending';

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fasilitas != null ? fasilitas['nama_fasilitas'] : 'Item Dihapus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 5),
                            Text("Rp ${item['total_harga']} - Status: $status", style: TextStyle(color: Colors.grey)),
                            Divider(),
                            if (isPending)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showKonfirmasiDialog(item['id']),
                                  icon: Icon(Icons.check_circle_outline),
                                  label: Text("Konfirmasi Pembayaran"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                ),
                              )
                            else if (status == 'selesai')
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(onPressed: () => _openReviewDialog(fasilitas['id']), child: Text("Beri Ulasan")),
                              )
                            else
                              Center(child: Text("Menunggu Verifikasi Admin", style: TextStyle(color: mainColor, fontStyle: FontStyle.italic)))
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}