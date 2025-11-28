import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bulbul_reservasi/services/reservasi_service.dart';
import 'package:bulbul_reservasi/screens/users/payment_instruction_screen.dart'; // IMPORT INI

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
  final Color mainColor = Color(0xFF50C2C9);

  DateTime _selectedDate = DateTime.now();
  int _durasi = 1;
  bool _isLoading = false;

  // Hitung Total
  double get _totalHarga => widget.pricePerUnit * _durasi;

  // Format Rupiah
  String formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: mainColor, onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
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
    };

    // SIMPAN KE DATABASE (Status: Pending)
    bool success = await _reservasiService.createReservasi(data);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        // LANGSUNG PINDAH KE HALAMAN INSTRUKSI SEPERTI GAMBAR
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentInstructionScreen(
              totalHarga: _totalHarga,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membuat pesanan."), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate);

    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      appBar: AppBar(
        title: Text("Detail Reservasi", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: mainColor, 
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TAMPILAN ITEM (Sesuai Gambar Pertama Anda)
            Text(widget.itemName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 15),
            
            // GAMBAR ITEM
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/pantai_landingscreens.jpg', // Placeholder
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            SizedBox(height: 25),

            // INPUT TANGGAL (Model Radio Button Sederhana)
            Text("Tanggal Sewa:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(displayDate, style: TextStyle(fontSize: 16)),
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: mainColor),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // DURASI
            Text("Durasi Sewa (Hari/Jam)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () { if (_durasi > 1) setState(() => _durasi--); },
                    icon: Icon(Icons.remove_circle_outline, color: Colors.grey),
                  ),
                  Text("$_durasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () { setState(() => _durasi++); },
                    icon: Icon(Icons.add_circle, color: mainColor),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // TOTAL BAYAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(formatRupiah(_totalHarga), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainColor)),
              ],
            ),

            SizedBox(height: 30),

            // TOMBOL PESAN SEKARANG
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(backgroundColor: mainColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: _isLoading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Pesan Sekarang", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}