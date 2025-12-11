import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/admin_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

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
            SnackBar(
              content: Text("Gagal update status", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          )
        );
      }
    } finally {
      if (mounted) setState(() => _updatingId = null);
    }
  }

  // --- FUNGSI HAPUS DATA ---
  void _deleteItem(int id) async {
    bool confirm = await showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: Text("Hapus Data?"),
        content: Text("Data reservasi ini akan dihapus permanen."),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(ctx, false), child: Text("Batal")),
          TextButton(onPressed: ()=>Navigator.pop(ctx, true), child: Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      )
    ) ?? false;

    if (confirm) {
      setState(() => _deletingId = id);
      try {
        bool success = await _service.deleteReservasi(id);
        if (success) {
          _fetchData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Data berhasil dihapus", style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              )
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Gagal menghapus", style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.grey[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              )
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $e", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
          );
        }
      } finally {
        if (mounted) setState(() => _deletingId = null);
      }
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
                    Text("Kode Referensi / VA", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    SizedBox(height: 5),
                    Text(
                      bukti, 
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black87),
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
            // HEADER GRADIENT
            SliverAppBar(
              expandedHeight: 180,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mainColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(top: -50, left: -50, child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.1))),
                      Positioned(top: 40, right: -30, child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1))),
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeInDown(child: Text("Manajemen Reservasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white))),
                              SizedBox(height: 5),
                              FadeInUp(delay: Duration(milliseconds: 100), child: Text("Total: ${_reservasi.length} reservasi", style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)))),
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
            // CONTENT BODY
            SliverToBoxAdapter(
              child: _isLoading
                ? Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: mainColor)))
                : _reservasi.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                            SizedBox(height: 15),
                            Text("Belum ada data reservasi.", style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500)),
                            SizedBox(height: 5),
                            Text("Reservasi dari pengunjung akan muncul di sini", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _reservasi.length,
                        itemBuilder: (context, index) => FadeInUp(
                          delay: Duration(milliseconds: index * 100),
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
    bool isDeleting = _deletingId == id;
    bool isUpdating = _updatingId == id;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER CARD (ID & STATUS + HAPUS) ---
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mainColor.withOpacity(0.08), secondaryColor.withOpacity(0.08)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Kiri: ID & Status
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: mainColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text("#${item['id']}", style: TextStyle(fontWeight: FontWeight.bold, color: mainColor, fontSize: 12)),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_getStatusText(status), style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(status), fontSize: 11)),
                    ),
                  ],
                ),
                
                // Kanan: Tombol Hapus dengan Loading
                GestureDetector(
                  onTap: isDeleting ? null : () => _deleteItem(id),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(isDeleting ? 0.3 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: isDeleting
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                      : Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
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
                CircleAvatar(
                  backgroundColor: mainColor.withOpacity(0.1),
                  child: Text(user['nama'][0].toUpperCase(), style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                ),
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

          // --- FOOTER ACTION ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showBuktiDialog(dataBukti, user['nama']),
                    icon: Icon(
                      dataBukti == null ? Icons.upload_file_rounded : (isImageBukti ? Icons.image_rounded : Icons.receipt_rounded),
                      size: 16,
                    ),
                    label: Text(
                      dataBukti == null ? "Belum Ada" : (isImageBukti ? "Cek Foto" : "Cek Kode"),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dataBukti != null ? Colors.blue : Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                  ),
                ),
                
                SizedBox(width: 10),

                Expanded(
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
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [mainColor, secondaryColor]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: mainColor.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 3))]
                      ),
                      child: isUpdating
                        ? Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text("Status", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Icon(Icons.expand_more, color: Colors.white, size: 16)
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