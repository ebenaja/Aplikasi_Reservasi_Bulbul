import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/facility_service.dart';
import 'package:bulbul_reservasi/services/local_storage_service.dart'; // Import Helper tadi
import 'package:bulbul_reservasi/screens/users/payment_screen.dart';

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({super.key});

  @override
  _FavoriteTabState createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  final FacilityService _facilityService = FacilityService();
  final LocalStorageService _localStorage = LocalStorageService();
  final Color mainColor = Color(0xFF50C2C9);

  List<dynamic> _favoriteFacilities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  // LOGIKA MENGAMBIL DATA GABUNGAN (API + LOCAL)
  void _fetchFavorites() async {
    setState(() => _isLoading = true);

    try {
      // 1. Ambil semua fasilitas dari Server
      final allFacilities = await _facilityService.getFacilities();
      
      // 2. Ambil daftar ID yang disimpan di HP
      final savedIds = await _localStorage.getFavoriteIds();

      // 3. Filter: Hanya ambil fasilitas yang ID-nya ada di savedIds
      List<dynamic> filtered = allFacilities.where((item) {
        String idString = item['id'].toString();
        return savedIds.contains(idString);
      }).toList();

      if (mounted) {
        setState(() {
          _favoriteFacilities = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error Favorite: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // HAPUS DARI FAVORIT
  void _removeFavorite(String id) async {
    await _localStorage.toggleFavorite(id); // Hapus dari memori
    _fetchFavorites(); // Refresh tampilan
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Dihapus dari favorit"), backgroundColor: Colors.red, duration: Duration(seconds: 1))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      appBar: AppBar(
        title: Text("Favorit Saya", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _favoriteFacilities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                      SizedBox(height: 20),
                      Text("Belum ada item favorit", style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 5),
                      Text("Tandai fasilitas yang Anda suka!", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _favoriteFacilities.length,
                  itemBuilder: (context, index) {
                    final item = _favoriteFacilities[index];
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 60, height: 60,
                            color: Colors.grey[200],
                            child: (item['foto'] != null && item['foto'] != '')
                                ? Image.network(
                                    item['foto'], 
                                    fit: BoxFit.cover,
                                    errorBuilder: (_,__,___) => Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover)
                                  )
                                : Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover),
                          ),
                        ),
                        title: Text(item['nama_fasilitas'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Rp ${item['harga']}", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                        
                        // TOMBOL HAPUS FAVORIT (SAMPAH)
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _removeFavorite(item['id'].toString()),
                        ),
                        
                        onTap: () {
                          // Bisa langsung pesan
                          double price = double.tryParse(item['harga'].toString()) ?? 0;
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => PaymentScreen(
                              fasilitasId: item['id'],
                              itemName: item['nama_fasilitas'],
                              pricePerUnit: price
                            ))
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}