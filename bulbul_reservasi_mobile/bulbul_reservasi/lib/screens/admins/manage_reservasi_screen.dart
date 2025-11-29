import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/admin_service.dart';

class ManageReservasiScreen extends StatefulWidget {
  const ManageReservasiScreen({super.key});
  @override
  _ManageReservasiScreenState createState() => _ManageReservasiScreenState();
}

class _ManageReservasiScreenState extends State<ManageReservasiScreen> {
  final AdminService _service = AdminService();
  
  // Warna Palette
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  final Color bgPage = const Color(0xFFF5F7FA);

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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateStatus(int id, String status) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mengupdate status..."), duration: Duration(milliseconds: 500)));
    
    bool success = await _service.updateStatusReservasi(id, status);
    
    if (success) {
      _fetchData(); 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Status berhasil diubah ke $status"), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal update status"), backgroundColor: Colors.red));
    }
  }

  // --- DIALOG BUKTI MODERN ---
  void _showBuktiDialog(String? bukti, String userName) {
    bool isImage = bukti != null && (bukti.startsWith('http') || bukti.contains('storage'));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.receipt_long_rounded, size: 40, color: mainColor),
            SizedBox(height: 10),
            Text("Bukti Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(userName, style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (bukti == null || bukti.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey[300]),
                    SizedBox(height: 10),
                    Text("Belum ada bukti yang dikirim.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else if (isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  bukti, 
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => Column(
                    children: [
                      Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      Text("Gagal memuat gambar")
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!)
                ),
                child: Column(
                  children: [
                    Text("Kode Referensi / VA", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    SizedBox(height: 5),
                    Text(
                      bukti, 
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: Colors.blue),
                        SizedBox(width: 5),
                        Text("Cek mutasi bank Anda", style: TextStyle(fontSize: 12, color: Colors.blue)),
                      ],
                    )
                  ],
                ),
              )
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Tutup", style: TextStyle(color: Colors.grey)),
            ),
          )
        ],
      ),
    );
  }

  // Helper Warna Status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'menunggu': return Colors.blueAccent; 
      case 'dibayar': return Colors.purple; 
      case 'selesai': return Colors.green;
      case 'batal': 
      case 'cancelled': return Colors.redAccent;
      default: return Colors.grey;
    }
  }

  // Helper Text Status
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return "Belum Bayar";
      case 'menunggu': return "Verifikasi"; 
      case 'dibayar': return "Lunas"; 
      case 'selesai': return "Selesai";
      case 'batal': return "Dibatalkan";
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      
      // HEADER GRADIENT
      appBar: AppBar(
        title: Text("Manajemen Reservasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
      ),
      
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _reservasi.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                    SizedBox(height: 15),
                    Text("Belum ada data reservasi masuk.", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: _reservasi.length,
                  itemBuilder: (context, index) => _buildReservasiCard(_reservasi[index]),
                ),
    );
  }

  Widget _buildReservasiCard(Map<String, dynamic> item) {
    final user = item['user'] ?? {'nama': 'User Terhapus'};
    final fasilitas = item['fasilitas'] ?? {'nama_fasilitas': 'Fasilitas Terhapus'};
    final pembayaran = item['pembayaran']; 
    final String? dataBukti = pembayaran != null ? pembayaran['bukti'] : null;
    final status = item['status'] ?? 'pending';

    bool isImageBukti = dataBukti != null && (dataBukti.startsWith('http') || dataBukti.contains('storage'));

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER CARD (ID & TANGGAL) ---
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.tag, size: 16, color: Colors.grey),
                    Text("Order ID: ${item['id']}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                  ],
                ),
                // Badge Status
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(status).withOpacity(0.2))
                  ),
                  child: Text(
                    _getStatusText(status).toUpperCase(), 
                    style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 10)
                  ),
                )
              ],
            ),
          ),

          // --- BODY CARD (USER & ITEM) ---
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar User
                CircleAvatar(
                  backgroundColor: mainColor.withOpacity(0.1),
                  child: Text(user['nama'][0].toUpperCase(), style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 15),
                // Detail
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['nama'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text(fasilitas['nama_fasilitas'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      SizedBox(height: 8),
                      Text("Total: Rp ${item['total_harga']}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- FOOTER ACTION ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // TOMBOL LIHAT BUKTI
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showBuktiDialog(dataBukti, user['nama']),
                    icon: Icon(
                      dataBukti == null ? Icons.warning_amber_rounded : (isImageBukti ? Icons.image_rounded : Icons.receipt_long_rounded),
                      size: 16,
                      color: dataBukti == null ? Colors.grey : Colors.blue
                    ),
                    label: Text(
                      dataBukti == null ? "Belum Bayar" : (isImageBukti ? "Cek Foto" : "Cek Kode"),
                      style: TextStyle(fontSize: 12, color: dataBukti == null ? Colors.grey : Colors.blue)
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                  ),
                ),
                
                SizedBox(width: 10),

                // TOMBOL UBAH STATUS (DROPDOWN)
                Expanded(
                  child: PopupMenuButton<String>(
                    offset: Offset(0, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: mainColor.withOpacity(0.3), blurRadius: 5, offset: Offset(0, 2))]
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Ubah Status", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(width: 5),
                          Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16)
                        ],
                      ),
                    ),
                    onSelected: (val) => _updateStatus(item['id'], val),
                    itemBuilder: (context) => [
                      _buildMenuItem('dibayar', Icons.verified_user_outlined, Colors.purple, "Terima Bayar"),
                      _buildMenuItem('selesai', Icons.check_circle_outline, Colors.green, "Selesai (Liburan)"),
                      _buildMenuItem('batal', Icons.cancel_outlined, Colors.red, "Tolak / Batal"),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, Color color, String text) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Text(text, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}