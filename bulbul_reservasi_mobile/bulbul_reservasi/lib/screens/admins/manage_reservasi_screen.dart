import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/admin_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart'; // <--- INI YANG KURANG TADI

class ManageReservasiScreen extends StatefulWidget {
  const ManageReservasiScreen({super.key});
  @override
  _ManageReservasiScreenState createState() => _ManageReservasiScreenState();
}

class _ManageReservasiScreenState extends State<ManageReservasiScreen> {
  final AdminService _service = AdminService();
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  final Color bgPage = const Color(0xFFF5F7FA);
  
  List<dynamic> _reservasi = [];
  bool _isLoading = true;
  int? _updatingId; 
  int? _deletingId; 

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
    setState(() => _updatingId = id);
    try {
      bool success = await _service.updateStatusReservasi(id, status);
      if (success) {
        _fetchData(); 
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Status berhasil diubah ke $status", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal update status"), backgroundColor: Colors.red)
          );
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _updatingId = null);
    }
  }

  void _deleteItem(int id) async {
    bool confirm = await showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.warning_amber_rounded, size: 40, color: Colors.redAccent),
            SizedBox(height: 10),
            Text("Hapus Data?", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text("Data reservasi ini akan dihapus permanen.", textAlign: TextAlign.center),
        actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: ()=>Navigator.pop(ctx, false), child: Text("Batal"))),
              SizedBox(width: 10),
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: ()=>Navigator.pop(ctx, true), child: Text("Hapus", style: TextStyle(color: Colors.white)))),
            ],
          )
        ],
      )
    ) ?? false;

    if (confirm) {
      // Panggil update status ke batal dulu sbg simulasi hapus jika endpoint delete belum ada
      _updateStatus(id, 'batal'); 
    }
  }

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
                    Text("Kode Referensi / Catatan", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    SizedBox(height: 5),
                    Text(
                      bukti, 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
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
      body: RefreshIndicator(
        onRefresh: () async => _fetchData(),
        color: mainColor,
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            // HEADER
            SliverAppBar(
              expandedHeight: 170,
              floating: true,
              pinned: true,
              leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: ()=>Navigator.pop(context)),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [mainColor, secondaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Stack(
                    children: [
                      Positioned(top: -60, left: -40, child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.1))),
                      Positioned(top: 30, right: -50, child: CircleAvatar(radius: 70, backgroundColor: Colors.white.withOpacity(0.1))),
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(60, 16, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Manajemen Reservasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
                              SizedBox(height: 6),
                              Text("Total: ${_reservasi.length} transaksi", style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              backgroundColor: mainColor,
              elevation: 0,
              foregroundColor: Colors.white,
            ),
            
            // BODY
            SliverToBoxAdapter(
              child: _isLoading
                ? Center(child: Padding(padding: EdgeInsets.all(60), child: CircularProgressIndicator(color: mainColor)))
                : _reservasi.isEmpty
                  ? Center(child: Padding(padding: EdgeInsets.all(50), child: Text("Belum ada reservasi")))
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _reservasi.length,
                        itemBuilder: (context, index) => FadeInUp(
                          delay: Duration(milliseconds: index * 50),
                          child: _buildReservasiCard(_reservasi[index]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservasiCard(Map<String, dynamic> item) {
    final int id = item['id'];
    final user = item['user'] ?? {'nama': 'User Terhapus'};
    final fasilitas = item['fasilitas'] ?? {'nama_fasilitas': 'Fasilitas Terhapus'};
    final pembayaran = item['pembayaran']; 
    final String? dataBukti = pembayaran != null ? pembayaran['bukti'] : null;
    final status = item['status'] ?? 'pending';
    bool isImageBukti = dataBukti != null && (dataBukti.startsWith('http') || dataBukti.contains('storage'));
    bool isUpdating = _updatingId == id;
    bool isDeleting = _deletingId == id;

    return Container(
      margin: EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER CARD
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                    Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: mainColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text("#$id", style: TextStyle(fontWeight: FontWeight.bold, color: mainColor, fontSize: 12))),
                    SizedBox(width: 8),
                    // FORMAT TANGGAL YANG DIPERBAIKI (MENGGUNAKAN INTL)
                    Text(
                      DateFormat('dd MMM yyyy').format(DateTime.parse(item['created_at'])), 
                      style: TextStyle(color: Colors.grey, fontSize: 11)
                    ),
                ]),
                GestureDetector(
                  onTap: isDeleting ? null : () => _deleteItem(id),
                  child: isDeleting 
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red)) 
                    : Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                )
              ],
            ),
          ),

          // BODY
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(backgroundColor: mainColor.withOpacity(0.1), child: Text(user['nama'][0].toUpperCase(), style: TextStyle(color: mainColor, fontWeight: FontWeight.bold))),
                SizedBox(width: 15),
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

          // FOOTER ACTION
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showBuktiDialog(dataBukti, user['nama']),
                    icon: Icon(
                      dataBukti == null ? Icons.upload_file_rounded : (isImageBukti ? Icons.image : Icons.receipt),
                      size: 16,
                    ),
                    label: Text(
                      dataBukti == null ? "Belum Ada" : (isImageBukti ? "Cek Foto" : "Cek Kode"),
                      style: TextStyle(fontSize: 11)
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dataBukti != null ? Colors.blue : Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                  ),
                ),
                
                SizedBox(width: 10),

                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _getStatusColor(status).withOpacity(0.5))
                    ),
                    child: PopupMenuButton<String>(
                      offset: Offset(0, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      onSelected: (value) => _updateStatus(id, value),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(value: 'menunggu', child: Row(children: [Icon(Icons.hourglass_bottom, size: 16, color: Colors.orange), SizedBox(width: 10), Text("Verifikasi")])),
                        PopupMenuItem(value: 'dibayar', child: Row(children: [Icon(Icons.check_circle, size: 16, color: Colors.purple), SizedBox(width: 10), Text("Lunas")])),
                        PopupMenuItem(value: 'selesai', child: Row(children: [Icon(Icons.done_all, size: 16, color: Colors.green), SizedBox(width: 10), Text("Selesai")])),
                        PopupMenuItem(value: 'batal', child: Row(children: [Icon(Icons.cancel, size: 16, color: Colors.red), SizedBox(width: 10), Text("Batal")])),
                      ],
                      child: isUpdating
                        ? Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: _getStatusColor(status))))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_getStatusText(status), style: TextStyle(color: _getStatusColor(status), fontSize: 12, fontWeight: FontWeight.bold)),
                              Icon(Icons.arrow_drop_down, color: _getStatusColor(status))
                            ],
                          ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}