import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const OrderDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final fasilitas = transaction['fasilitas'] ?? {};
    final status = transaction['status'] ?? 'pending';
    final Color mainColor = Color(0xFF50C2C9);

    // Parsing Data
    double totalHarga = double.tryParse(transaction['total_harga'].toString()) ?? 0;
    int durasi = int.tryParse(transaction['durasi'].toString()) ?? 1;
    
    // Format Tanggal
    DateTime tglSewa = DateTime.parse(transaction['tanggal_sewa']);
    DateTime tglSelesai = tglSewa.add(Duration(days: durasi));
    String formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(tglSewa);
    String formattedEndDate = DateFormat('d MMMM yyyy', 'id_ID').format(tglSelesai);
    String jamMulai = transaction['jam_mulai'] ?? '08:00';

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
                    child: Image.asset(
                      'assets/images/pantai_landingscreens.jpg', // Ganti dengan fasilitas['foto'] jika sudah ada
                      width: 80, height: 80, fit: BoxFit.cover,
                    ),
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
              onPressed: () {
                // Arahkan ke Upload Bukti atau Payment Gateway
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fitur Bayar Lanjutan...")));
              },
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
      case 'menunggu': return Colors.blue; // Menunggu konfirmasi admin
      case 'dibayar': return Colors.green;
      case 'selesai': return Colors.teal;
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