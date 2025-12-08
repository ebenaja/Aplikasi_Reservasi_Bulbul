import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bulbul_reservasi/services/reservasi_service.dart';
import 'package:bulbul_reservasi/screens/users/add_review_dialog.dart';
import 'package:bulbul_reservasi/screens/users/order_detail_screen.dart'; 
import 'package:bulbul_reservasi/screens/users/payment_instruction_screen.dart';
import 'package:bulbul_reservasi/screens/users/payment_success_screen.dart'; 

class PemesananTab extends StatefulWidget {
  const PemesananTab({super.key});

  @override
  _PemesananTabState createState() => _PemesananTabState();
}

class _PemesananTabState extends State<PemesananTab> {
  final ReservasiService _reservasiService = ReservasiService();
  final Color mainColor = const Color(0xFF50C2C9);
  
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

  void _fetchHistory() async {
    if (mounted) setState(() => _isLoading = true);
    
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
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (e) { return dateStr; }
  }

  // --- NAVIGASI SUKSES ---
  void _navigateToSuccess() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
    );
  }

  // --- UPLOAD BUKTI (AMAN DARI CRASH) ---
  void _uploadBuktiGambar(int reservasiId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 40); // Kompresi biar cepat
    
    if (pickedFile != null) {
      // Tampilkan notifikasi kecil saja (bukan dialog yang memblokir layar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sedang mengupload..."), duration: Duration(seconds: 1))
      );

      // Proses Upload
      bool success = await _reservasiService.uploadBukti(reservasiId, File(pickedFile.path));
      
      // PERBAIKAN: Cek mounted sebelum navigasi
      if (!mounted) return; 

      if (success) {
        _navigateToSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal Upload. Cek koneksi."), backgroundColor: Colors.red)
        );
      }
    }
  }

  // --- INPUT REFERENSI (AMAN DARI CRASH) ---
  void _inputNomorReferensi(int reservasiId) {
    TextEditingController refController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Pembayaran"),
        content: TextField(
          controller: refController,
          decoration: InputDecoration(
            labelText: "No. Referensi / Catatan",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: "Contoh: Sudah transfer a.n Budi"
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () async {
              if (refController.text.isEmpty) return;
              
              // 1. Tutup Dialog Input SEGERA
              Navigator.pop(context); 

              // 2. Beri Feedback SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Mengirim konfirmasi..."), duration: Duration(seconds: 1))
              );

              // 3. Kirim ke Server
              bool success = await _reservasiService.konfirmasiPembayaran(reservasiId, refController.text);
              
              // 4. PERBAIKAN UTAMA: Cek mounted sebelum navigasi lagi
              if (!mounted) return; 

              if (success) {
                _navigateToSuccess();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Gagal mengirim konfirmasi"), backgroundColor: Colors.red)
                );
              }
            },
            child: const Text("Kirim", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- BATALKAN PESANAN ---
  void _cancelOrder(int reservasiId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Pesanan?"),
        content: const Text("Yakin ingin membatalkan pesanan ini?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Tidak")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Memproses pembatalan...")));
      
      bool success = await _reservasiService.cancelReservasi(reservasiId);
      
      if (!mounted) return;

      if (success) {
        _fetchHistory(); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pesanan dibatalkan"), backgroundColor: Colors.red));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membatalkan pesanan"), backgroundColor: Colors.black));
      }
    }
  }

  void _showPaymentOptions(Map<String, dynamic> item) {
    int reservasiId = item['id'];
    double totalHarga = double.tryParse(item['total_harga'].toString()) ?? 0;

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
              const Text("Metode Konfirmasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 10),
              const Text("Pilih langkah yang ingin Anda lakukan:", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),
              
              _buildOptionTile(
                Icons.info_outline, "Lihat Instruksi Transfer", "Nomor Rekening & Cara Bayar", 
                () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentInstructionScreen(totalHarga: totalHarga, reservasiId: reservasiId)));
                }
              ),
              const SizedBox(height: 15),
              _buildOptionTile(
                Icons.cloud_upload_outlined, "Upload Bukti Foto", "Screenshot transfer / struk", 
                () {
                  Navigator.pop(context); 
                  _uploadBuktiGambar(reservasiId);
                }
              ),
              const SizedBox(height: 15),
               _buildOptionTile(
                Icons.edit, "Input No. Referensi", "Input manual jika gagal upload", 
                () {
                  Navigator.pop(context); 
                  _inputNomorReferensi(reservasiId);
                }
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(IconData icon, String title, String sub, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: mainColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: mainColor)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12))])), Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300])]),
      ),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text("Riwayat Pesanan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: mainColor, elevation: 0, centerTitle: true, automaticallyImplyLeading: false),
      body: Column(
        children: [
          Container(
            width: double.infinity, color: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _filters.map((filter) {
                  bool isSelected = _selectedFilter == filter;
                  return GestureDetector(onTap: () { setState(() { _selectedFilter = filter; _filterData(); }); }, child: AnimatedContainer(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: isSelected ? mainColor : Colors.grey[100], borderRadius: BorderRadius.circular(30), boxShadow: isSelected ? [BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : []), child: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 13))));
                }).toList())),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: mainColor))
                : _filteredList.isEmpty
                    ? Center(child: Text("Tidak ada pesanan $_selectedFilter", style: TextStyle(color: Colors.grey[600])))
                    : RefreshIndicator(
                        onRefresh: () async => _fetchHistory(),
                        color: mainColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          itemCount: _filteredList.length,
                          itemBuilder: (context, index) => _buildHistoryCard(_filteredList[index]),
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
    final tanggal = formatDate(item['created_at']);
    final String? imgUrl = fasilitas != null ? fasilitas['foto'] : null;
    final String title = fasilitas != null ? fasilitas['nama_fasilitas'] : 'Item Dihapus';

    Color statusColor;
    String statusText;
    switch (status.toLowerCase()) {
      case 'selesai': statusColor = Colors.green; statusText = "Selesai"; break;
      case 'menunggu': statusColor = Colors.blueAccent; statusText = "Verifikasi"; break;
      case 'pending': statusColor = Colors.orange; statusText = "Bayar"; break;
      case 'batal': case 'cancelled': statusColor = Colors.redAccent; statusText = "Batal"; break;
      default: statusColor = Colors.grey; statusText = status;
    }

    return GestureDetector(
      onTap: () {
         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderDetailScreen(transaction: item)),
        );
      },
      child: Container(
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text("Tgl: $tanggal", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(totalHarga, style: TextStyle(color: mainColor, fontWeight: FontWeight.w900, fontSize: 16)),
                      
                      if (status == 'pending') 
                        Row(children: [
                          OutlinedButton(
                            onPressed: () => _cancelOrder(item['id']),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              minimumSize: const Size(60, 30),
                              padding: const EdgeInsets.symmetric(horizontal: 10)
                            ),
                            child: const Text("Batal", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _showPaymentOptions(item),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            child: const Text("Bayar", style: TextStyle(color: Colors.white)),
                          ),
                        ])
                      else if (status == 'selesai')
                        OutlinedButton(
                          onPressed: () => _openReviewDialog(fasilitas != null ? fasilitas['id'] : 0),
                          child: const Text("Ulas"),
                        )
                       else if (status == 'menunggu')
                        const Text("Diproses Admin", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))
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
}