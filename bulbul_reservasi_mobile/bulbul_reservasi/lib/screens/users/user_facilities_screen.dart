import 'package:bulbul_reservasi/screens/users/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/facility_service.dart'; 

class UserFacilitiesScreen extends StatefulWidget {
  final String category; // "Pondok", "Tenda", "Homestay", "Wahana"
  const UserFacilitiesScreen({super.key, required this.category});

  @override
  State<UserFacilitiesScreen> createState() => _UserFacilitiesScreenState();
}

class _UserFacilitiesScreenState extends State<UserFacilitiesScreen> {
  final FacilityService _facilityService = FacilityService();
  final Color mainColor = Color(0xFF50C2C9);
  
  List<dynamic> _facilities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFacilities();
  }

  void _fetchFacilities() async {
    try {
      final data = await _facilityService.getFacilities();
      
      if (mounted) {
        setState(() {
          // Filter data dari API berdasarkan kategori yang dipilih di Home
          // Logika: Mencari apakah nama fasilitas mengandung kata kategori (misal: "Pondok Indah" mengandung "Pondok")
          _facilities = data.where((item) {
            String nama = item['nama_fasilitas'].toString().toLowerCase();
            String kategori = widget.category.toLowerCase();
            return nama.contains(kategori);
          }).toList();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching facilities: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      appBar: AppBar(
        title: Text(widget.category, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: mainColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _facilities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("Belum ada data ${widget.category}", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _facilities.length,
                  itemBuilder: (context, index) {
                    final item = _facilities[index];
                    return _buildFacilityCard(item);
                  },
                ),
    );
  }

  Widget _buildFacilityCard(Map<String, dynamic> item) {
    // Parsing Data dengan aman
    String nama = item['nama_fasilitas'] ?? 'Tanpa Nama';
    String hargaDisplay = "Rp ${item['harga']}";
    double hargaDouble = double.tryParse(item['harga'].toString()) ?? 0.0;
    int id = item['id'];
    String status = item['status'] ?? 'tersedia';
    bool isAvailable = status == 'tersedia';
    
    // Gambar dari DB atau Default
    String? fotoUrl = item['foto'];

    return GestureDetector(
      onTap: isAvailable ? () {
        _goToPayment(id, nama, hargaDouble);
      } : null,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR ---
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[200],
                child: (fotoUrl != null && fotoUrl.isNotEmpty)
                    ? Image.network(
                        fotoUrl, // Jika backend kirim URL lengkap
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover),
                      )
                    : Image.asset(
                        'assets/images/pantai_landingscreens.jpg', // Gambar Default
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            
            // --- KONTEN TEKS ---
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(nama, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      ),
                      // Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: isAvailable ? Colors.green : Colors.red
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(item['deskripsi'] ?? "Fasilitas nyaman di Pantai Bulbul", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  SizedBox(height: 10),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(hargaDisplay, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainColor)),
                      
                      ElevatedButton(
                        onPressed: isAvailable ? () {
                          _goToPayment(id, nama, hargaDouble);
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable ? mainColor : Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: Text(isAvailable ? "Pesan" : "Penuh", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToPayment(int id, String name, double price) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          fasilitasId: id,   // Gunakan variabel 'id' dari parameter
          itemName: name,    // Gunakan variabel 'name' dari parameter
          pricePerUnit: price, // Gunakan variabel 'price' dari parameter
        ),
      ),
    );
  }
}