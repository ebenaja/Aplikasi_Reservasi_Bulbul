import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/payment_screen.dart'; // Kita buat ini di langkah 2

class CategoryListScreen extends StatelessWidget {
  final String categoryName;
  final Color mainColor = Color(0xFF50C2C9);

  CategoryListScreen({required this.categoryName});

  // Data Dummy (Biasanya dari API)
  final List<Map<String, dynamic>> _items = [
    {
      "title": "VIP A",
      "price": "Rp 250.000",
      "image": "assets/images/pantai_landingscreens.jpg",
      "rating": 4.8
    },
    {
      "title": "VIP B",
      "price": "Rp 300.000",
      "image": "assets/images/pantai_landingscreens.jpg",
      "rating": 4.9
    },
    {
      "title": "Reguler 1",
      "price": "Rp 150.000",
      "image": "assets/images/pantai_landingscreens.jpg",
      "rating": 4.5
    },
    {
      "title": "Reguler 2",
      "price": "Rp 150.000",
      "image": "assets/images/pantai_landingscreens.jpg",
      "rating": 4.4
    },
  ];

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
        title: Text("Daftar $categoryName", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return _buildItemCard(context, item);
          },
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                item['image'],
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$categoryName ${item['title']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    Text("${item['rating']}", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 8),
                Text(item['price'], style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigasi ke Halaman Pembayaran
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(itemName: "$categoryName ${item['title']}", price: item['price'])
                        )
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text("Pesan", style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}