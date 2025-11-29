import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/facility_service.dart';
import 'package:bulbul_reservasi/services/favorite_service.dart';
import 'package:bulbul_reservasi/screens/users/payment_screen.dart';

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({super.key});

  @override
  _FavoriteTabState createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  // 1. Warna Utama (Tosca)
  final Color mainColor = const Color(0xFF50C2C9); 

  final FacilityService _facilityService = FacilityService();
  final FavoriteService _favoriteService = FavoriteService();

  bool _isLoading = true;
  List<dynamic> _favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteFacilities();
  }

  // Reload data saat halaman dibuka
  Future<void> _loadFavoriteFacilities() async {
    setState(() => _isLoading = true);
    try {
      final favoriteIds = await _favoriteService.getFavorites();
      final facilities = await _facilityService.getFacilities();

      // Filter hanya fasilitas yang ID-nya ada di daftar favorit
      final filtered = facilities.where((item) => favoriteIds.contains(item['id'])).toList();

      if (mounted) {
        setState(() {
          _favoriteItems = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading favorites: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi Hapus Favorit
  Future<void> _removeFavorite(int id) async {
    await _favoriteService.toggleFavorite(id);
    
    // Update UI secara langsung (hapus dari list lokal)
    setState(() {
      _favoriteItems.removeWhere((item) => item['id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Dihapus dari favorit"), 
        duration: Duration(seconds: 1),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToPayment(int id, String itemName, var price) {
    double priceDouble = double.tryParse(price.toString()) ?? 0.0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          fasilitasId: id,
          itemName: itemName,
          pricePerUnit: priceDouble
        ),
      ),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Image.asset("assets/images/pantai_landingscreens.jpg", fit: BoxFit.cover);
    } else if (path.startsWith("http")) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.grey));
    } else {
      return Image.asset(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.image_not_supported, color: Colors.grey));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background agak abu biar kartu kontras
      
      // 2. AppBar Konsisten (Warna Tosca, Teks Putih)
      appBar: AppBar(
        title: Text(
          "Favorit Saya", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)
        ),
        backgroundColor: mainColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Hilangkan tombol back default
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))
        ),
      ),
      
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _favoriteItems.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadFavoriteFacilities,
                  color: mainColor,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: _favoriteItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildFavoriteCard(_favoriteItems[index]),
                      );
                    },
                  ),
                ),
    );
  }

  // 3. Widget Empty State (Jika tidak ada favorit)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              shape: BoxShape.circle
            ),
            child: Icon(Icons.favorite_border, size: 60, color: mainColor),
          ),
          SizedBox(height: 20),
          Text(
            "Belum ada favorit",
            style: TextStyle(fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Tandai fasilitas yang Anda suka \nagar muncul di sini.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // 4. Widget Kartu Favorit (Desain Modern)
  Widget _buildFavoriteCard(Map<String, dynamic> item) {
    String title = item['nama_fasilitas'] ?? 'Tanpa Nama';
    String price = "Rp ${item['harga']}";
    String? imgUrl = item['foto'];
    int id = item['id'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Shadow halus
            blurRadius: 15,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GAMBAR & TOMBOL HAPUS (Stack)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: _buildImage(imgUrl),
                ),
              ),
              // Gradient Overlay agar gambar terlihat elegan
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.0)],
                    ),
                  ),
                ),
              ),
              // Tombol Hapus (Hati Merah) di Pojok Kanan Atas
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]
                  ),
                  child: IconButton(
                    icon: Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => _removeFavorite(id),
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.all(8),
                    iconSize: 22,
                    tooltip: "Hapus dari Favorit",
                  ),
                ),
              ),
              // Tag Lokasi (Pojok Kiri Atas)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text("Pantai Bulbul", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // INFORMASI
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  price,
                  style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 15),
                
                // TOMBOL PESAN (Full Width & Warna Konsisten)
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () => _navigateToPayment(id, title, item['harga']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Pesan Sekarang",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}