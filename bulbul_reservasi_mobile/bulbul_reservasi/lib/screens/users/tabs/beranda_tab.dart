import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bulbul_reservasi/screens/users/user_facilities_screen.dart'; 
import 'package:bulbul_reservasi/screens/users/payment_screen.dart';
import 'package:bulbul_reservasi/services/facility_service.dart';
import 'package:bulbul_reservasi/services/ulasan_service.dart';
import 'package:bulbul_reservasi/services/local_storage_service.dart';

class BerandaTab extends StatefulWidget {
  const BerandaTab({super.key});

  @override
  _BerandaTabState createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  // --- WARNA & GAYA ---
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  final Color backgroundColor = const Color(0xFFF5F6FA);

  // --- CONTROLLER & SERVICE ---
  final TextEditingController _searchController = TextEditingController();
  final FacilityService _facilityService = FacilityService();
  final UlasanService _ulasanService = UlasanService();
  final LocalStorageService _localStorage = LocalStorageService();

  // --- STATE DATA ---
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

  // --- FUNGSI FETCH DATA ---
  void _fetchData() async {
    try {
      // Panggil semua API secara paralel biar cepat
      final results = await Future.wait([
        _facilityService.getFacilities(),
        _ulasanService.getRecentUlasan(),
        _localStorage.getFavoriteIds(),
      ]);

      final facilitiesData = results[0];
      final ulasanData = results[1];
      final favIds = results[2] as List<String>;

      if (mounted) {
        setState(() {
          _allFacilities = facilitiesData;
          _testimonials = ulasanData;
          _favoriteIds = favIds;

          // Logika Memisahkan Promo & Populer
          // Ambil 3 item pertama sebagai Promo/Rekomendasi
          _recommendations = facilitiesData.take(3).toList();
          
          // Ambil sisanya sebagai Populer (jika data > 3)
          if (facilitiesData.length > 3) {
            _populars = facilitiesData.sublist(3).toList();
          } else {
            _populars = facilitiesData; // Kalau sedikit, tampilkan semua di populer juga
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error Fetch Beranda: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void refreshFavorites() async {
    final ids = await _localStorage.getFavoriteIds();
    if (mounted) setState(() => _favoriteIds = ids);
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

  // --- FUNGSI SEARCH ---
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

  // --- NAVIGASI ---
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

  // --- WIDGET HELPER GAMBAR ---
  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover);
    } else if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.grey));
    } else {
      return Image.asset(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.image, color: Colors.grey));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: mainColor))
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER & SEARCH BAR
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 260,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [mainColor, secondaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 15, 24, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Halo, Pengunjung! 👋", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                                SizedBox(height: 4),
                                Text("BulbulHolidays", style: TextStyle(fontFamily: "Serif", fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                            )
                          ],
                        ),
                      ),
                    ),
                    
                    // SEARCH BAR
                    Positioned(
                      bottom: -25, left: 24, right: 24,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: Offset(0, 5))]),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => _runFilter(value),
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded, color: mainColor, size: 22),
                            hintText: "Cari Pondok, Tenda, dll...",
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                            suffixIcon: _searchController.text.isNotEmpty ? GestureDetector(onTap: () { _searchController.clear(); _runFilter(''); FocusScope.of(context).unfocus(); }, child: Icon(Icons.close, color: Colors.grey, size: 20)) : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 40),

                // 2. JIKA SEARCH AKTIF -> TAMPILKAN HASIL
                if (_searchController.text.isNotEmpty) ...[
                  Padding(padding: EdgeInsets.all(24), child: Text("Hasil Pencarian:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  if (_searchResults.isEmpty)
                    Center(child: Padding(padding: EdgeInsets.only(top: 20), child: Text("Tidak ditemukan", style: TextStyle(color: Colors.grey)))),
                  ListView.builder(
                    shrinkWrap: true, physics: NeverScrollableScrollPhysics(), padding: EdgeInsets.symmetric(horizontal: 24), itemCount: _searchResults.length,
                    itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(bottom: 15), child: _buildCardItem(_searchResults[index], isHorizontal: false)),
                  ),
                ] 
                
                // 3. JIKA TIDAK SEARCH -> TAMPILKAN DASHBOARD
                else ...[
                  // A. KATEGORI
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCategoryBtn("Pondok", Icons.house_siding_rounded, () => _navigateToCategory("Pondok")),
                        _buildCategoryBtn("Tenda", Icons.holiday_village_rounded, () => _navigateToCategory("Tenda")),
                        _buildCategoryBtn("Homestay", Icons.home_rounded, () => _navigateToCategory("Homestay")),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 25),

                  // B. PROMO / REKOMENDASI
                  if (_recommendations.isNotEmpty) ...[
                    _buildSectionTitle("Promo Spesial 🔥", onSeeAll: _navigateToSeeAll),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 260, 
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal, 
                        padding: EdgeInsets.only(left: 24, right: 10), 
                        itemCount: _recommendations.length, 
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 16), 
                          child: _buildCardItem(_recommendations[index], isHorizontal: true)
                        )
                      )
                    ),
                    SizedBox(height: 25),
                  ],
                  
                  // C. FASILITAS POPULER
                  if (_populars.isNotEmpty) ...[
                    _buildSectionTitle("Paling Populer"),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true, 
                      physics: NeverScrollableScrollPhysics(), 
                      padding: EdgeInsets.symmetric(horizontal: 24), 
                      itemCount: _populars.length, 
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 15), 
                        child: _buildCardItem(_populars[index], isHorizontal: false)
                      )
                    ),
                    SizedBox(height: 25),
                  ],

                  // D. APA KATA PENGUNJUNG (TESTIMONI) - SUDAH DIKEMBALIKAN!
                  _buildTestimonialSection(),

                  SizedBox(height: 25),

                  // E. BANNER KONTAK
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24), 
                    child: Container(
                      width: double.infinity, padding: EdgeInsets.all(16), 
                      decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2E3E5C), Color(0xFF4A5E8C)]), borderRadius: BorderRadius.circular(20)), 
                      child: Row(
                        children: [
                          Icon(Icons.support_agent_rounded, color: Colors.white, size: 28), SizedBox(width: 12), 
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Ada Pertanyaan?", style: TextStyle(color: Colors.white70, fontSize: 12)), Text("Chat Admin Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))])), 
                          GestureDetector(onTap: _contactAdmin, child: Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(15)), child: Text("WhatsApp", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))))
                        ]
                      )
                    )
                  ),
                  
                  SizedBox(height: 30),
                ]
              ],
            ),
          ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87)),
          if (onSeeAll != null)
            GestureDetector(onTap: onSeeAll, child: Text("Lihat Semua", style: TextStyle(fontSize: 12, color: mainColor, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildCategoryBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 55, width: 55, 
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 2))]),
            child: Icon(icon, color: mainColor, size: 26)
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87))
        ],
      )
    );
  }

  Widget _buildCardItem(Map<String, dynamic> item, {required bool isHorizontal}) {
    String title = item['nama_fasilitas'] ?? 'Tanpa Nama';
    String price = "Rp ${item['harga']}";
    String? imgUrl = item['foto'];
    int id = item['id'];
    bool isFavorite = _favoriteIds.contains(id.toString());
    // Ambil rating dari backend (jika ada), default 0
    double rating = double.tryParse(item['ulasan_avg_rating']?.toString() ?? '0') ?? 0.0;
    String ratingText = rating == 0 ? "Baru" : rating.toStringAsFixed(1);

    return Container(
      width: isHorizontal ? 210 : double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 3))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)), 
                child: SizedBox(height: isHorizontal ? 130 : 160, width: double.infinity, child: _buildImage(imgUrl))
              ),
              // Favorite Button
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(id),
                  child: Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle), child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey, size: 18)),
                ),
              ),
              // Rating Badge
              Positioned(
                top: 8, left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [Icon(Icons.star, color: Colors.amber, size: 12), SizedBox(width: 3), Text(ratingText, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w700, fontSize: 13)),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () => _navigateToPayment(id, title, item['harga']), 
                        style: ElevatedButton.styleFrom(backgroundColor: mainColor, padding: EdgeInsets.symmetric(horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                        child: Text("Pesan", style: TextStyle(color: Colors.white, fontSize: 11))
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- SECTION TESTIMONI (DIKEMBALIKAN & DIRAPIKAN) ---
  Widget _buildTestimonialSection() {
    if (_testimonials.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Apa Kata Pengunjung?"),
        SizedBox(height: 12),
        SizedBox(
          height: 130, // Horizontal Scroll Testimoni
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 24, right: 10),
            itemCount: _testimonials.length,
            itemBuilder: (context, index) {
              final review = _testimonials[index];
              final user = review['user'] != null ? review['user']['nama'] : 'Pengunjung';
              final text = review['komentar'] ?? '';
              final stars = review['rating'] ?? 5;

              return Container(
                width: 260,
                margin: EdgeInsets.only(right: 16),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: Offset(0, 2))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 12, backgroundColor: Colors.grey[200], child: Icon(Icons.person, size: 16, color: Colors.grey)),
                        SizedBox(width: 8),
                        Expanded(child: Text(user, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Row(children: List.generate(5, (i) => Icon(i < stars ? Icons.star : Icons.star_border, size: 12, color: Colors.amber))),
                      ],
                    ),
                    SizedBox(height: 8),
                    Expanded(child: Text('"$text"', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic), maxLines: 3, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}