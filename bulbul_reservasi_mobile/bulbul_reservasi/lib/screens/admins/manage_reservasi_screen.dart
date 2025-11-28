import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/admin_service.dart';

class ManageReservasiScreen extends StatefulWidget {
  const ManageReservasiScreen({super.key});
  @override
  _ManageReservasiScreenState createState() => _ManageReservasiScreenState();
}

class _ManageReservasiScreenState extends State<ManageReservasiScreen> {
  final AdminService _service = AdminService();
  List<dynamic> _reservasi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getReservations();
      if (mounted) {
        setState(() {
          _reservasi = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateStatus(int id, String status) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mengupdate status...")));
    
    bool success = await _service.updateStatusReservasi(id, status);
    
    if (success) {
      _fetchData(); 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Status berhasil diubah ke $status"), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal update status"), backgroundColor: Colors.red));
    }
  }

  // --- REVISI DIALOG BUKTI (Bisa Teks atau Gambar) ---
  void _showBuktiDialog(String? bukti) {
    // Cek apakah bukti ini URL gambar atau Teks biasa
    bool isImage = bukti != null && (bukti.startsWith('http') || bukti.contains('storage'));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Bukti Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)),
        contentPadding: EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (bukti == null || bukti.isEmpty)
              Text("User belum melakukan konfirmasi pembayaran.", textAlign: TextAlign.center)
            else if (isImage)
              // Jika URL Gambar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  bukti, 
                  fit: BoxFit.contain,
                  errorBuilder: (_,__,___) => Text("Gagal memuat gambar"),
                ),
              )
            else
              // Jika Teks (Nomor Referensi)
              Column(
                children: [
                  Text("Nomor Referensi / VA:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Text(
                      bukti, 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Cek mutasi bank Anda dengan nomor ini.", style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Tutup"))
        ],
      ),
    );
  }

  // Helper Warna Status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'menunggu': return Colors.blue; // Menunggu verifikasi
      case 'dibayar': return Colors.purple; // Sudah bayar tapi belum selesai liburan
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
        title: Text("Reservasi & Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: Color(0xFF50C2C9), 
        foregroundColor: Colors.white
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF50C2C9)))
          : _reservasi.isEmpty
              ? Center(child: Text("Belum ada data reservasi"))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _reservasi.length,
                  itemBuilder: (context, index) {
                    final item = _reservasi[index];
                    
                    final user = item['user'] ?? {'nama': 'User Terhapus'};
                    final fasilitas = item['fasilitas'] ?? {'nama_fasilitas': 'Fasilitas Terhapus'};
                    
                    // Ambil data pembayaran dari relasi
                    final pembayaran = item['pembayaran']; 
                    final String? dataBukti = pembayaran != null ? pembayaran['bukti'] : null;
                    final status = item['status'] ?? 'pending';

                    // Ikon Status Bukti
                    IconData iconBukti;
                    Color warnaBukti;
                    if (dataBukti != null) {
                      iconBukti = Icons.check_circle; // Sudah upload
                      warnaBukti = Colors.green;
                    } else {
                      iconBukti = Icons.pending_actions; // Belum upload
                      warnaBukti = Colors.grey;
                    }

                    return Card(
                      margin: EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text("Order #${item['id']} - ${user['nama']}", style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text("Item: ${fasilitas['nama_fasilitas']}"),
                                  Text("Total: Rp ${item['total_harga']}"),
                                  SizedBox(height: 8),
                                  
                                  // Badge Status
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Text(status.toUpperCase(), style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12)),
                                  )
                                ],
                              ),
                              // Tombol Lihat Bukti
                              trailing: IconButton(
                                icon: Icon(Icons.receipt_long, color: dataBukti != null ? Colors.blue : Colors.grey),
                                onPressed: () => _showBuktiDialog(dataBukti),
                                tooltip: "Lihat Bukti Bayar",
                              ),
                            ),
                            Divider(),
                            
                            // Tombol Aksi Admin (Ubah Status)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(iconBukti, size: 16, color: warnaBukti),
                                    SizedBox(width: 5),
                                    Text(
                                      dataBukti != null ? "Bukti Diterima" : "Menunggu Bukti",
                                      style: TextStyle(fontSize: 12, color: warnaBukti)
                                    )
                                  ],
                                ),
                                PopupMenuButton<String>(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(color: Color(0xFF50C2C9), borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      children: [
                                        Text("Ubah Status", style: TextStyle(color: Colors.white, fontSize: 12)),
                                        Icon(Icons.arrow_drop_down, color: Colors.white, size: 16)
                                      ],
                                    ),
                                  ),
                                  onSelected: (val) => _updateStatus(item['id'], val),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(value: 'dibayar', child: Row(children: [Icon(Icons.check, color: Colors.blue), SizedBox(width: 8), Text("Valid (Dibayar)")])),
                                    PopupMenuItem(value: 'selesai', child: Row(children: [Icon(Icons.done_all, color: Colors.green), SizedBox(width: 8), Text("Selesai (Checkout)")])),
                                    PopupMenuItem(value: 'batal', child: Row(children: [Icon(Icons.cancel, color: Colors.red), SizedBox(width: 8), Text("Batalkan")])),
                                  ],
                                ),
                              ],
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