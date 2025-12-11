import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Pastikan sudah ada di pubspec.yaml
import 'package:bulbul_reservasi/services/facility_service.dart';
import 'package:bulbul_reservasi/services/local_storage_service.dart';
import 'package:bulbul_reservasi/screens/users/payment_screen.dart';

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({super.key});

  @override
  _FavoriteTabState createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  
  final FacilityService _facilityService = FacilityService();
  final LocalStorageService _localStorage = LocalStorageService();
  
  bool _isLoading = true;
  List<dynamic> _favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteFacilities();
  }

  // Dipanggil saat tab ini dibuka kembali (agar data refresh)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavoriteFacilities();
  }

  Future<void> _loadFavoriteFacilities() async {
    try {
      // 1. Ambil ID Favorit dari HP
      final favoriteIds = await _localStorage.getFavoriteIds();
      
      // 2. Ambil Semua Data dari Server
      // (Idealnya backend punya endpoint getByIds, tapi ini solusi sementara)
      final facilities = await _facilityService.getFacilities();

      // 3. Filter: Hanya ambil yang ID-nya ada di favoriteIds
      final filtered = facilities.where((item) {
        String id = item['id'].toString();
        return favoriteIds.contains(id);
      }).toList();

      if (mounted) {
        setState(() {
          _favoriteItems = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error Load Fav: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(int id) async {
    await _localStorage.toggleFavorite(id.toString());
    setState(() {
      _favoriteItems.removeWhere((item) => item['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Dihapus dari favorit"), 
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating, // Tampil melayang
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      )
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
        )
      )
    );
  }

  // Helper Gambar Hybrid (Aset/Network)
  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover);
    } else if (path.startsWith('http')) {
      return Image.network(
        path, 
        fit: BoxFit.cover, 
        errorBuilder: (ctx, err, stack) => Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover)
      );
    } else {
      return Image.asset(
        path, 
        fit: BoxFit.cover, 
        errorBuilder: (ctx, err, stack) => Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA), // Warna background konsisten
      appBar: AppBar(
        title: Text("Favorit Saya", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: mainColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _favoriteItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey[300]),
                      SizedBox(height: 20),
                      Text("Belum ada favorit", style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text("Simpan tempat impianmu di sini!", style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: _favoriteItems.length,
                  itemBuilder: (context, index) {
                    final item = _favoriteItems[index];
                    return FadeInUp( // Efek Animasi Masuk
                      delay: Duration(milliseconds: index * 100),
                      child: _buildFavoriteCard(item),
                    );
                  },
                ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))
        ]
      ),
      child: Column(
        children: [
          // Bagian Atas: Gambar + Tombol Hapus
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)), 
                child: SizedBox(
                  height: 160, 
                  width: double.infinity, 
                  child: _buildImage(item['foto'])
                )
              ),
              // Tombol Love (Hapus)
              Positioned(
                top: 10, right: 10, 
                child: GestureDetector(
                  onTap: () => _removeFavorite(item['id']), 
                  child: Container(
                    padding: EdgeInsets.all(8), 
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle), 
                    child: Icon(Icons.favorite, color: Colors.red, size: 22)
                  )
                )
              ),
              // Badge Kategori (Opsional, ambil dari data jika ada, atau hardcode text)
              Positioned(
                bottom: 10, left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text("Rp ${item['harga']}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              )
            ],
          ),
          
          // Bagian Bawah: Info + Tombol Pesan
          Padding(
            padding: EdgeInsets.all(16), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['nama_fasilitas'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text("Pantai Bulbul", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _navigateToPayment(item['id'], item['nama_fasilitas'], item['harga']), 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                  ), 
                  child: Text("Pesan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                )
              ]
            )
          )
        ],
      ),
    );
  }
}