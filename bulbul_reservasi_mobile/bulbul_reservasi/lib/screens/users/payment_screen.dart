import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bulbul_reservasi/services/reservasi_service.dart';

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

  // Fungsi Format Rupiah
  String formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    ).format(amount);
  }

  // Fungsi Pilih Tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030), // Bisa booking sampai tahun 2030
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: mainColor, // Warna header datepicker
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
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

  // PROSES RESERVASI KE LARAVEL
  void _processPayment() async {
    setState(() => _isLoading = true);

    // 1. Format Tanggal (yyyy-MM-dd)
    String dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // 2. Siapkan Data
    Map<String, dynamic> data = {
      'fasilitas_id': widget.fasilitasId,
      'tanggal_sewa': dateString,
      'durasi': _durasi,
      'total_harga': _totalHarga,
    };

    // 3. Kirim ke Service
    bool success = await _reservasiService.createReservasi(data);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Reservasi Berhasil! Silakan cek riwayat."), 
            backgroundColor: Colors.green
          )
        );
        Navigator.pop(context); // Kembali ke Home/List
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal membuat reservasi. Cek koneksi atau login ulang."), 
            backgroundColor: Colors.red
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format Tampilan Tanggal
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
            // CARD ITEM
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Item yang disewa:", style: TextStyle(color: Colors.grey)),
                  Text(widget.itemName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Harga per unit/hari:", style: TextStyle(color: Colors.grey)),
                      Text(
                        formatRupiah(widget.pricePerUnit), 
                        style: TextStyle(fontSize: 16, color: mainColor, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 25),
            
            // INPUT TANGGAL
            Text("Tanggal Sewa", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(displayDate, style: TextStyle(fontSize: 16)),
                    Icon(Icons.calendar_today, color: mainColor),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // INPUT DURASI
            Text("Durasi Sewa (Hari/Jam)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Lama Sewa", style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_durasi > 1) setState(() => _durasi--);
                        },
                        icon: Icon(Icons.remove_circle_outline, color: Colors.grey),
                      ),
                      Text("$_durasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () {
                          setState(() => _durasi++);
                        },
                        icon: Icon(Icons.add_circle, color: mainColor),
                      ),
                    ],
                  )
                ],
              ),
            ),

            SizedBox(height: 30),

            // TOTAL & TOMBOL
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Bayar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        formatRupiah(_totalHarga), 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainColor)
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                      ),
                      child: _isLoading 
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Buat Pesanan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}