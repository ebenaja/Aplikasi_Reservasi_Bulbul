import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:animate_do/animate_do.dart'; // Pastikan animate_do ada di pubspec.yaml
import 'package:bulbul_reservasi/services/reservasi_service.dart';
import 'package:bulbul_reservasi/screens/users/add_review_dialog.dart';
import 'package:bulbul_reservasi/screens/users/payment_success_screen.dart'; 
import 'package:bulbul_reservasi/utils/image_picker_helper.dart';
import 'package:image_picker/image_picker.dart';



// import 'package:bulbul_reservasi/screens/users/order_detail_screen.dart'; // Uncomment jika sudah ada
// import 'package:bulbul_reservasi/screens/users/payment_instruction_screen.dart'; // Uncomment jika sudah ada

class PemesananTab extends StatefulWidget {
  const PemesananTab({super.key});

  @override
  _PemesananTabState createState() => _PemesananTabState();
}

class _PemesananTabState extends State<PemesananTab> {
  final ReservasiService _reservasiService = ReservasiService();
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  
  List<dynamic> _allHistory = [];
  List<dynamic> _filteredList = [];
  bool _isLoading = true;

  final List<String> _filters = ["Belum Bayar", "Selesai", "Dibatalkan"];
  String _selectedFilter = "Belum Bayar";

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

  void _fetchHistory() async {
    // if (mounted) setState(() => _isLoading = true); // Optional: loading state
    
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
    if (!mounted) return;
    setState(() {
      _filteredList = _allHistory.where((item) {
        String status = (item['status'] ?? 'pending').toLowerCase();
        
        if (_selectedFilter == "Belum Bayar") {
          return status == 'pending' || status == 'menunggu';
        } else if (_selectedFilter == "Selesai") {
          return status == 'selesai' || status == 'dibayar' || status == 'success';
        } else if (_selectedFilter == "Dibatalkan") {
          return status == 'batal' || status == 'cancelled' || status == 'ditolak';
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
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) { return dateStr; }
  }


// --- LOGIKA UPLOAD GAMBAR ---
void _uploadBuktiGambar(int reservasiId) async {
  final ImagePicker picker = ImagePicker();

  final XFile? pickedFile = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 30, // ✔ kompres
    maxWidth: 800,    // ✔ batasi ukuran
    maxHeight: 800,
  );

  if (pickedFile != null) {
    File imageFile = File(pickedFile.path);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mengupload bukti...")),
    );

    bool success =
        await _reservasiService.uploadBukti(reservasiId, imageFile);

    if (mounted) {
      if (success) {
        _fetchHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil! Menunggu Verifikasi."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal Upload."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}



  // --- LOGIKA INPUT REFERENSI (YANG HILANG TADI) ---
  void _inputNomorReferensi(int reservasiId) {
    TextEditingController refController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi Manual"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Masukkan No. Referensi / Catatan Transfer:"),
            SizedBox(height: 10),
            TextField(
              controller: refController,
              decoration: InputDecoration(
                hintText: "Contoh: Transfer a.n Budi",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () async {
              if (refController.text.isNotEmpty) {
                Navigator.pop(context); // Tutup dialog
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mengirim data...")));
                
                bool success = await _reservasiService.konfirmasiManual(reservasiId, refController.text);
                
                if (success) {
                  _fetchHistory();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konfirmasi Terkirim!"), backgroundColor: Colors.green));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal Mengirim."), backgroundColor: Colors.red));
                }
              }
            }, 
            child: Text("Kirim", style: TextStyle(color: Colors.white))
          )
        ],
      ),
    );
  }
  
  // --- LOGIKA BATALKAN ---
  void _cancelOrder(int reservasiId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Pesanan"),
        content: const Text("Yakin ingin membatalkan?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Tidak")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ya", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      // Panggil API Cancel (Pastikan di service ada fungsi cancelReservasi)
      // await _reservasiService.cancelReservasi(reservasiId); 
      // _fetchHistory();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Batal belum diimplementasikan di backend")));
    }
  }

  void _showPaymentOptions(Map<String, dynamic> item) {
    int reservasiId = item['id'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("Konfirmasi Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              
              // OPSI 1: UPLOAD GAMBAR
              ListTile(
                leading: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: mainColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.cloud_upload, color: mainColor)),
                title: Text("Upload Bukti Transfer"),
                subtitle: Text("Foto struk/screenshot"),
                onTap: () {
                  Navigator.pop(context); 
                  _uploadBuktiGambar(reservasiId);
                },
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
              
              Divider(),

              // OPSI 2: INPUT REFERENSI (INI YANG KEMARIN HILANG)
              ListTile(
                leading: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.edit_note, color: Colors.orange)),
                title: Text("Input No. Referensi"),
                subtitle: Text("Jika tidak ada foto"),
                onTap: () {
                  Navigator.pop(context);
                  _inputNomorReferensi(reservasiId);
                },
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openReviewDialog(int fasilitasId) async {
    await showDialog(context: context, builder: (context) => AddReviewDialog(fasilitasId: fasilitasId));
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) return Image.asset("assets/images/pantai_landingscreens.jpg", fit: BoxFit.cover);
    if (path.startsWith("http")) return Image.network(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.grey));
    return Image.asset(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.image_not_supported, color: Colors.grey));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA), // Warna konsisten
      appBar: AppBar(
        title: const Text("Riwayat Pesanan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), 
        backgroundColor: mainColor, 
        elevation: 0, 
        centerTitle: true, 
        automaticallyImplyLeading: false
      ),
      body: Column(
        children: [
          // FILTER TAB BAR
          Container(
            width: double.infinity, color: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _filters.map((filter) {
                  bool isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () { setState(() { _selectedFilter = filter; _filterData(); }); }, 
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300), 
                      curve: Curves.easeInOut, 
                      margin: const EdgeInsets.only(right: 12), 
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), 
                      decoration: BoxDecoration(
                        color: isSelected ? mainColor : Colors.grey[100], 
                        borderRadius: BorderRadius.circular(30), 
                        boxShadow: isSelected ? [BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : []
                      ), 
                      child: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 13))
                    )
                  );
                }).toList())),
          ),
          
          // LIST DATA
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: mainColor))
                : _filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey[300]),
                            SizedBox(height: 15),
                            Text("Belum ada pesanan $_selectedFilter", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          ],
                        )
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _fetchHistory(),
                        color: mainColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          itemCount: _filteredList.length,
                          itemBuilder: (context, index) => FadeInUp( // Animasi Masuk
                            delay: Duration(milliseconds: index * 100),
                            child: _buildHistoryCard(_filteredList[index])
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final fasilitas = item['fasilitas'];
    final status = item['status'] ?? 'pending';
    final totalHarga = formatRupiah(item['total_harga']);
    final tanggal = formatDate(item['tanggal_sewa']); // Pastikan field tanggal benar
    final String? imgUrl = fasilitas != null ? fasilitas['foto'] : null;
    final String title = fasilitas != null ? fasilitas['nama_fasilitas'] : 'Item Dihapus';

    Color statusColor;
    String statusText;
    switch (status.toLowerCase()) {
      case 'selesai': statusColor = Colors.green; statusText = "Selesai"; break;
      case 'menunggu': statusColor = Colors.blueAccent; statusText = "Verifikasi"; break;
      case 'pending': statusColor = Colors.orange; statusText = "Belum Bayar"; break;
      case 'batal': statusColor = Colors.redAccent; statusText = "Dibatalkan"; break;
      default: statusColor = Colors.grey; statusText = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(
        children: [ 
          Stack(
            children: [
              ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: SizedBox(height: 140, width: double.infinity, child: _buildImage(imgUrl))),
              Positioned(top: 12, right: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]), child: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text(tanggal, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                Text("Total: $totalHarga", style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 15),
                
                // TOMBOL AKSI
                if (status.toLowerCase() == 'pending') 
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _cancelOrder(item['id']),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text("Batal", style: TextStyle(color: Colors.redAccent)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showPaymentOptions(item),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text("Bayar", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ])
                else if (status.toLowerCase() == 'selesai' || status.toLowerCase() == 'dibayar' || status.toLowerCase() == 'success')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _openReviewDialog(fasilitas != null ? fasilitas['id'] : 0),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: mainColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: Text("Beri Ulasan", style: TextStyle(color: mainColor)),
                    ),
                  )
                else if (status.toLowerCase() == 'menunggu')
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text("Menunggu Verifikasi Admin", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}