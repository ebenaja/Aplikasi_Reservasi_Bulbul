import 'package:flutter/material.dart';

class PemesananTab extends StatelessWidget {
  final Color mainColor = Color(0xFF50C2C9);
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
          SizedBox(height: 20),
          Text("Riwayat Pemesanan", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: mainColor)),
          Text("Belum ada riwayat transaksi", style: TextStyle(color: Colors.grey)),
        ]));
  }
}