import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bulbul_reservasi/services/facility_service.dart';
import 'package:bulbul_reservasi/screens/users/payment_screen.dart';

class UserFacilitiesScreen extends StatefulWidget {
  final String category; // "Pondok", "Tenda", "Homestay", "Wahana", "Semua"
  const UserFacilitiesScreen({super.key, required this.category});

  @override
  State<UserFacilitiesScreen> createState() => _UserFacilitiesScreenState();
}

class _UserFacilitiesScreenState extends State<UserFacilitiesScreen> {
  final FacilityService _facilityService = FacilityService();
  
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  final Color bgPage = const Color(0xFFF5F7FA);

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
          // LOGIKA FILTER
          if (widget.category == "Semua" || widget.category == "Semua Fasilitas") {
            _facilities = data;
          } else {
            // Filter berdasarkan nama yang mengandung kategori
            _facilities = data.where((item) {
              String nama = item['nama_fasilitas'].toString().toLowerCase();
              String kategori = widget.category.toLowerCase();
              return nama.contains(kategori);
            }).toList();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching facilities: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String formatRupiah(var price) {
    double priceDouble = double.tryParse(price.toString()) ?? 0.0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(priceDouble);
  }

  // Helper Gambar
  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover);
    } 
    // Hapus spasi jika ada
    String cleanPath = path.trim();

    if (cleanPath.startsWith('http')) {
      return Image.network(cleanPath, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.grey));
    } else {
      return Image.asset(cleanPath, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.image_not_supported, color: Colors.grey));
    }
  }

  // NAVIGASI KE PAYMENT SCREEN (DENGAN GAMBAR)
  void _goToPayment(int id, String name, double price, String? imgUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          fasilitasId: id,
          itemName: name,
          pricePerUnit: price,
          fasilitasImage: imgUrl, // PERBAIKAN: Gunakan parameter 'fasilitasImage'
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      
      // HEADER GRADIENT
      appBar: AppBar(
        title: Text(widget.category, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _facilities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
                      SizedBox(height: 15),
                      Text("Tidak ada fasilitas ${widget.category}", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: _facilities.length,
                  itemBuilder: (context, index) {
                    final item = _facilities[index];
                    return _buildFacilityCard(item);
                  },
                ),
    );
  }

  Widget _buildFacilityCard(Map<String, dynamic> item) {
    String nama = item['nama_fasilitas'] ?? 'Tanpa Nama';
    String hargaDisplay = formatRupiah(item['harga']);
    double hargaDouble = double.tryParse(item['harga'].toString()) ?? 0.0;
    int id = item['id'];
    String status = item['status'] ?? 'tersedia';
    bool isAvailable = status.toLowerCase() == 'tersedia';
    String? fotoUrl = item['foto']; // Ambil path foto

    return GestureDetector(
      onTap: isAvailable ? () {
        _goToPayment(id, nama, hargaDouble, fotoUrl); 
      } : null,
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: _buildImage(fotoUrl), // Panggil helper gambar
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                    ),
                    child: Text(
                      isAvailable ? "Tersedia" : "Penuh",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text("Pantai Bulbul", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                  SizedBox(height: 15),
                  Divider(height: 1, color: Colors.grey[200]),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(hargaDisplay, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: mainColor)),
                      ElevatedButton(
                        onPressed: isAvailable ? () {
                          _goToPayment(id, nama, hargaDouble, fotoUrl);
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable ? mainColor : Colors.grey[300],
                          foregroundColor: isAvailable ? Colors.white : Colors.grey[500],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          elevation: isAvailable ? 2 : 0,
                        ),
                        child: Text(isAvailable ? "Pesan" : "Habis"),
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
}