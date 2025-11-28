import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bulbul_reservasi/screens/users/home_screen.dart';

class PaymentInstructionScreen extends StatelessWidget {
  final double totalHarga;
  const PaymentInstructionScreen({super.key, required this.totalHarga});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = Color(0xFF50C2C9);
    final String vaNumber = "889082283929112";

    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      appBar: AppBar(
        title: Text("Rincian Pembayaran", style: TextStyle(fontFamily: "Serif", fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24)),
        centerTitle: true,
        backgroundColor: mainColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Kembali ke Home jika user ingin batal/keluar
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (_) => HomeScreen()), 
              (route) => false
            );
          },
        ),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(25),
          width: double.infinity,
          height: 450, // Tinggi kartu putih
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Pembayaran
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 16)),
                  Text(
                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(totalHarga),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Divider(thickness: 1.5),
              SizedBox(height: 20),

              // Info Bank
              Text("Bank Mandiri (Virtual Account)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])),
              SizedBox(height: 5),
              Text("No. Rek/Virtual Account", style: TextStyle(color: Colors.grey)),
              
              SizedBox(height: 15),
              
              // Nomor VA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vaNumber,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey[800]),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: vaNumber));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nomor disalin!")));
                    },
                    child: Text("Salin", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                  )
                ],
              ),

              Spacer(), // Dorong tombol ke bawah

              // Tombol Pesan Sekarang (Konfirmasi Selesai)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Setelah user melihat instruksi, kembalikan ke Home (Tab Pemesanan)
                    // Di sana nanti user bisa Upload Bukti jika mau
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                      (route) => false,
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Pesanan tersimpan. Silakan lakukan pembayaran."), backgroundColor: mainColor)
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text("Pesan Sekarang", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}