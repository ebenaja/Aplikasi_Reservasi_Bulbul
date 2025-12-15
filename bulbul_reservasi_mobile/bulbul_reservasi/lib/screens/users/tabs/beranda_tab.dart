import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart'; // WAJIB ADA DI PUBSPEC
import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';

// SCREEN & SERVICE IMPORT
import 'package:bulbul_reservasi/screens/users/user_facilities_screen.dart'; 
import 'package:bulbul_reservasi/screens/users/payment_screen.dart';
import 'package:bulbul_reservasi/screens/users/notification_screen.dart';
import 'package:bulbul_reservasi/services/facility_service.dart';
import 'package:bulbul_reservasi/services/ulasan_service.dart';
import 'package:bulbul_reservasi/services/local_storage_service.dart';
import 'package:bulbul_reservasi/services/weather_service.dart'; // PASTIKAN FILE INI ADA

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

  // --- SERVICE ---
  final TextEditingController _searchController = TextEditingController();
  final FacilityService _facilityService = FacilityService();
  final UlasanService _ulasanService = UlasanService();
  final LocalStorageService _localStorage = LocalStorageService();
  final WeatherService _weatherService = WeatherService();

  // --- STATE DATA ---
  bool _isLoading = true;
  List<dynamic> _allFacilities = [];
  List<dynamic> _recommendations = [];
  List<dynamic> _populars = [];
  List<dynamic> _searchResults = [];
  List<dynamic> _testimonials = [];
  List<String> _favoriteIds = [];
  int _currentBannerIndex = 0;

  // --- STATE LOKASI & CUACA ---
  Map<String, String>? _weather;
  Timer? _weatherTimer;
  bool _useGpsForWeather = false;

  // --- DATA BANNER PROMO (CAROUSEL) ---
  final List<Map<String, dynamic>> _promoBanners = [
    {"title": "Liburan Seru! 🏖️", "subtitle": "Diskon 20% untuk Pondok VIP.", "colors": [Colors.orangeAccent, Colors.deepOrangeAccent], "icon": Icons.local_fire_department},
    {"title": "Paket Hemat 👨‍👩‍👧‍👦", "subtitle": "Homestay + Banana Boat murah.", "colors": [Colors.blueAccent, Colors.lightBlue], "icon": Icons.family_restroom},
    {"title": "Weekend Ceria 🛶", "subtitle": "Gratis 1 jam sewa Kano.", "colors": [Color(0xFF50C2C9), Color(0xFF2E8B91)], "icon": Icons.kayaking},
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Start Logic Cuaca
    _loadWeatherPreference();
    _startTimers();
  }

  @override
  void dispose() {
    _weatherTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIKA FETCH DATA ---
  void _fetchData() async {
    try {
      final results = await Future.wait([
        _facilityService.getFacilities(),
        _ulasanService.getRecentUlasan(),
        _localStorage.getFavoriteIds(),
      ]);

      if (mounted) {
        setState(() {
          _allFacilities = results[0];
          _testimonials = results[1];
          _favoriteIds = results[2] as List<String>;
          _recommendations = _allFacilities.take(3).toList();
          _populars = _allFacilities.length > 3 ? _allFacilities.sublist(3).toList() : _allFacilities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIKA CUACA & LOKASI (YANG DIKEMBALIKAN) ---
  Future<void> _loadWeatherPreference() async {
    try {
      final useGps = await _localStorage.getUseGpsForWeather(); // Pastikan method ini ada di local_storage_service.dart
      if (!mounted) return;
      setState(() => _useGpsForWeather = useGps);
      await _updateWeather();
    } catch (e) {
      _updateWeather();
    }
  }

  void _startTimers() {
    _updateWeather();
    _weatherTimer = Timer.periodic(const Duration(minutes: 10), (_) => _updateWeather());
  }

  Future<void> _updateWeather() async {
    Map<String, String>? data;
    if (_useGpsForWeather) {
      final pos = await _determinePosition();
      if (pos != null) {
        data = await _weatherService.fetchWeather(lat: pos.latitude, lon: pos.longitude);
      } else {
        data = await _weatherService.fetchWeather();
      }
    } else {
      data = await _weatherService.fetchWeather();
    }
    if (mounted) setState(() => _weather = data);
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aktifkan GPS untuk cuaca akurat')));
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _showLocationOptions() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pengaturan Lokasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 15),
              SwitchListTile(
                title: Text('Gunakan GPS untuk Cuaca'),
                value: _useGpsForWeather,
                subtitle: Text('Memerlukan izin lokasi'),
                activeColor: mainColor,
                onChanged: (v) async {
                  Navigator.pop(ctx);
                  // Simpan pref (Pastikan method setUseGpsForWeather ada di service)
                  // await _localStorage.setUseGpsForWeather(v); 
                  setState(() => _useGpsForWeather = v);
                  _updateWeather();
                },
              ),
              ListTile(
                leading: Icon(Icons.map, color: mainColor),
                title: Text("Buka Google Maps"),
                onTap: () async {
                  Navigator.pop(ctx);
                  final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=Pantai+Bulbul");
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                },
              )
            ],
          ),
        );
      }
    );
  }

  // --- LOGIKA UMUM LAINNYA ---
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

  void _runFilter(String enteredKeyword) {
    List<dynamic> results = [];
    if (enteredKeyword.isEmpty) {
      results = [];
    } else {
      results = _allFacilities.where((item) => item["nama_fasilitas"].toString().toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
    }
    setState(() => _searchResults = results);
  }

  // Navigasi Smooth
  void _navigateToCategory(String categoryName) {
    Navigator.push(context, _createSmoothRoute(UserFacilitiesScreen(category: categoryName))).then((_) => refreshFavorites());
  }
  void _navigateToSeeAll() {
    Navigator.push(context, _createSmoothRoute(UserFacilitiesScreen(category: "Semua"))).then((_) => refreshFavorites());
  }
  void _navigateToPayment(int id, String itemName, var price, String? foto) {
    double priceDouble = double.tryParse(price.toString()) ?? 0.0;
    Navigator.push(context, _createSmoothRoute(PaymentScreen(fasilitasId: id, itemName: itemName, pricePerUnit: priceDouble, fasilitasImage: foto)));
  }
  void _navigateToNotification() {
    Navigator.push(context, _createSmoothRoute(NotificationScreen()));
  }

  Route _createSmoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: Duration(milliseconds: 400),
    );
  }

  Future<void> _contactAdmin() async {
    final Uri url = Uri.parse("https://wa.me/6283492468871");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal membuka WhatsApp")));
    }
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) return Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover);
    if (path.startsWith('http')) return Image.network(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.grey));
    return Image.asset(path, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Icon(Icons.image, color: Colors.grey));
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
                // 1. HEADER (LOKASI & CUACA SUDAH KEMBALI)
                _buildHeader(),
                
                SizedBox(height: 55), 

                // 2. HASIL PENCARIAN
                if (_searchController.text.isNotEmpty) ...[
                  Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text("Hasil Pencarian:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  _searchResults.isEmpty 
                    ? Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Tidak ditemukan", style: TextStyle(color: Colors.grey))))
                    : ListView.builder(
                        shrinkWrap: true, physics: NeverScrollableScrollPhysics(), padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10), itemCount: _searchResults.length,
                        itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(bottom: 15), child: _buildCardItem(_searchResults[index], isHorizontal: false)),
                      ),
                ] 
                else ...[
                  // 3. KATEGORI
                  FadeInUp(
                    duration: Duration(milliseconds: 600),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCategoryBtn("Pondok", Icons.house_siding_rounded, () => _navigateToCategory("Pondok")),
                          _buildCategoryBtn("Tenda", Icons.holiday_village_rounded, () => _navigateToCategory("Tenda")),
                          _buildCategoryBtn("Homestay", Icons.home_rounded, () => _navigateToCategory("Homestay")),
                          _buildCategoryBtn("Semua", Icons.all_inclusive_outlined, () => _navigateToCategory("Semua")),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 25),

                  // 4. CAROUSEL BANNER (TETAP ADA)
                  FadeInUp(
                    delay: Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 140.0, autoPlay: true, autoPlayInterval: Duration(seconds: 4), enlargeCenterPage: true, viewportFraction: 0.85, aspectRatio: 16/9,
                            onPageChanged: (index, reason) => setState(() => _currentBannerIndex = index),
                          ),
                          items: _promoBanners.map((banner) {
                            return BouncingButton(
                              onTap: (){}, 
                              child: Container(
                                width: MediaQuery.of(context).size.width, margin: EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: banner['colors'], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: (banner['colors'][0] as Color).withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))]
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                            Text(banner['title'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), SizedBox(height: 5),
                                            Text(banner['subtitle'], style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        ])),
                                      Icon(banner['icon'], color: Colors.white.withOpacity(0.9), size: 45),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: _promoBanners.asMap().entries.map((entry) {
                            return Container(width: 8.0, height: 8.0, margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), decoration: BoxDecoration(shape: BoxShape.circle, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : mainColor).withOpacity(_currentBannerIndex == entry.key ? 0.9 : 0.2)));
                        }).toList()),
                      ],
                    ),
                  ),

                  SizedBox(height: 15),

                  // 5. REKOMENDASI & POPULER (TETAP ADA)
                  if (_recommendations.isNotEmpty) ...[
                    FadeInRight(child: _buildSectionTitle("Rekomendasi Pilihan ✨", onSeeAll: _navigateToSeeAll)),
                    SizedBox(height: 15),
                    SizedBox(height: 270, child: ListView.builder(scrollDirection: Axis.horizontal, padding: EdgeInsets.only(left: 24, right: 10), itemCount: _recommendations.length, itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(right: 16), child: FadeInRight(delay: Duration(milliseconds: index * 100), child: _buildCardItem(_recommendations[index], isHorizontal: true))))),
                    SizedBox(height: 25),
                  ],
                  if (_populars.isNotEmpty) ...[
                    FadeInUp(child: _buildSectionTitle("Fasilitas Populer 🔥")),
                    SizedBox(height: 15),
                    ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), padding: EdgeInsets.symmetric(horizontal: 24), itemCount: _populars.length, itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(bottom: 15), child: FadeInUp(delay: Duration(milliseconds: index * 100), child: _buildCardItem(_populars[index], isHorizontal: false)))),
                    SizedBox(height: 25),
                  ],

                  FadeInUp(child: _buildTestimonialSection()),
                  SizedBox(height: 25),
                  
                  // KONTAK ADMIN
                  FadeInUp(child: Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: BouncingButton(onTap: _contactAdmin, child: Container(width: double.infinity, padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Color(0xFF2E3E5C), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Color(0xFF2E3E5C).withOpacity(0.4), blurRadius: 10, offset: Offset(0, 5))]), child: Row(children: [Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle), child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 28)), SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Butuh Bantuan?", style: TextStyle(color: Colors.white70, fontSize: 12)), Text("Hubungi Admin via WhatsApp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))])), Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16)]))))),
                  SizedBox(height: 40),
                ]
              ],
            ),
          ),
    );
  }

  // --- WIDGET HELPER UTAMA ---

  Widget _buildHeader() {
    return Stack(
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
        Positioned(top: -50, left: -50, child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.1))),
        Positioned(top: 50, right: -20, child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1))),
        
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Halo, Pengunjung! 👋", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                        SizedBox(height: 5),
                        Text("BulbulHolidays", style: TextStyle(fontFamily: "Serif", fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                      ],
                    ),
                    BouncingButton(
                      onTap: _navigateToNotification,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.3))),
                        child: Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 25),
                
                // --- BAGIAN CUACA YANG DIKEMBALIKAN ---
                GestureDetector(
                  onTap: _showLocationOptions, // Bisa diklik untuk atur lokasi
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('EEEE, d MMM yyyy', 'id_ID').format(DateTime.now()), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                          ],
                        ),
                        Container(height: 30, width: 1, color: Colors.white30, margin: EdgeInsets.symmetric(horizontal: 12)),
                        Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Text(
                          _weather != null ? "${_weather!['temp_c']}°C" : "...",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.location_on, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                )
                // -------------------------------------
              ],
            ),
          ),
        ),
        
        Positioned(
          bottom: -25, left: 24, right: 24,
          child: Container(
            height: 55,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: Offset(0, 10))]),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              style: TextStyle(color: Colors.black87, fontSize: 15),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search_rounded, color: mainColor, size: 26),
                hintText: "Mau liburan kemana hari ini?",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                suffixIcon: _searchController.text.isNotEmpty ? GestureDetector(onTap: () { _searchController.clear(); _runFilter(''); FocusScope.of(context).unfocus(); }, child: Icon(Icons.close, color: Colors.grey, size: 20)) : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
          if (onSeeAll != null)
            BouncingButton(
              onTap: onSeeAll,
              child: Text("Lihat Semua", style: TextStyle(fontSize: 13, color: mainColor, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryBtn(String label, IconData icon, VoidCallback onTap) {
    return BouncingButton(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60, width: 60, 
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))]),
            child: Icon(icon, color: mainColor, size: 28)
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87))
        ],
      ),
    );
  }

  Widget _buildCardItem(Map<String, dynamic> item, {required bool isHorizontal}) {
    String title = item['nama_fasilitas'] ?? 'Tanpa Nama';
    String price = "Rp ${item['harga']}";
    String? imgUrl = item['foto'];
    int id = item['id'];
    bool isFavorite = _favoriteIds.contains(id.toString());
    double rating = double.tryParse(item['ulasan_avg_rating']?.toString() ?? '0') ?? 0.0;
    String ratingText = rating == 0 ? "Baru" : rating.toStringAsFixed(1);

    return BouncingButton(
      onTap: () => _navigateToPayment(id, title, item['harga'], item['foto']),
      child: Container(
        width: isHorizontal ? 220 : double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)), 
                  child: SizedBox(
                    height: isHorizontal ? 140 : 180, 
                    width: double.infinity, 
                    child: _buildImage(imgUrl)
                  )
                ),
                Positioned(
                  top: 10, right: 10,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(id),
                    child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle), child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey, size: 20)),
                  ),
                ),
                Positioned(
                  bottom: 10, left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [Icon(Icons.star, color: Colors.amber, size: 12), SizedBox(width: 4), Text(ratingText, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))]),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 5),
                  Row(children: [Icon(Icons.location_on, size: 14, color: Colors.grey), SizedBox(width: 4), Text("Pantai Bulbul", style: TextStyle(color: Colors.grey, fontSize: 12))]),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(price, style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w800, fontSize: 15)),
                      Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(10)), child: Text("Pesan", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialSection() {
    if (_testimonials.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Apa Kata Pengunjung? 💬"),
        SizedBox(height: 15),
        SizedBox(
          height: 140,
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
                width: 280,
                margin: EdgeInsets.only(right: 16),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 5))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [CircleAvatar(radius: 14, backgroundColor: Colors.grey[200], child: Icon(Icons.person, size: 16, color: Colors.grey)), SizedBox(width: 10), Expanded(child: Text(user, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87), maxLines: 1)), Row(children: List.generate(5, (i) => Icon(i < stars ? Icons.star : Icons.star_border, size: 12, color: Colors.amber)))]),
                    SizedBox(height: 10),
                    Expanded(child: Text('"${text}"', style: TextStyle(fontSize: 13, color: Colors.grey[700], fontStyle: FontStyle.italic), maxLines: 3, overflow: TextOverflow.ellipsis)),
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

// --- WIDGET TOMBOL MEMBAL ---
class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const BouncingButton({required this.child, required this.onTap});

  @override
  _BouncingButtonState createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) { _controller.reverse(); widget.onTap(); },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
}