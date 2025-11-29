import 'package:flutter/material.dart';
// MAKE SURE THIS PATH IS 100% CORRECT
import 'package:bulbul_reservasi/screens/users/user_facilities_screen.dart'; 
import 'package:bulbul_reservasi/screens/users/payment_screen.dart';
import 'package:bulbul_reservasi/services/facility_service.dart';
import 'package:bulbul_reservasi/services/ulasan_service.dart';
import 'package:bulbul_reservasi/services/favorite_service.dart';
import 'package:url_launcher/url_launcher.dart';

class BerandaTab extends StatefulWidget {
  const BerandaTab({super.key});

  @override
  _BerandaTabState createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  // --- PALETTE WARNA ---
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  final Color backgroundColor = const Color(0xFFF8F9FA);

  final TextEditingController _searchController = TextEditingController();
  final FacilityService _facilityService = FacilityService();
  final UlasanService _ulasanService = UlasanService();
  final FavoriteService _favoriteService = FavoriteService();

  bool _isLoading = true;

  // Data
  List<dynamic> _allFacilities = [];
  List<dynamic> _recommendations = []; // Data Promo Akhir Pekan
  List<dynamic> _populars = [];
  List<dynamic> _searchResults = [];
  List<dynamic> _testimonials = [];
  List<int> _favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void refreshFavorites() {
    _favoriteService.getFavorites().then((ids) {
      if (mounted) setState(() => _favoriteIds = ids);
    });
  }

 void _fetchData() async {
    try {
      final facilitiesData = await _facilityService.getFacilities();
      final ulasanData = await _ulasanService.getRecentUlasan();
      final favIds = await _favoriteService.getFavorites();

      if (mounted) {
        setState(() {
          _allFacilities = facilitiesData;
          
          // --- PERUBAHAN DI SINI ---
          // Filter hanya fasilitas yang is_promo == 1 (atau true)
          // Jika tidak ada promo sama sekali, fallback ambil 3 item pertama
          var promoItems = facilitiesData.where((item) => item['is_promo'] == 1 || item['is_promo'] == true).toList();
          
          if (promoItems.isNotEmpty) {
            _recommendations = promoItems;
          } else {
            // Jika admin lupa set promo, tampilkan 3 teratas agar tidak kosong jelek
            _recommendations = facilitiesData.take(3).toList();
          }
          // ------------------------

          _populars = facilitiesData.length > 3 ? facilitiesData.sublist(3).toList() : facilitiesData;
          _testimonials = ulasanData;
          _favoriteIds = favIds;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error Fetch Beranda: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(int id) async {
    await _favoriteService.toggleFavorite(id);
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
  }

  void _runFilter(String enteredKeyword) {
    List<dynamic> results = [];
    if (enteredKeyword.isEmpty) {
      results = [];
    } else {
      results = _allFacilities
          .where((item) => item["nama_fasilitas"]
              .toString()
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() => _searchResults = results);
  }

  // --- NAVIGASI ---

  void _navigateToCategory(String categoryName) {
    Navigator.push(
      context,
      // If UserFacilitiesScreen is correctly imported, this will work.
      MaterialPageRoute(builder: (context) => UserFacilitiesScreen(category: categoryName)),
    ).then((_) => refreshFavorites());
  }

  void _navigateToSeeAll() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserFacilitiesScreen(category: "Semua Fasilitas")),
    ).then((_) => refreshFavorites());
  }

  // MODIFIKASI: Kirim Data Promo ke Halaman Notifikasi
  void _navigateToNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationScreen(
          promoItems: _recommendations // Data Promo dikirim kesini
        ), 
      ),
    );
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
            // --- 1. HEADER ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [mainColor, secondaryColor],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
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
                        
                        // TOMBOL NOTIFIKASI
                        GestureDetector(
                          onTap: _navigateToNotification,
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
                              ),
                              // Badge jika ada promo
                              if (_recommendations.isNotEmpty)
                                Positioned(
                                  right: 10, top: 10,
                                  child: Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                                  ),
                                )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                
                // Search Bar
                Positioned(
                  bottom: -25, left: 24, right: 24,
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: Offset(0, 10))],
                    ),
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
                        suffixIcon: _searchController.text.isNotEmpty
                            ? GestureDetector(onTap: () { _searchController.clear(); _runFilter(''); FocusScope.of(context).unfocus(); }, child: Icon(Icons.close, color: Colors.grey))
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),

            // --- ISI KONTEN ---
            if (_searchController.text.isNotEmpty) ...[
              Padding(padding: EdgeInsets.all(24), child: Text("Hasil Pencarian:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              if (_searchResults.isEmpty) Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text("Tidak ditemukan", style: TextStyle(color: Colors.grey)))),
              ListView.builder(
                shrinkWrap: true, physics: NeverScrollableScrollPhysics(), padding: EdgeInsets.symmetric(horizontal: 24), itemCount: _searchResults.length,
                itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(bottom: 20), child: _buildCardItem(_searchResults[index], isHorizontal: false)),
              ),
            ] else ...[
              
              // 2. KATEGORI
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

              // 3. PROMO
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 5, height: 20, decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(10))),
                        SizedBox(width: 8),
                        Text("Promo Akhir Pekan 🔥", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                    GestureDetector(
                      onTap: _navigateToSeeAll,
                      child: Text("Lihat Semua", style: TextStyle(fontSize: 13, color: mainColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: mainColor))
                  : SizedBox(
                      height: 310,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal, padding: EdgeInsets.only(left: 24, right: 10), itemCount: _recommendations.length,
                        itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(right: 16), child: _buildCardItem(_recommendations[index], isHorizontal: true)),
                      ),
                    ),

              SizedBox(height: 30),

              // 4. FASILITAS POPULER
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(width: 5, height: 20, decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(10))),
                    SizedBox(width: 8),
                    Text("Fasilitas Populer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
              ),
              SizedBox(height: 15),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true, physics: NeverScrollableScrollPhysics(), padding: EdgeInsets.symmetric(horizontal: 24), itemCount: _populars.length,
                      itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(bottom: 20), child: _buildCardItem(_populars[index], isHorizontal: false)),
                    ),

              SizedBox(height: 30),

              // 5. TESTIMONI
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: Offset(0, 10))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Review Pengunjung", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                        ],
                      ),
                      SizedBox(height: 20),
                      if (_testimonials.isEmpty)
                        Text("Belum ada ulasan.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                      else
                        ..._testimonials.take(3).map((review) {
                          String userName = review['user'] != null ? review['user']['nama'] : 'Pengunjung';
                          String text = review['komentar'] ?? '';
                          int stars = review['rating'] ?? 5;
                          return Column(children: [_buildTestimonialItem(userName, text, stars), if (review != _testimonials.take(3).last) Divider(height: 30, color: Colors.grey[100], thickness: 1)]);
                        }).toList(),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // 6. KONTAK
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF2E3E5C), Color(0xFF4A5E8C)]), 
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Color(0xFF2E3E5C).withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                        child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 30),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Butuh Bantuan?", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text("Hubungi Admin Kami", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 5),
                            GestureDetector(
                              onTap: _contactAdmin, 
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.chat_bubble_outline, size: 14, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text("Chat WhatsApp", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
            ]
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildCategoryBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 65, width: 65,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: Offset(0, 5))]),
            child: Icon(icon, color: mainColor, size: 30),
          ),
          SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildCardItem(Map<String, dynamic> item, {required bool isHorizontal}) {
    String title = item['nama_fasilitas'] ?? 'Tanpa Nama';
    String price = "Rp ${item['harga']}";
    String? imgUrl = item['foto'];
    int id = item['id'];
    bool isFavorite = _favoriteIds.contains(id);

    return Container(
      width: isHorizontal ? 220 : double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: Offset(0, 8))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(borderRadius: BorderRadius.vertical(top: Radius.circular(20)), child: SizedBox(height: 150, width: double.infinity, child: _buildImage(imgUrl))),
              Positioned(
                top: 10, right: 10,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(id),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                    child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border_rounded, color: isFavorite ? Colors.redAccent : Colors.grey, size: 20),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 6),
                Row(children: [Icon(Icons.location_on_rounded, size: 14, color: Colors.grey[400]), SizedBox(width: 4), Text("Pantai Bulbul", style: TextStyle(fontSize: 12, color: Colors.grey[500]))]),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: TextStyle(color: mainColor, fontWeight: FontWeight.w800, fontSize: 16)),
                    ElevatedButton(
                      onPressed: () => _navigateToPayment(id, title, item['harga']),
                      style: ElevatedButton.styleFrom(backgroundColor: mainColor, padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                      child: Text("Pesan", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialItem(String name, String text, int stars) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 20, backgroundColor: Colors.grey[200], child: Icon(Icons.person_rounded, color: Colors.grey[400])),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)), Row(children: List.generate(5, (index) => Icon(index < stars ? Icons.star_rounded : Icons.star_border_rounded, size: 14, color: Colors.amber)))]),
              SizedBox(height: 6),
              Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

// --- CLASS SCREEN NOTIFIKASI YANG DINAMIS ---
class NotificationScreen extends StatelessWidget {
  // Menerima data promo dari BerandaTab
  final List<dynamic> promoItems;

  const NotificationScreen({super.key, required this.promoItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Notifikasi & Promo", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: promoItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                  SizedBox(height: 20),
                  Text("Belum ada promo saat ini", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: promoItems.length + 1, // +1 untuk notifikasi Welcome (Dummy)
              itemBuilder: (context, index) {
                // Notifikasi Statis Pertama (Welcome)
                if (index == 0) {
                  return _buildNotifItem(
                    "Selamat Datang di Bulbul Holidays!", 
                    "Jelajahi keindahan Pantai Bulbul bersama kami.", 
                    "Baru saja", 
                    false,
                    null
                  );
                }

                // Notifikasi Promo dari Data
                final item = promoItems[index - 1]; // Offset index karena ada dummy
                return _buildNotifItem(
                  "Promo Spesial: ${item['nama_fasilitas']}", 
                  "Nikmati harga spesial Rp ${item['harga']} untuk pemesanan hari ini!", 
                  "Promo Aktif", 
                  true, // Tandai sebagai belum dibaca agar berwarna
                  Icons.local_offer_rounded
                );
              },
            ),
    );
  }

  Widget _buildNotifItem(String title, String body, String time, bool isUnread, IconData? customIcon) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isUnread ? Color(0xFF50C2C9).withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: isUnread ? Border.all(color: Color(0xFF50C2C9).withOpacity(0.3)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            // Jika ada icon custom (Promo), pakai itu. Jika tidak, pakai lonceng.
            child: Icon(customIcon ?? Icons.notifications_active_rounded, color: isUnread ? Color(0xFF50C2C9) : Colors.grey, size: 20),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text(time, style: TextStyle(color: isUnread ? Color(0xFF50C2C9) : Colors.grey, fontSize: 11, fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
                SizedBox(height: 5),
                Text(body, style: TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}