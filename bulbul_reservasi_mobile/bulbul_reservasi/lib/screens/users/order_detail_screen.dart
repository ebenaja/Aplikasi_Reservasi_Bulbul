import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Import Service & Screen Lainnya
import 'package:bulbul_reservasi/services/reservasi_service.dart';
import 'package:bulbul_reservasi/screens/users/payment_instruction_screen.dart';
import 'package:bulbul_reservasi/screens/users/payment_success_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const OrderDetailScreen({super.key, required this.transaction});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final ReservasiService _reservasiService = ReservasiService();
  final Color mainColor = Color(0xFF50C2C9);
  
  // --- FUNGSI UPLOAD BUKTI (Sama dengan PemesananTab) ---
  void _uploadBuktiGambar(int reservasiId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    
    if (pickedFile != null) {
      if(mounted) {
        showDialog(context: context, barrierDismissible: false, builder: (ctx) => Center(child: CircularProgressIndicator(color: mainColor)));
      }

      bool success = await _reservasiService.uploadBukti(reservasiId, File(pickedFile.path));
      
      if(mounted) Navigator.pop(context); // Tutup Loading

      if (success) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PaymentSuccessScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal Upload Bukti. Cek koneksi."), backgroundColor: Colors.red));
      }
    }
  }

  // --- FUNGSI INPUT REFERENSI ---
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
            hintText: "Contoh: Transfer a.n Budi"
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () async {
              if (refController.text.isEmpty) return;
              Navigator.pop(context);
              
              showDialog(context: context, barrierDismissible: false, builder: (ctx) => Center(child: CircularProgressIndicator(color: mainColor)));
              bool success = await _reservasiService.konfirmasiManual(reservasiId, refController.text);
              Navigator.pop(context);

              if (success) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PaymentSuccessScreen()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengirim konfirmasi"), backgroundColor: Colors.red));
              }
            },
            child: const Text("Kirim", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- MODAL PILIHAN PEMBAYARAN ---
  void _showPaymentOptions() {
    int reservasiId = widget.transaction['id'];
    double totalHarga = double.tryParse(widget.transaction['total_harga'].toString()) ?? 0;

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
              const SizedBox(height: 25),
              
              _buildOptionTile(Icons.info_outline, "Lihat Instruksi Transfer", "Nomor Rekening & Cara Bayar", () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentInstructionScreen(totalHarga: totalHarga, reservasiId: reservasiId)));
              }),
              const SizedBox(height: 15),
              _buildOptionTile(Icons.cloud_upload_outlined, "Upload Bukti Foto", "Screenshot transfer / struk", () {
                Navigator.pop(context); 
                _uploadBuktiGambar(reservasiId);
              }),
              const SizedBox(height: 15),
              _buildOptionTile(Icons.edit, "Input No. Referensi", "Ketik manual nomor referensi", () {
                Navigator.pop(context); 
                _inputNomorReferensi(reservasiId);
              }),
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

  @override
  Widget build(BuildContext context) {
    final fasilitas = widget.transaction['fasilitas'] ?? {};
    final status = widget.transaction['status'] ?? 'pending';

    // Parsing Data
    double totalHarga = double.tryParse(widget.transaction['total_harga'].toString()) ?? 0;
    int durasi = int.tryParse(widget.transaction['durasi'].toString()) ?? 1;
    
    // Format Tanggal
    DateTime tglSewa;
    try {
       tglSewa = DateTime.parse(widget.transaction['tanggal_sewa']);
    } catch(e) {
       tglSewa = DateTime.now(); // Fallback
    }

    DateTime tglSelesai = tglSewa.add(Duration(days: durasi));
    String formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(tglSewa);
    String formattedEndDate = DateFormat('d MMMM yyyy', 'id_ID').format(tglSelesai);
    String jamMulai = widget.transaction['jam_mulai'] ?? '08:00';
    
    // Gambar
    String? imgUrl = fasilitas['foto'];

    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text("Detail Pesanan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. STATUS BANNER
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(_getStatusIcon(status), color: _getStatusColor(status)),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status Pesanan", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(status.toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _getStatusColor(status))),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),

            // 2. INFO FASILITAS
            Text("Fasilitas Dipesan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (imgUrl != null && imgUrl.isNotEmpty) 
                      ? (imgUrl.startsWith('http') 
                          ? Image.network(imgUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_,__,___)=>Icon(Icons.broken_image))
                          : Image.asset('assets/images/pantai_landingscreens.jpg', width: 80, height: 80, fit: BoxFit.cover)) // Fallback asset
                      : Image.asset('assets/images/pantai_landingscreens.jpg', width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fasilitas['nama_fasilitas'] ?? 'Nama Tidak Ada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text("Pantai Bulbul, Balige", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: 20),

            // 3. DETAIL WAKTU (CHECK-IN / OUT)
            Text("Rincian Jadwal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  _buildRowInfo("Tanggal Check-in", formattedDate),
                  Divider(),
                  _buildRowInfo("Jam Kedatangan", jamMulai),
                  Divider(),
                  _buildRowInfo("Durasi Sewa", "$durasi Hari"),
                  Divider(),
                  _buildRowInfo("Perkiraan Selesai", formattedEndDate),
                ],
              ),
            ),

            SizedBox(height: 20),

            // 4. RINCIAN PEMBAYARAN
            Text("Rincian Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  _buildRowInfo("Harga Sewa", "Rp ${NumberFormat('#,###', 'id_ID').format(totalHarga)}"),
                  SizedBox(height: 10),
                  _buildRowInfo("Biaya Layanan", "Rp 0"),
                  Divider(thickness: 1, height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Bayar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("Rp ${NumberFormat('#,###', 'id_ID').format(totalHarga)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainColor)),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
      
      // 5. TOMBOL AKSI DI BAWAH
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: status == 'pending' 
          ? ElevatedButton(
              onPressed: () => _showPaymentOptions(), // PANGGIL MODAL PEMBAYARAN
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Bayar Sekarang", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            )
          : OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text("Tutup", style: TextStyle(color: Colors.black87)),
            ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildRowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'menunggu': return Colors.blue; 
      case 'dibayar': case 'selesai': return Colors.green;
      case 'batal': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.access_time_filled;
      case 'menunggu': return Icons.hourglass_top;
      case 'dibayar': return Icons.check_circle;
      case 'batal': return Icons.cancel;
      default: return Icons.info;
    }
  }
}