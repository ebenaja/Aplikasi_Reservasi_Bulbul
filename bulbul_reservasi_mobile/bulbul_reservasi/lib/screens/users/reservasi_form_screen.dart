import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bulbul_reservasi/services/reservasi_service.dart';
import 'package:bulbul_reservasi/screens/users/home_screen.dart'; 

class ReservasiFormScreen extends StatefulWidget {
  final int fasilitasId;
  final String itemName;
  final double pricePerUnit;
  final String? imagePath;

  const ReservasiFormScreen({
    super.key,
    required this.fasilitasId,
    required this.itemName,
    required this.pricePerUnit,
    this.imagePath,
  });

  @override
  State<ReservasiFormScreen> createState() => _ReservasiFormScreenState();
}

class _ReservasiFormScreenState extends State<ReservasiFormScreen> {
  final ReservasiService _reservasiService = ReservasiService();
  
  // Palette Warna
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  final Color bgPage = const Color(0xFFF5F7FA);

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _durasi = 1;
  bool _isLoading = false;

  double get _totalHarga => widget.pricePerUnit * _durasi;

  // Format Rupiah
  String formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  // Fungsi Pilih Tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)), // Bisa pesan sampai 30 hari ke depan
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: mainColor, onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // Fungsi Pilih Jam
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
         return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: mainColor, onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      }
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submitReservasi() async {
    setState(() => _isLoading = true);

    String dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    // Format Jam: 14:30
    String timeString = "${_selectedTime.hour.toString().padLeft(2,'0')}:${_selectedTime.minute.toString().padLeft(2,'0')}";

    Map<String, dynamic> data = {
      'fasilitas_id': widget.fasilitasId,
      'tanggal_sewa': dateString,
      'jam_mulai': timeString,
      'durasi': _durasi,
      'total_harga': _totalHarga,
    };

    bool success = await _reservasiService.createReservasi(data);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        // Dialog Sukses Modern
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 50),
                ),
                SizedBox(height: 20),
                Text("Berhasil Dipesan!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Pesanan Anda telah dibuat. Silakan cek menu Pemesanan untuk melakukan pembayaran.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 12)
                    ),
                    onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: 2)), (route) => false),
                    child: Text("Cek Pesanan Saya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal Reservasi. Stok mungkin habis."), backgroundColor: Colors.red)
        );
      }
    }
  }

  // Helper Image Builder
  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover);
    } else if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.grey));
    } else if (path.startsWith('assets')) {
      return Image.asset(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.image_not_supported, color: Colors.grey));
    } else {
      return Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      
      // 1. HEADER GRADIENT
      appBar: AppBar(
        title: Text("Form Reservasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [mainColor, secondaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      
      // 2. BOTTOM BAR (HARGA & TOMBOL)
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))],
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Estimasi", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text(
                  formatRupiah(_totalHarga), 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: mainColor)
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitReservasi,
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                shadowColor: mainColor.withOpacity(0.4)
              ),
              child: _isLoading 
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : Text("Buat Pesanan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            )
          ],
        ),
      ),
      
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. CARD FASILITAS UTAMA
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: _buildImage(widget.imagePath),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.itemName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text("Pantai Bulbul, Balige", style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                        SizedBox(height: 15),
                        Text(
                          "${formatRupiah(widget.pricePerUnit)} / unit", 
                          style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
            Text("Detail Waktu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 15),

            // 4. INPUT TANGGAL & WAKTU (Split Row)
            Row(
              children: [
                Expanded(
                  child: _buildSelectionCard(
                    "Tanggal Mulai", 
                    DateFormat('dd MMM yyyy').format(_selectedDate), 
                    Icons.calendar_month_rounded, 
                    () => _selectDate(context)
                  )
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildSelectionCard(
                    "Jam Mulai", 
                    _selectedTime.format(context), 
                    Icons.access_time_rounded, 
                    () => _selectTime(context)
                  )
                ),
              ],
            ),

            SizedBox(height: 15),

            // 5. INPUT DURASI (Full Width)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Durasi Sewa", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text("$_durasi Hari/Jam", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCircleBtn(Icons.remove, () { if (_durasi > 1) setState(() => _durasi--); }),
                      SizedBox(width: 20),
                      Text("$_durasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 20),
                      _buildCircleBtn(Icons.add, () { setState(() => _durasi++); }),
                    ],
                  )
                ],
              ),
            ),
            
            SizedBox(height: 30), // Spasi bawah
          ],
        ),
      ),
    );
  }

  // Widget Helper: Kartu Pilihan (Tanggal/Waktu)
  Widget _buildSelectionCard(String title, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: mainColor, size: 20),
                SizedBox(width: 8),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget Helper: Tombol +/-
  Widget _buildCircleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: mainColor.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: mainColor.withOpacity(0.2))
        ),
        child: Icon(icon, color: mainColor, size: 20),
      )
    );
  }
}