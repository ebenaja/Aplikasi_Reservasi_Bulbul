import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/users/home_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF50C2C9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Centang Animasi
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded, size: 80, color: mainColor),
              ),
              SizedBox(height: 30),
              
              Text("Pemesanan Berhasil!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 10),
              Text("Terima kasih telah memesan. Silakan cek status pesanan Anda.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              
              SizedBox(height: 50),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),
                      child: Text("Kembali ke Beranda", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: 2)), (route) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0
                  ),
                  child: Text("Lihat Pesanan Saya", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}