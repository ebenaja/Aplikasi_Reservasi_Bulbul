import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final String itemName;
  final String price;
  final Color mainColor = Color(0xFF50C2C9);

  PaymentScreen({required this.itemName, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Pembayaran", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Detail Item
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    height: 60, width: 60,
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.shopping_bag, color: mainColor, size: 30),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(itemName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Total: $price", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  )
                ],
              ),
            ),
            
            SizedBox(height: 25),
            Text("Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            
            _buildPaymentMethod("Transfer Bank (BCA, Mandiri)", Icons.account_balance),
            SizedBox(height: 10),
            _buildPaymentMethod("E-Wallet (DANA, OVO)", Icons.account_balance_wallet),
            SizedBox(height: 10),
            _buildPaymentMethod("QRIS", Icons.qr_code),

            SizedBox(height: 25),
            Text("Upload Bukti Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Ketuk untuk upload gambar", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Pembayaran Berhasil Dikirim!"), backgroundColor: Colors.green)
                  );
                  Navigator.pop(context); // Kembali
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text("Konfirmasi Pembayaran", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          SizedBox(width: 15),
          Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
          Spacer(),
          Radio(value: false, groupValue: true, onChanged: (val){}, activeColor: mainColor),
        ],
      ),
    );
  }
}