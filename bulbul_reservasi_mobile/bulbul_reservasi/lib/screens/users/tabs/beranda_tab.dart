import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bulbul_reservasi/screens/users/user_facilities_screen.dart'; 
import 'package:bulbul_reservasi/screens/users/payment_screen.dart';
import 'package:bulbul_reservasi/services/facility_service.dart';
import 'package:bulbul_reservasi/services/ulasan_service.dart';
import 'package:bulbul_reservasi/services/local_storage_service.dart'; // Pakai Local Storage

class BerandaTab extends StatefulWidget {
  const BerandaTab({super.key});

  @override
  _BerandaTabState createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  final Color backgroundColor = const Color(0xFFF8F9FA);

  final TextEditingController _searchController = TextEditingController();
  final FacilityService _facilityService = FacilityService();
  final UlasanService _ulasanService = UlasanService();
  final LocalStorageService _localStorage = LocalStorageService();

  bool _isLoading = true;
  List<dynamic> _allFacilities = [];
  List<dynamic> _recommendations = [];
  List<dynamic> _populars = [];
  List<dynamic> _searchResults = [];
  List<dynamic> _testimonials = [];
  List<String> _favoriteIds = []; 

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void refreshFavorites() async {
    final ids = await _localStorage.getFavoriteIds();
    if (mounted) setState(() => _favoriteIds = ids);
  }

  void _fetchData() async {
    try {
      final facilitiesData = await _facilityService.getFacilities();
      final ulasanData = await _ulasanService.getRecentUlasan();
      final favIds = await _localStorage.getFavoriteIds();

      if (mounted) {
        setState(() {
          _allFacilities = facilitiesData;
          
          var promoItems = facilitiesData.where((item) => item['is_promo'] == 1 || item['is_promo'] == true).toList();
          _recommendations = promoItems.isNotEmpty ? promoItems : facilitiesData.take(3).toList();
          
          _populars = facilitiesData.length > 3 ? facilitiesData.sublist(3).toList() : facilitiesData;
          _testimonials = ulasanData;
          _favoriteIds = favIds;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(int id) async {
    String idStr = id.toString();
    await _localStorage.toggleFavorite(idStr);
    setState(() {
      if (_favoriteIds.contains(idStr)) {
        _favoriteIds.remove(idStr);
      } else {
        _favoriteIds.add(idStr);
      }
    });
  }

  void _runFilter(String enteredKeyword) {
    List<dynamic> results = [];
    if (enteredKeyword.isEmpty) {
      results = [];
    } else {
      results = _allFacilities
          .where((item) => item["nama_fasilitas"].toString().toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() => _searchResults = results);
  }

  void _navigateToCategory(String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserFacilitiesScreen(category: categoryName)),
    ).then((_) => refreshFavorites());
  }

  void _navigateToSeeAll() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserFacilitiesScreen(category: "Semua")),
    ).then((_) => refreshFavorites());
  }

  void _navigateToPayment(int id, String itemName, var price) {
    double priceDouble = double.tryParse(price.toString()) ?? 0.0;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentScreen(fasilitasId: id, itemName: itemName, pricePerUnit: priceDouble)),
    );
  }

  Future<void> _contactAdmin() async {
    String phoneNumber = "6283492468871"; 
    final Uri url = Uri.parse("https://wa.me/$phoneNumber");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal membuka WhatsApp")));
    }
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover);
    } else if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.grey));
    } else {
      return Image.asset(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.image_not_supported, color: Colors.grey));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER & SEARCH
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [mainColor, secondaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Selamat Datang 👋", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                            SizedBox(height: 5),
                            Text("BulbulHolidays", style: TextStyle(fontFamily: "Serif", fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                          child: Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -25, left: 24, right: 24,
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: Offset(0, 10))]),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => _runFilter(value),
                      style: TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded, color: mainColor),
                        hintText: "Cari fasilitas...",
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        suffixIcon: _searchController.text.isNotEmpty ? GestureDetector(onTap: () { _searchController.clear(); _runFilter(''); FocusScope.of(context).unfocus(); }, child: Icon(Icons.close, color: Colors.grey)) : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),

            if (_searchController.text.isNotEmpty) ...[
              Padding(padding: EdgeInsets.all(24), child: Text("Hasil Pencarian:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ListView.builder(
                shrinkWrap: true, physics: NeverScrollableScrollPhysics(), padding: EdgeInsets.symmetric(horizontal: 24), itemCount: _searchResults.length,
                itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(bottom: 20), child: _buildCardItem(_searchResults[index], isHorizontal: false)),
              ),
            ] else ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCategoryBtn("Pondok", Icons.house_siding_rounded, () => _navigateToCategory("Pondok")),
                    _buildCategoryBtn("Tenda", Icons.holiday_village_rounded, () => _navigateToCategory("Tenda")),
                    _buildCategoryBtn("Homestay", Icons.home_rounded, () => _navigateToCategory("Homestay")),
                    _buildCategoryBtn("Wahana", Icons.kayaking_rounded, () => _navigateToCategory("Wahana")),
                  ],
                ),
              ),
              SizedBox(height: 30),

              Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Container(width: 5, height: 20, decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(10))), SizedBox(width: 8), Text("Promo Akhir Pekan 🔥", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))]), GestureDetector(onTap: _navigateToSeeAll, child: Text("Lihat Semua", style: TextStyle(fontSize: 13, color: mainColor, fontWeight: FontWeight.bold)))])),
              SizedBox(height: 15),
              SizedBox(height: 310, child: ListView.builder(scrollDirection: Axis.horizontal, padding: EdgeInsets.only(left: 24, right: 10), itemCount: _recommendations.length, itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(right: 16), child: _buildCardItem(_recommendations[index], isHorizontal: true)))),
              
              SizedBox(height: 30),
              Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Row(children: [Container(width: 5, height: 20, decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(10))), SizedBox(width: 8), Text("Fasilitas Populer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))])),
              SizedBox(height: 15),
              ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), padding: EdgeInsets.symmetric(horizontal: 24), itemCount: _populars.length, itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(bottom: 20), child: _buildCardItem(_populars[index], isHorizontal: false))),
              
              SizedBox(height: 30),
              Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Container(width: double.infinity, padding: EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2E3E5C), Color(0xFF4A5E8C)]), borderRadius: BorderRadius.circular(24)), child: Row(children: [Icon(Icons.support_agent_rounded, color: Colors.white, size: 30), SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Butuh Bantuan?", style: TextStyle(color: Colors.white70)), Text("Hubungi Admin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(height: 5), GestureDetector(onTap: _contactAdmin, child: Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(20)), child: Text("Chat WhatsApp", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))))]))]))),
              SizedBox(height: 30),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Column(children: [Container(height: 65, width: 65, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]), child: Icon(icon, color: mainColor, size: 30)), SizedBox(height: 10), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]));
  }

  Widget _buildCardItem(Map<String, dynamic> item, {required bool isHorizontal}) {
    String title = item['nama_fasilitas'] ?? 'Tanpa Nama';
    String price = "Rp ${item['harga']}";
    String? imgUrl = item['foto'];
    int id = item['id'];
    bool isFavorite = _favoriteIds.contains(id.toString());

    return Container(
      width: isHorizontal ? 220 : double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(borderRadius: BorderRadius.vertical(top: Radius.circular(20)), child: SizedBox(height: 150, width: double.infinity, child: _buildImage(imgUrl))),
              Positioned(
                top: 10, right: 10,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(id),
                  child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey, size: 20)),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                    ElevatedButton(onPressed: () => _navigateToPayment(id, title, item['harga']), style: ElevatedButton.styleFrom(backgroundColor: mainColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text("Pesan", style: TextStyle(color: Colors.white)))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}