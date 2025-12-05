import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bulbul_reservasi/services/reservasi_service.dart';
import 'package:bulbul_reservasi/screens/users/add_review_dialog.dart';
import 'package:bulbul_reservasi/screens/users/order_detail_screen.dart'; 

class PemesananTab extends StatefulWidget {
  const PemesananTab({super.key});

  @override
  _PemesananTabState createState() => _PemesananTabState();
}

class _PemesananTabState extends State<PemesananTab> with TickerProviderStateMixin {
  final ReservasiService _reservasiService = ReservasiService();
  final Color mainColor = const Color(0xFF50C2C9);
  
  List<dynamic> _allHistory = [];
  List<dynamic> _filteredList = [];
  bool _isLoading = true;

  // Filter
  final List<String> _filters = ["Belum Bayar", "Selesai", "Dibatalkan"];
  String _selectedFilter = "Belum Bayar";

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final data = await _reservasiService.getHistory();
      if (mounted) {
        setState(() {
          _allHistory = data;
          _filterData();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterData() {
    setState(() {
      _filteredList = _allHistory.where((item) {
        String status = (item['status'] ?? 'pending').toLowerCase();
        
        if (_selectedFilter == "Belum Bayar") {
          return status == 'pending' || status == 'menunggu' || status == 'paid';
        } else if (_selectedFilter == "Selesai") {
          return status == 'selesai' || status == 'success';
        } else if (_selectedFilter == "Dibatalkan") {
          if (status == 'batal' || status == 'cancelled' || status == 'ditolak') {
            // Logika 5 Menit Auto-Hide
            String? updatedAtStr = item['updated_at'];
            if (updatedAtStr != null) {
              DateTime updatedAt = DateTime.parse(updatedAtStr);
              if (DateTime.now().difference(updatedAt).inMinutes > 5) {
                return false; 
              }
            }
            return true;
          }
          return false;
        }
        return false;
      }).toList();
    });
  }

  String formatRupiah(var price) {
    double priceDouble = double.tryParse(price.toString()) ?? 0.0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(priceDouble);
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (e) { return dateStr; }
  }

  // --- MODAL PILIHAN PEMBAYARAN ---
  void _showPaymentOptions(int reservasiId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              SizedBox(height: 20),
              Text("Metode Konfirmasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 25),
              _buildOptionTile(Icons.image, "Upload Bukti Foto", "Screenshot transfer / struk", () {
                Navigator.pop(context); _uploadBuktiGambar(reservasiId);
              }),
              SizedBox(height: 15),
              _buildOptionTile(Icons.edit, "Input No. Referensi", "Jika tidak ada foto", () {
                Navigator.pop(context); _showKonfirmasiDialogText(reservasiId);
              }),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // --- TILE OPSI PEMBAYARAN ---
  Widget _buildOptionTile(IconData icon, String title, String sub, VoidCallback onTap) {
    return BouncingButton(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 5))]
        ),
        child: Row(
          children: [
            Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: mainColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: mainColor)),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(sub, style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _uploadBuktiGambar(int reservasiId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      showDialog(context: context, barrierDismissible: false, builder: (ctx) => Center(child: CircularProgressIndicator(color: mainColor)));
      bool success = await _reservasiService.uploadBukti(reservasiId, File(pickedFile.path));
      Navigator.pop(context);
      if (success) {
        _fetchHistory();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bukti Berhasil Diupload!"), backgroundColor: Colors.green));
      }
    }
  }

  void _showKonfirmasiDialogText(int reservasiId) {
    TextEditingController refController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi Pembayaran"),
        content: TextField(controller: refController, decoration: InputDecoration(labelText: "No. Referensi", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () async {
              if (refController.text.isEmpty) return;
              Navigator.pop(context);
              // Asumsi: Ada fungsi konfirmasiPembayaran di service (jika belum ada, abaikan bagian ini)
              // bool success = await _reservasiService.konfirmasiPembayaran(reservasiId, refController.text);
            },
            child: Text("Kirim", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _cancelOrder(int reservasiId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Batalkan Pesanan?"),
        content: Text("Yakin ingin membatalkan pesanan ini?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Tidak")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Ya, Batalkan", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    // Jika ingin mengaktifkan fitur cancel, uncomment baris ini (jika service sudah ada)
    /*
    if (confirm) {
      bool success = await _reservasiService.cancelReservasi(reservasiId);
      if (success) {
        _fetchHistory(); 
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pesanan dibatalkan"), backgroundColor: Colors.red));
      }
    }
    */
  }

  void _openReviewDialog(int fasilitasId) async {
    await showDialog(context: context, builder: (context) => AddReviewDialog(fasilitasId: fasilitasId));
  }

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Riwayat Pesanan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: mainColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // --- 1. CUSTOM FILTER TABS ---
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  bool isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                        _filterData();
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? mainColor : Colors.grey[100],
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: isSelected ? [BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 8, offset: Offset(0, 4))] : [],
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // --- 2. LIST DATA DENGAN ANIMASI ---
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: mainColor))
                : _filteredList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async => _fetchHistory(),
                        color: mainColor,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          itemCount: _filteredList.length,
                          itemBuilder: (context, index) {
                            return _buildHistoryCard(_filteredList[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_rounded, size: 60, color: Colors.grey[400]),
          ),
          SizedBox(height: 20),
          Text("Tidak ada pesanan $_selectedFilter", style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          if (_selectedFilter == "Dibatalkan")
             Padding(padding: EdgeInsets.only(top: 8), child: Text("(Hilang otomatis setelah 5 menit)", style: TextStyle(fontSize: 11, color: Colors.grey[400]))),
        ],
      ),
    );
  }

  // --- FUNGSI UNTUK MEMBUAT KARTU ---
  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final fasilitas = item['fasilitas'];
    final status = item['status'] ?? 'pending';
    final totalHarga = formatRupiah(item['total_harga']);
    final tanggal = formatDate(item['created_at']);
    final String? imgUrl = fasilitas != null ? fasilitas['foto'] : null;
    final String title = fasilitas != null ? fasilitas['nama_fasilitas'] : 'Item Dihapus';

    Color statusColor;
    String statusText;
    switch (status.toLowerCase()) {
      case 'success': case 'selesai': statusColor = Colors.green; statusText = "Selesai"; break;
      case 'menunggu': case 'paid': statusColor = Colors.blueAccent; statusText = "Verifikasi"; break;
      case 'pending': statusColor = Colors.orange; statusText = "Bayar"; break;
      case 'batal': statusColor = Colors.redAccent; statusText = "Batal"; break;
      default: statusColor = Colors.grey; statusText = status;
    }

    // --- PERBAIKAN UTAMA: Navigasi ke OrderDetailScreen ada DI SINI ---
    return GestureDetector(
      onTap: () {
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(transaction: item), 
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))]
        ),
        child: Column(
          children: [ 
            // IMAGE HEADER
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(height: 140, width: double.infinity, child: _buildImage(imgUrl)),
                ),
                Positioned.fill(
                  child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(20)), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.center, colors: [Colors.black.withOpacity(0.3), Colors.transparent]))),
                ),
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
            
            // INFO BODY
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 6),
                  Row(children: [Icon(Icons.calendar_today, size: 14, color: Colors.grey), SizedBox(width: 6), Text(tanggal, style: TextStyle(fontSize: 12, color: Colors.grey))]),
                  
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Tagihan", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(totalHarga, style: TextStyle(color: mainColor, fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),

                      // --- ACTION BUTTONS ---
                      if (status == 'pending')
                        Row(
                          children: [
                            _buildStyledButton(
                              "Batal", 
                              Colors.white, 
                              Colors.redAccent, 
                              () => _cancelOrder(item['id']),
                              borderColor: Colors.redAccent
                            ),
                            SizedBox(width: 10),
                            _buildStyledButton(
                              "Bayar", 
                              Colors.orange, 
                              Colors.white, 
                              () => _showPaymentOptions(item['id'])
                            ),
                          ],
                        )
                      else if (status == 'success' || status == 'selesai')
                        _buildStyledButton(
                          "Ulas", 
                          Colors.white, 
                          mainColor, 
                          () => _openReviewDialog(fasilitas != null ? fasilitas['id'] : 0),
                          borderColor: mainColor
                        )
                      else if (status == 'menunggu')
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Row(children: [Icon(Icons.access_time_filled, size: 14, color: Colors.blue), SizedBox(width: 5), Text("Diproses", style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold))]),
                        )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper Tombol
  Widget _buildStyledButton(String text, Color bgColor, Color textColor, VoidCallback onTap, {Color? borderColor}) {
    return BouncingButton(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: borderColor != null ? Border.all(color: borderColor) : null,
          boxShadow: borderColor == null ? [BoxShadow(color: bgColor.withOpacity(0.4), blurRadius: 5, offset: Offset(0, 2))] : [],
        ),
        child: Text(
          text, 
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)
        ),
      ),
    );
  }
}

// --- ANIMATED BOUNCING BUTTON ---
class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const BouncingButton({super.key, required this.child, required this.onTap});

  @override
  _BouncingButtonState createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}