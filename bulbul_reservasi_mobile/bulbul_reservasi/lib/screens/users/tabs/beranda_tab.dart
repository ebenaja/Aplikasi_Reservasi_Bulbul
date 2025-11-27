import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/users/user_facilities_screen.dart';
import 'package:bulbul_reservasi/screens/users/payment_screen.dart';
import 'package:bulbul_reservasi/services/facility_service.dart';
import 'package:bulbul_reservasi/services/ulasan_service.dart'; // IMPORT SERVICE BARU

class BerandaTab extends StatefulWidget {
  const BerandaTab({super.key});

  @override
  _BerandaTabState createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  final Color mainColor = Color(0xFF50C2C9);
  final TextEditingController _searchController = TextEditingController();
  
  final FacilityService _facilityService = FacilityService();
  final UlasanService _ulasanService = UlasanService(); // Instance Ulasan
  
  bool _isLoading = true;
  bool _showAllReviews = false;

  // List Data dari Database
  List<dynamic> _allFacilities = [];
  List<dynamic> _recommendations = [];
  List<dynamic> _populars = [];
  List<dynamic> _testimonials = []; // Data Ulasan Asli

  // Hasil Pencarian
  List<dynamic> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // --- AMBIL DATA DARI API ---
  void _fetchData() async {
    try {
      // 1. Ambil Fasilitas
      final facilitiesData = await _facilityService.getFacilities();
      // 2. Ambil Ulasan
      final ulasanData = await _ulasanService.getRecentUlasan();
      
      if (mounted) {
        setState(() {
          _allFacilities = facilitiesData;
          _testimonials = ulasanData; // Simpan ulasan

          // Bagi data fasilitas
          _recommendations = facilitiesData.take(3).toList();
          if (facilitiesData.length > 3) {
            _populars = facilitiesData.sublist(3).toList();
          } else {
            _populars = facilitiesData;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error Fetch Beranda: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _runFilter(String enteredKeyword) {
    List<dynamic> results = [];
    if (enteredKeyword.isEmpty) {
      results = [];
    } else {
      results = _allFacilities.where((item) => 
        item["nama_fasilitas"].toString().toLowerCase().contains(enteredKeyword.toLowerCase())
      ).toList();
    }
    setState(() {
      _searchResults = results;
    });
  }

  void _navigateToCategory(String categoryName) {
    Navigator.push(
      context,
      _createSmoothRoute(UserFacilitiesScreen(category: categoryName)),
    );
  }

  void _navigateToPayment(int id, String itemName, var price) {
    double priceDouble = double.tryParse(price.toString()) ?? 0.0;
    Navigator.push(
      context,
      _createSmoothRoute(PaymentScreen(
        fasilitasId: id, 
        itemName: itemName, 
        pricePerUnit: priceDouble
      )),
    );
  }

  Route _createSmoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1); 
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart; 
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER & SEARCH
          Stack(
            children: [
              Container(height: 300, width: double.infinity, decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)))),
              SafeArea(child: Padding(padding: const EdgeInsets.all(20.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text("Lokasi Anda", style: TextStyle(color: Colors.white70, fontSize: 12)),
                              Row(children: [Icon(Icons.location_on, color: Colors.white, size: 16), SizedBox(width: 4), Text("Balige, Toba", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                            ]),
                          Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.notifications_none, color: Colors.white))
                        ]),
                      SizedBox(height: 20),
                      Text("Temukan Tempat\nLiburan Impianmu", style: TextStyle(fontFamily: "Serif", fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                      SizedBox(height: 20),
                      Container(padding: EdgeInsets.symmetric(horizontal: 15), height: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]), child: Row(children: [Icon(Icons.search, color: Colors.grey), SizedBox(width: 10), Expanded(child: TextField(controller: _searchController, onChanged: (value) => _runFilter(value), decoration: InputDecoration(hintText: "Cari Pondok, Tenda, dll...", border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey[400])))), if (_searchController.text.isNotEmpty) GestureDetector(onTap: () { _searchController.clear(); _runFilter(''); FocusScope.of(context).unfocus(); }, child: Icon(Icons.close, color: Colors.grey))])),
                    ]))),
            ],
          ),

          // --- HASIL PENCARIAN ---
          if (_searchController.text.isNotEmpty) ...[
             Padding(padding: EdgeInsets.all(20), child: Text("Hasil Pencarian:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
             if (_searchResults.isEmpty)
                Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Column(children: [Icon(Icons.search_off, size: 50, color: Colors.grey), Text("Tidak ditemukan", style: TextStyle(color: Colors.grey))]))),
             ListView.builder(
               shrinkWrap: true,
               physics: NeverScrollableScrollPhysics(),
               padding: EdgeInsets.symmetric(horizontal: 20),
               itemCount: _searchResults.length,
               itemBuilder: (context, index) {
                 final item = _searchResults[index];
                 return Padding(padding: const EdgeInsets.only(bottom: 15), child: _buildPopularCard(item));
               },
             ),
          ] 
          
          // --- TAMPILAN UTAMA ---
          else ...[
             SizedBox(height: 20),
             Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _buildCategoryItem("Pondok", Icons.bungalow_outlined, true, () => _navigateToCategory("Pondok")),
                  _buildCategoryItem("Tenda", Icons.holiday_village_outlined, false, () => _navigateToCategory("Tenda")),
                  _buildCategoryItem("Homestay", Icons.house_siding_outlined, false, () => _navigateToCategory("Homestay")),
                  _buildCategoryItem("Wahana", Icons.kayaking, false, () => _navigateToCategory("Wahana")),
                ],
              ),
            ),

            SizedBox(height: 25),

            // REKOMENDASI
            Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Rekomendasi Pilihan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))),
            SizedBox(height: 15),
            
            _isLoading 
              ? Center(child: CircularProgressIndicator(color: mainColor))
              : (_recommendations.isEmpty 
                  ? Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Belum ada data.", style: TextStyle(color: Colors.grey)))
                  : SizedBox(height: 260, child: ListView.builder(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal: 20), itemCount: _recommendations.length, itemBuilder: (context, index) {
                        final item = _recommendations[index];
                        return Padding(padding: const EdgeInsets.only(right: 15), child: _buildRecommendationCard(item));
                      },
                    ),
                  )
                ),
            
            SizedBox(height: 25),

            // POPULER
            Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Fasilitas Populer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))),
            SizedBox(height: 10),
            
            _isLoading 
              ? Center(child: CircularProgressIndicator(color: mainColor))
              : (_populars.isEmpty
                  ? Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Belum ada data populer.", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), padding: EdgeInsets.symmetric(horizontal: 20), itemCount: _populars.length, itemBuilder: (context, index) {
                      final item = _populars[index];
                      return Padding(padding: const EdgeInsets.only(bottom: 15), child: _buildPopularCard(item));
                    },
                  )
                ),
            
            // --- TESTIMONI DARI DATABASE ---
            SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20), 
              child: Container(
                padding: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))]), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        Text("Apa Kata Pengunjung?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
                        Icon(Icons.format_quote, color: mainColor.withOpacity(0.5), size: 30)
                      ]
                    ), 
                    SizedBox(height: 20), 
                    
                    // JIKA KOSONG
                    if (_testimonials.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text("Belum ada ulasan.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                      )
                    else
                      // TAMPILKAN LIST DARI DATABASE
                      ...(_showAllReviews ? _testimonials : _testimonials.take(3)).map((review) { 
                        return Column(
                          children: [
                            _buildTestimonialItem(
                              review['user']?['nama'] ?? 'Pengunjung', 
                              review['komentar'] ?? '-', 
                              review['rating'] ?? 5
                            ), 
                            Divider(height: 30, color: Colors.grey[200])
                          ]
                        ); 
                      }).toList(),

                    SizedBox(height: 10),
                    if (_testimonials.length > 3)
                      SizedBox(
                        width: double.infinity, 
                        height: 45, 
                        child: OutlinedButton(
                          onPressed: () { 
                            setState(() { _showAllReviews = !_showAllReviews; }); 
                          }, 
                          style: OutlinedButton.styleFrom(side: BorderSide(color: mainColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), 
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center, 
                            children: [
                              Text(_showAllReviews ? "Sembunyikan Ulasan" : "Lihat Semua Ulasan", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)), 
                              SizedBox(width: 5), 
                              Icon(_showAllReviews ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: mainColor)
                            ]
                          )
                        )
                      ) 
                  ]
                )
              )
            ),
            
            SizedBox(height: 30),
          ]
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildCategoryItem(String title, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [Container(height: 60, width: 60, decoration: BoxDecoration(color: isActive ? mainColor : Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))]), child: Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 28)), SizedBox(height: 8), Text(title, style: TextStyle(fontSize: 12, color: isActive ? mainColor : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal))]),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> item) {
    String title = item['nama_fasilitas'] ?? 'Tanpa Nama';
    String price = "Rp ${item['harga']}";
    String? imgUrl = item['foto'];
    int id = item['id'];

    return GestureDetector(
      onTap: () => _navigateToPayment(id, title, item['harga']),
      child: Container(width: 220, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Stack(children: [ClipRRect(borderRadius: BorderRadius.vertical(top: Radius.circular(20)), 
      child: Container(height: 140, width: double.infinity, color: Colors.grey[200], 
        child: (imgUrl != null && imgUrl != '') ? Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_,__,___)=>Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover)) : Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover)
      )), Positioned(top: 10, right: 10, child: Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle), child: Icon(Icons.favorite_border, size: 18, color: Colors.redAccent)))]), Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis), SizedBox(height: 4), Row(children: [Icon(Icons.location_on, size: 14, color: Colors.grey), SizedBox(width: 4), Text("Pantai Bulbul", style: TextStyle(fontSize: 12, color: Colors.grey))]), SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(price, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 16)), Row(children: [Icon(Icons.star, size: 14, color: Colors.amber), SizedBox(width: 4), Text("4.5", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])])]))])),
    );
  }

  Widget _buildPopularCard(Map<String, dynamic> item) {
    String title = item['nama_fasilitas'] ?? 'Tanpa Nama';
    String desc = item['deskripsi'] ?? 'Fasilitas nyaman';
    String price = "Rp ${item['harga']}";
    String? imgUrl = item['foto'];
    int id = item['id'];

    return GestureDetector(
      onTap: () => _navigateToPayment(id, title, item['harga']),
      child: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2))]), child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(10), 
        child: Container(height: 80, width: 80, color: Colors.grey[200],
          child: (imgUrl != null && imgUrl != '') ? Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_,__,___)=>Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover)) : Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover)
        )), SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(height: 4), Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis), SizedBox(height: 8), Text(price, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 14))])), 
      ElevatedButton(
        onPressed: () => _navigateToPayment(id, title, item['harga']), 
        style: ElevatedButton.styleFrom(backgroundColor: mainColor, minimumSize: Size(60, 30), padding: EdgeInsets.symmetric(horizontal: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
        child: Text("Pesan", style: TextStyle(fontSize: 12, color: Colors.white))) 
      ])),
    );
  }

  Widget _buildTestimonialItem(String name, String text, int stars) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(radius: 16, backgroundColor: Colors.grey[200], child: Icon(Icons.person, size: 20, color: Colors.grey)), SizedBox(width: 10), Text(name, style: TextStyle(fontWeight: FontWeight.bold))]), SizedBox(height: 5), Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic))]);
  }
}