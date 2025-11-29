import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bulbul_reservasi/screens/users/home_screen.dart';

class PaymentInstructionScreen extends StatelessWidget {
  final double totalHarga;
  const PaymentInstructionScreen({super.key, required this.totalHarga});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF50C2C9);
    final Color secondaryColor = const Color(0xFF2E8B91);
    final String vaNumber = "889082283929112";

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Instruksi Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [mainColor, secondaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight))),
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // KARTU INSTRUKSI (TICKET STYLE)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: Offset(0, 10))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(color: mainColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.account_balance_wallet_rounded, size: 40, color: mainColor),
                  ),
                  SizedBox(height: 20),
                  Text("Total Pembayaran", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  SizedBox(height: 5),
                  Text(
                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(totalHarga),
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                  SizedBox(height: 30),
                  Divider(color: Colors.grey[200], thickness: 1.5),
                  SizedBox(height: 30),
                  
                  // VA Section
                  Align(alignment: Alignment.centerLeft, child: Text("Transfer Bank (Virtual Account)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87))),
                  SizedBox(height: 15),
                  
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[50], 
                      borderRadius: BorderRadius.circular(16), 
                      border: Border.all(color: Colors.grey[200]!)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Bank Mandiri", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            SizedBox(height: 4),
                            Text(vaNumber, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black87)),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.content_copy_rounded, color: mainColor),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: vaNumber));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nomor VA disalin!"), backgroundColor: Colors.green));
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey),
                      SizedBox(width: 5),
                      Text("Bayar sebelum 24 jam.", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Spacer(),
            
            // TOMBOL CEK STATUS
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen(initialIndex: 2)), (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: mainColor.withOpacity(0.4)
                ),
                child: Text("Cek Status Pesanan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}