import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bulbul_reservasi/services/reservasi_service.dart';
import 'package:bulbul_reservasi/screens/users/payment_instruction_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int fasilitasId;
  final String itemName;
  final double pricePerUnit;

  const PaymentScreen({
    super.key, 
    required this.fasilitasId, 
    required this.itemName, 
    required this.pricePerUnit
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ReservasiService _reservasiService = ReservasiService();
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);

  // REVISI: Default tanggal BESOK
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _durasi = 1;
  bool _isLoading = false;

  double get _totalHarga => widget.pricePerUnit * _durasi;

  String formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(tomorrow) ? tomorrow : _selectedDate,
      // REVISI: Batas awal tanggal adalah BESOK
      firstDate: tomorrow, 
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: mainColor, onPrimary: Colors.white, onSurface: Colors.black)),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _processPayment() async {
    setState(() => _isLoading = true);
    
    String dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    Map<String, dynamic> data = {
      'fasilitas_id': widget.fasilitasId,
      'tanggal_sewa': dateString,
      'durasi': _durasi,
      'total_harga': _totalHarga,
      'jam_mulai': '08:00:00' // Default jam
    };

    // Panggil Service Baru (return Map)
    final result = await _reservasiService.createReservasi(data);
    
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        // SUKSES: Pindah ke Instruksi
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(
            builder: (context) => PaymentInstructionScreen(
              totalHarga: _totalHarga,
              // Kirim ID reservasi agar nanti bisa dipakai upload bukti (opsional)
              reservasiId: result['data']['id'] 
            )
          )
        );
      }
    } else {
      // GAGAL: Tampilkan Pesan Error (Misal Stok Habis)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']), // Pesan dari Laravel
            backgroundColor: Colors.red
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate);

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Konfirmasi Pesanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [mainColor, secondaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight))),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE & TITLE CARD
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.asset('assets/images/pantai_landingscreens.jpg', height: 180, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.itemName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        SizedBox(height: 5),
                        Text("Pantai Bulbul, Balige", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 25),
            Text("Detail Reservasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),

            // DATE PICKER
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
                child: Row(
                  children: [
                    Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: mainColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.calendar_today_rounded, color: mainColor, size: 20)),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tanggal Sewa (Mulai Besok)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        SizedBox(height: 2),
                        Text(displayDate, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey)
                  ],
                ),
              ),
            ),

            SizedBox(height: 15),

            // DURATION PICKER
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Durasi", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text("$_durasi Hari", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCircleBtn(Icons.remove, () { if (_durasi > 1) setState(() => _durasi--); }),
                      SizedBox(width: 15),
                      Text("$_durasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 15),
                      _buildCircleBtn(Icons.add, () { setState(() => _durasi++); }),
                    ],
                  )
                ],
              ),
            ),

            SizedBox(height: 30),

            // TOTAL & BUTTON
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -2))]),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Pembayaran", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      Text(formatRupiah(_totalHarga), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: mainColor)),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processPayment,
                      style: ElevatedButton.styleFrom(backgroundColor: mainColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5, shadowColor: mainColor.withOpacity(0.4)),
                      child: _isLoading 
                        ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Lanjut Pembayaran", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[300]!), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.grey[700], size: 20),
      ),
    );
  }
}