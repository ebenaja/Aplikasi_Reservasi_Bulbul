import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/category_list_screen.dart'; 
import 'package:bulbul_reservasi/screens/payment_screen.dart'; 

class BerandaTab extends StatefulWidget {
  @override
  _BerandaTabState createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  final Color mainColor = Color(0xFF50C2C9);
  final TextEditingController _searchController = TextEditingController();
  
  // --- DATA DUMMY ---
  final List<Map<String, dynamic>> _allRecommendations = [
    {"title": "Pondok VIP 1", "location": "Pantai Pasir Putih", "price": "Rp 200rb", "rating": 4.8, "image": "assets/images/pantai_landingscreens.jpg"},
    {"title": "Tenda Camping", "location": "Area Kemah", "price": "Rp 150rb", "rating": 4.5, "image": "assets/images/pantai_landingscreens.jpg"},
  ];

  final List<Map<String, dynamic>> _allPopulars = [
    {"title": "Banana Boat", "desc": "Wahana Air", "price": "Rp 35.000", "rating": 4.9, "image": "assets/images/pantai_landingscreens.jpg"},
    {"title": "Homestay", "desc": "Keluarga", "price": "Rp 500rb", "rating": 4.7, "image": "assets/images/pantai_landingscreens.jpg"},
    {"title": "Pelampung", "desc": "Safety", "price": "Rp 20.000", "rating": 4.5, "image": "assets/images/pantai_landingscreens.jpg"},
  ];

  final List<Map<String, dynamic>> _allTestimonials = [
    {"name": "Budi", "text": "Tempat nyaman & bersih.", "stars": 5},
    {"name": "Siti", "text": "Seru banget wahananya!", "stars": 4},
  ];

  List<Map<String, dynamic>> _foundRecommendations = [];
  List<Map<String, dynamic>> _foundPopulars = [];

  @override
  void initState() {
    super.initState();
    _foundRecommendations = _allRecommendations;
    _foundPopulars = _allPopulars;
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> resultsRec = [];
    List<Map<String, dynamic>> resultsPop = [];
    if (enteredKeyword.isEmpty) {
      resultsRec = _allRecommendations;
      resultsPop = _allPopulars;
    } else {
      resultsRec = _allRecommendations.where((item) => item["title"].toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
      resultsPop = _allPopulars.where((item) => item["title"].toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
    }
    setState(() {
      _foundRecommendations = resultsRec;
      _foundPopulars = resultsPop;
    });
  }

  // --- NAVIGASI DENGAN ANIMASI SMOOTH ---
  void _navigateToCategory(String categoryName) {
    Navigator.push(
      context,
      // Menggunakan fungsi animasi custom
      _createSmoothRoute(CategoryListScreen(categoryName: categoryName)),
    );
  }

  // --- NAVIGASI PEMBAYARAN SMOOTH ---
  void _navigateToPayment(String itemName, String price) {
    Navigator.push(
      context,
      _createSmoothRoute(PaymentScreen(itemName: itemName, price: price)),
    );
  }

  // --- FUNGSI PEMBUAT TRANSISI (RAHASIA SMOOTH) ---
  Route _createSmoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        
        // Animasi: Muncul dari bawah sedikit (0.1) ke posisi normal (0.0)
        const begin = Offset(0.0, 0.1); 
        const end = Offset.zero;
        // Kurva: Cepat di awal, melambat lembut di akhir
        const curve = Curves.easeInOutQuart; 

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition( // Digabung dengan efek pudar
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 500), // 0.5 Detik
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

          // KATEGORI (Dengan Animasi Klik)
          if (_searchController.text.isEmpty) ...[
             SizedBox(height: 20),
             Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _buildCategoryItem("Pondok", Icons.bungalow_outlined, true, () => _navigateToCategory("Pondok")),
                  _buildCategoryItem("Tenda", Icons.holiday_village_outlined, false, () => _navigateToCategory("Tenda")),
                  _buildCategoryItem("Homestay", Icons.house_siding_outlined, false, () => _navigateToCategory("Homestay")),
                  _buildCategoryItem("Wahana", Icons.kayaking, false, () => _navigateToCategory("Wahana")),
                ],
              ),
            ),
          ],

          SizedBox(height: 25),

          // REKOMENDASI
          if (_foundRecommendations.isNotEmpty) ...[
            Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Rekomendasi Pilihan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))),
            SizedBox(height: 15),
            SizedBox(height: 260, child: ListView.builder(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal: 20), itemCount: _foundRecommendations.length, itemBuilder: (context, index) {
                  final item = _foundRecommendations[index];
                  return Padding(padding: const EdgeInsets.only(right: 15), child: _buildRecommendationCard(item["title"], item["location"], item["price"], item["rating"], item["image"]));
                },
              ),
            ),
            SizedBox(height: 25),
          ],

          // POPULER
          if (_foundPopulars.isNotEmpty) ...[
            Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Fasilitas Populer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))),
            SizedBox(height: 10),
            ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), padding: EdgeInsets.symmetric(horizontal: 20), itemCount: _foundPopulars.length, itemBuilder: (context, index) {
                final item = _foundPopulars[index];
                return Padding(padding: const EdgeInsets.only(bottom: 15), child: _buildPopularCard(item["title"], item["desc"], item["price"], item["rating"], item["image"]));
              },
            ),
          ],
          
          // TESTIMONI
          if (_searchController.text.isEmpty) ...[
            SizedBox(height: 25),
            Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Apa Kata Pengunjung?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Icon(Icons.format_quote, color: mainColor.withOpacity(0.5), size: 30)]), SizedBox(height: 20), ..._allTestimonials.map((review) { return Column(children: [_buildTestimonialItem(review['name'], review['text'], review['stars']), Divider(height: 30, color: Colors.grey[200])]); }).toList()]))),
          ],

          SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- WIDGET HELPER DENGAN GESTURE ---

  Widget _buildCategoryItem(String title, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        // Efek Tekan Sederhana (AnimatedContainer bisa ditambahkan jika ingin lebih kompleks)
        Container(
          height: 60, width: 60, 
          decoration: BoxDecoration(color: isActive ? mainColor : Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))]), 
          child: Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 28)
        ), 
        SizedBox(height: 8), 
        Text(title, style: TextStyle(fontSize: 12, color: isActive ? mainColor : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal))
      ]),
    );
  }

  Widget _buildRecommendationCard(String title, String location, String price, double rating, String imgPath) {
    return GestureDetector(
      onTap: () => _navigateToPayment(title, price), // Pindah dengan animasi smooth
      child: Container(width: 220, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Stack(children: [ClipRRect(borderRadius: BorderRadius.vertical(top: Radius.circular(20)), child: Image.asset(imgPath, height: 140, width: double.infinity, fit: BoxFit.cover, cacheWidth: 400)), Positioned(top: 10, right: 10, child: Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle), child: Icon(Icons.favorite_border, size: 18, color: Colors.redAccent)))]), Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis), SizedBox(height: 4), Row(children: [Icon(Icons.location_on, size: 14, color: Colors.grey), SizedBox(width: 4), Text(location, style: TextStyle(fontSize: 12, color: Colors.grey))]), SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(price, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 16)), Row(children: [Icon(Icons.star, size: 14, color: Colors.amber), SizedBox(width: 4), Text(rating.toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])])]))])),
    );
  }

  Widget _buildPopularCard(String title, String desc, String price, double rating, String imgPath) {
    return GestureDetector( // Card bisa diklik juga
      onTap: () => _navigateToPayment(title, price),
      child: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2))]), child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(imgPath, height: 80, width: 80, fit: BoxFit.cover, cacheWidth: 200)), SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(height: 4), Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey)), SizedBox(height: 8), Text(price, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 14))])), 
      ElevatedButton(
        onPressed: () => _navigateToPayment(title, price), // Tombol Pesan juga pakai animasi smooth
        style: ElevatedButton.styleFrom(backgroundColor: mainColor, minimumSize: Size(60, 30), padding: EdgeInsets.symmetric(horizontal: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
        child: Text("Pesan", style: TextStyle(fontSize: 12, color: Colors.white))) 
      ])),
    );
  }

  Widget _buildTestimonialItem(String name, String text, int stars) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(radius: 16, backgroundColor: Colors.grey[200], child: Icon(Icons.person, size: 20, color: Colors.grey)), SizedBox(width: 10), Text(name, style: TextStyle(fontWeight: FontWeight.bold))]), SizedBox(height: 5), Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic))]);
  }
}