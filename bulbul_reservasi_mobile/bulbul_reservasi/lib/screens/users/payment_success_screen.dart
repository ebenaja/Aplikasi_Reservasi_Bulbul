import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/users/home_screen.dart'; // Import HomeScreen User

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
              Icon(Icons.check_circle_rounded, size: 100, color: Colors.green),
              const SizedBox(height: 30),
              
              const Text("Pembayaran Terkirim!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),
              Text("Admin akan memverifikasi bukti pembayaran Anda.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              
              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Kembali ke Home dan Hapus semua rute
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (_) => const HomeScreen()), 
                      (route) => false
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Kembali ke Beranda", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}