import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/facility_service.dart';
import 'package:bulbul_reservasi/services/local_storage_service.dart';
import 'package:bulbul_reservasi/screens/users/payment_screen.dart';

// PERHATIKAN NAMA CLASS INI
class FavoriteTab extends StatefulWidget {
  const FavoriteTab({super.key});

  @override
  _FavoriteTabState createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  final Color mainColor = const Color(0xFF50C2C9);
  final FacilityService _facilityService = FacilityService();
  final LocalStorageService _localStorage = LocalStorageService();
  bool _isLoading = true;
  List<dynamic> _favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteFacilities();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavoriteFacilities();
  }

  Future<void> _loadFavoriteFacilities() async {
    try {
      final favoriteIds = await _localStorage.getFavoriteIds();
      final facilities = await _facilityService.getFacilities();

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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(int id) async {
    await _localStorage.toggleFavorite(id.toString());
    setState(() {
      _favoriteItems.removeWhere((item) => item['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dihapus dari favorit"), backgroundColor: Colors.redAccent, duration: Duration(seconds: 1)));
  }

  void _navigateToPayment(int id, String itemName, var price) {
    double priceDouble = double.tryParse(price.toString()) ?? 0.0;
    Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen(fasilitasId: id, itemName: itemName, pricePerUnit: priceDouble)));
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) return Image.asset("assets/images/pantai_landingscreens.jpg", fit: BoxFit.cover);
    if (path.startsWith("http")) return Image.network(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image));
    return Image.asset(path, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Favorit Saya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: mainColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _favoriteItems.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.favorite_border, size: 60, color: mainColor), Text("Belum ada favorit", style: TextStyle(color: Colors.grey))]))
              : ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: _favoriteItems.length,
                  itemBuilder: (context, index) {
                    final item = _favoriteItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                        child: Column(
                          children: [
                            Stack(children: [
                              ClipRRect(borderRadius: BorderRadius.vertical(top: Radius.circular(20)), child: SizedBox(height: 160, width: double.infinity, child: _buildImage(item['foto']))),
                              Positioned(top: 10, right: 10, child: GestureDetector(onTap: () => _removeFavorite(item['id']), child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(Icons.favorite, color: Colors.red, size: 20))))
                            ]),
                            Padding(padding: EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(item['nama_fasilitas'], style: TextStyle(fontWeight: FontWeight.bold)),
                              ElevatedButton(onPressed: () => _navigateToPayment(item['id'], item['nama_fasilitas'], item['harga']), style: ElevatedButton.styleFrom(backgroundColor: mainColor), child: Text("Pesan", style: TextStyle(color: Colors.white)))
                            ]))
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}