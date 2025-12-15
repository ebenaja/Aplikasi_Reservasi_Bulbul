import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bulbul_reservasi/services/reservasi_service.dart';
// Import screen instruksi
import 'package:bulbul_reservasi/screens/users/payment_instruction_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int fasilitasId;
  final String itemName;
  final double pricePerUnit;
  final String? imageUrl;
  final String? fasilitasImage; // Gambar fasilitas (opsional)

  const PaymentScreen({
    super.key,
    required this.fasilitasId,
    required this.itemName,
    required this.pricePerUnit,
    this.imageUrl,
    this.fasilitasImage,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ReservasiService _reservasiService = ReservasiService();
  final Color mainColor = const Color(0xFF50C2C9);

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  int _durasi = 1;
  bool _isLoading = false;

  // TOTAL
  double get _totalHarga => widget.pricePerUnit * _durasi;

  String formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final maxBookingWindow = now.add(const Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: maxBookingWindow,
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
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: mainColor)),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

Widget _buildHeaderImage() {
  final String img = widget.fasilitasImage?.trim() ?? "";

  // DEBUG (boleh hapus kalau sudah aman)
  debugPrint("PAYMENT IMAGE PATH: $img");

  // 1. Kosong → default
  if (img.isEmpty) {
    return Image.asset(
      'assets/images/pantai_landingscreens.jpg',
      fit: BoxFit.cover,
    );
  }

  // 2. URL dari backend
  if (img.startsWith('http')) {
    return Image.network(
      img,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, size: 60),
    );
  }

  // 3. Asset lokal
  if (img.startsWith('assets/')) {
    return Image.asset(
      img,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.image_not_supported, size: 60),
    );
  }

  // 4. Nama file dari DB → storage Laravel
  return Image.network(
    'http://10.0.2.2:8000/storage/$img',
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, size: 60),
  );
}

  // --- LOGIKA PEMBAYARAN DIPERBAIKI ---
  void _processPayment() async {
    setState(() => _isLoading = true);

    final String dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final String timeString = "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00";

    Map<String, dynamic> data = {
      'fasilitas_id': widget.fasilitasId,
      'tanggal_sewa': dateString,
      'jam_mulai': timeString,
      'durasi': _durasi,
      'total_harga': _totalHarga,
    };

    // 1. Panggil Service (Sekarang return Map, bukan bool)
    final result = await _reservasiService.createReservasi(data);

    setState(() => _isLoading = false);

    // 2. Cek Hasil
    if (result['success'] == true) {
      // Ambil ID Reservasi dari response backend
      // Pastikan backend mengirim struktur: { "data": { "id": 123, ... } }
      int newReservasiId = result['data']['id']; 

      if (mounted) {
        // 3. Navigasi ke Payment Instruction Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentInstructionScreen(
              totalHarga: _totalHarga,
              reservasiId: newReservasiId, // Kirim ID untuk keperluan upload bukti nanti
            ),
          ),
        );
      }
    } else {
      // Gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = DateFormat('d MMM yyyy', 'id_ID').format(_selectedDate);
    final displayTime = _selectedTime.format(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
      appBar: AppBar(
        title: const Text("Konfirmasi Pesanan", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Bagian UI Header Image & Info Item sama seperti sebelumnya) ...
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]),
              child: Column(
                children: [
                  ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: SizedBox(height: 180, width: double.infinity, child: _buildHeaderImage())),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text("Item yang disewa:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 5),
                      Text(widget.itemName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Divider(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("Harga per hari:", style: TextStyle(color: Colors.grey)),
                        Text(formatRupiah(widget.pricePerUnit), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainColor)),
                      ]),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            
            // ... (Bagian Input Tanggal, Jam, Durasi sama seperti sebelumnya) ...
            const Text("Jadwal Reservasi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: GestureDetector(onTap: () => _selectDate(context), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Tanggal", style: TextStyle(fontSize: 12, color: Colors.grey)), Text(displayDate, style: const TextStyle(fontWeight: FontWeight.bold))])))),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(onTap: () => _selectTime(context), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Jam", style: TextStyle(fontSize: 12, color: Colors.grey)), Text(displayTime, style: const TextStyle(fontWeight: FontWeight.bold))])))),
            ]),
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Durasi Sewa", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text("Maksimal 7 Hari", style: TextStyle(fontSize: 12, color: Colors.grey))]), Row(children: [IconButton(onPressed: () => setState(() { if (_durasi > 1) _durasi--; }), icon: const Icon(Icons.remove_circle, color: Colors.grey)), Text("$_durasi Hari", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), IconButton(onPressed: () => setState(() { if (_durasi < 7) _durasi++; }), icon: Icon(Icons.add_circle, color: _durasi >= 7 ? Colors.grey : mainColor))])])),

            const SizedBox(height: 40),

            // TOTAL & TOMBOL
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -2))]),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text("Total Pembayaran", style: TextStyle(fontSize: 16)),
                    Text(formatRupiah(_totalHarga), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: mainColor)),
                  ]),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processPayment, // Panggil fungsi baru
                      style: ElevatedButton.styleFrom(backgroundColor: mainColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Lanjut Pembayaran", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}