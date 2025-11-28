import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/users/home_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = Color(0xFF50C2C9);

    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Centang
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 4),
                  color: mainColor,
                ),
                child: Icon(Icons.check, size: 50, color: Colors.black),
              ),
              SizedBox(height: 20),
              
              Text(
                "Pemesanan Berhasil",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              
              SizedBox(height: 50),

              // Tombol Aksi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    // Tombol Kembali
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Kembali ke Home (Beranda)
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text("Kembali"),
                      ),
                    ),
                    SizedBox(width: 15),
                    // Tombol Lihat Pesanan
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Kembali ke Home tapi langsung ke Tab Pemesanan (Index 2)
                          // Kita perlu modifikasi HomeScreen sedikit agar bisa menerima index awal, 
                          // tapi untuk simplenya kita push ke Home dulu.
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()), // Nanti user klik manual tab pemesanan
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text("Lihat Pesanan"),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}