import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bulbul_reservasi/utils/whatsapp_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:animate_do/animate_do.dart'; // Import animasi
import 'package:bulbul_reservasi/widgets/conditional_animation.dart';
import 'package:bulbul_reservasi/screens/users/user_facilities_screen.dart'; 
import 'package:bulbul_reservasi/screens/users/payment_screen.dart';
import 'package:bulbul_reservasi/screens/users/notification_screen.dart'; // Import Notifikasi
import 'package:bulbul_reservasi/services/facility_service.dart';
import 'package:bulbul_reservasi/services/ulasan_service.dart';
import 'package:bulbul_reservasi/services/local_storage_service.dart';
import 'package:bulbul_reservasi/services/weather_service.dart';

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

  // --- Weather & Time ---
  final WeatherService _weatherService = WeatherService();
  Map<String, String>? _weather; // { 'temp_c': '28', 'condition': 'Sunny' }
  Timer? _weatherTimer;
  bool _useGpsForWeather = false;

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
    // Start time & periodic weather updates
    _startTimers();
    _loadWeatherPreference();
  }

  Future<void> _loadWeatherPreference() async {
    try {
      final useGps = await _localStorage.getUseGpsForWeather();
      if (!mounted) return;
      setState(() => _useGpsForWeather = useGps);
      // fetch weather according to preference
      await _updateWeather();
    } catch (e) {
      // ignore
    }
  }

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

          // Logic Data
          _recommendations = _allFacilities.take(3).toList();
          if (_allFacilities.length > 3) {
            _populars = _allFacilities.sublist(3).toList();
          } else {
            _populars = _allFacilities;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error Fetch: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // -------------------------
  // Weather helpers
  // -------------------------
  void _startTimers() {
    // initial weather fetch and periodic update (every 10 minutes)
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
        // fallback to IP-based
        data = await _weatherService.fetchWeather();
      }
    } else {
      data = await _weatherService.fetchWeather();
    }
    if (!mounted) return;
    setState(() {
      _weather = data;
    });
  }

  void refreshFavorites() async {
    final ids = await _localStorage.getFavoriteIds();
    if (mounted) setState(() => _favoriteIds = ids);
  }

  @override
  void dispose() {
    _weatherTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // -------------------------
  // LOKASI & MAP HELPERS
  // -------------------------
  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Layanan lokasi tidak aktif. Aktifkan GPS.')));
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Izin lokasi ditolak')));
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Izin lokasi ditolak permanen. Buka pengaturan aplikasi.')));
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi: $e')));
      return null;
    }
  }

  Future<void> _openMap() async {
    final pos = await _determinePosition();
    if (pos == null) return;

    final lat = pos.latitude;
    final lon = pos.longitude;

    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuka Google Maps')));
    }
  }

  Future<void> _showLocationOptions() async {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Opsi Lokasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Pilih tindakan untuk lokasi dan cuaca. Mengaktifkan cuaca berbasis GPS akan meminta izin lokasi.'),
              SizedBox(height: 12),
              Row(children: [
                Expanded(child: ElevatedButton.icon(onPressed: () { Navigator.of(ctx).pop(); _openMap(); }, icon: Icon(Icons.map), label: Text('Buka Google Maps'))),
              ]),
              SizedBox(height: 10),
              SwitchListTile(
                title: Text('Gunakan lokasi untuk cuaca'),
                value: _useGpsForWeather,
                subtitle: Text('Lebih akurat, memerlukan izin lokasi'),
                onChanged: (v) async {
                  Navigator.of(ctx).pop();
                  if (v) {
                    // Request permission first
                    final pos = await _determinePosition();
                    if (pos == null) return; // user denied
                  }
                  await _localStorage.setUseGpsForWeather(v);
                  if (!mounted) return;
                  setState(() => _useGpsForWeather = v);
                  await _updateWeather();
                },
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      }
    );
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

  // --- NAVIGASI SMOOTH ---
  void _navigateToCategory(String categoryName) {
    Navigator.push(context, _createSmoothRoute(UserFacilitiesScreen(category: categoryName)))
        .then((_) => refreshFavorites());
  }

  void _navigateToSeeAll() {
    Navigator.push(context, _createSmoothRoute(UserFacilitiesScreen(category: "Semua")))
        .then((_) => refreshFavorites());
  }

  void _navigateToPayment(int id, String itemName, var price) {
    double priceDouble = double.tryParse(price.toString()) ?? 0.0;
    Navigator.push(context, _createSmoothRoute(PaymentScreen(fasilitasId: id, itemName: itemName, pricePerUnit: priceDouble)));
  }

  void _navigateToNotification() {
    Navigator.push(context, _createSmoothRoute(NotificationScreen()));
  }

  Route _createSmoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Slide dari kanan
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: Duration(milliseconds: 400),
    );
  }

  Future<void> _contactAdmin() async {
    const String phoneNumber = '6282286250726'; // Ganti dengan nomor admin (format internasional tanpa +)
    await WhatsAppHelper.openWhatsApp(context: context, phone: phoneNumber, message: 'Halo Admin, saya butuh bantuan terkait reservasi.');
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
                // 1. HEADER MEWAH & SEARCH
                _buildHeader(),
                
                SizedBox(height: 55), // Jarak kompensasi Search Bar

                // 2. HASIL PENCARIAN (JIKA ADA)
                if (_searchController.text.isNotEmpty) ...[
                  Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text("Hasil Pencarian:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  _searchResults.isEmpty 
                    ? Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Tidak ditemukan", style: TextStyle(color: Colors.grey))))
                    : ListView.builder(
                        shrinkWrap: true, physics: NeverScrollableScrollPhysics(), padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10), itemCount: _searchResults.length,
                        itemBuilder: (context, index) => ConditionalAnimation(child: Padding(padding: const EdgeInsets.only(bottom: 15), child: _buildCardItem(_searchResults[index], isHorizontal: false))),
                      ),
                ] 
                else ...[
                  // 3. KATEGORI ANIMASI
                  ConditionalAnimation(
                    duration: Duration(milliseconds: 600),
                    child: Padding(
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
                  ),
                  
                  SizedBox(height: 25),

                  // 4. BANNER SPESIAL (Biar gak sepi)
                  ConditionalAnimation(
                    delay: Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrangeAccent]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 5))]
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Liburan Seru! 🏖️", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  SizedBox(height: 5),
                                  Text("Diskon 20% untuk pemesanan Pondok di hari kerja.", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(Icons.discount_outlined, color: Colors.white, size: 40),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 25),

                  // 5. REKOMENDASI (PROMO)
                  if (_recommendations.isNotEmpty) ...[
                    ConditionalAnimation(child: _buildSectionTitle("Rekomendasi Pilihan ✨", onSeeAll: _navigateToSeeAll), type: AnimationType.fadeRight),
                    SizedBox(height: 15),
                    SizedBox(
                      height: 270, 
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal, 
                        padding: EdgeInsets.only(left: 24, right: 10), 
                        itemCount: _recommendations.length, 
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 16), 
                          child: ConditionalAnimation(delay: Duration(milliseconds: index * 100), child: _buildCardItem(_recommendations[index], isHorizontal: true), type: AnimationType.fadeRight)
                        )
                      )
                    ),
                    SizedBox(height: 25),
                  ],
                  
                  // 6. FASILITAS POPULER
                  if (_populars.isNotEmpty) ...[
                    ConditionalAnimation(child: _buildSectionTitle("Fasilitas Populer 🔥")),
                    SizedBox(height: 15),
                    ListView.builder(
                      shrinkWrap: true, 
                      physics: NeverScrollableScrollPhysics(), 
                      padding: EdgeInsets.symmetric(horizontal: 24), 
                      itemCount: _populars.length, 
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 15), 
                        child: ConditionalAnimation(delay: Duration(milliseconds: index * 100), child: _buildCardItem(_populars[index], isHorizontal: false))
                      )
                    ),
                    SizedBox(height: 25),
                  ],

                  // 7. TESTIMONI
                  ConditionalAnimation(child: _buildTestimonialSection()),
                  SizedBox(height: 25),

                  // 8. KONTAK ADMIN (Floating Style)
                  ConditionalAnimation(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24), 
                      child: BouncingButton(
                        onTap: _contactAdmin,
                        child: Container(
                          width: double.infinity, padding: EdgeInsets.all(16), 
                          decoration: BoxDecoration(color: Color(0xFF2E3E5C), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Color(0xFF2E3E5C).withOpacity(0.4), blurRadius: 10, offset: Offset(0, 5))]), 
                          child: Row(
                            children: [
                              Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle), child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 28)),
                              SizedBox(width: 15), 
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Butuh Bantuan?", style: TextStyle(color: Colors.white70, fontSize: 12)), Text("Hubungi Admin via WhatsApp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))])), 
                              Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16)
                            ]
                          )
                        ),
                      )
                    ),
                  ),
                  
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
        // Motif Dekorasi Bulat
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
                    // TOMBOL NOTIFIKASI AKTIF
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
                // INFO CUACA & TANGGAL (Simplified)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tanggal
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat('EEEE').format(DateTime.now()), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(DateFormat('d MMMM yyyy').format(DateTime.now()), style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11)),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Pemisah vertikal
                      Container(width: 1, height: 35, color: Colors.white24),
                      const SizedBox(width: 12),
                      // Cuaca + Tombol Lokasi
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _weather != null ? "${_weather!['temp_c']}°C ${_weather!['condition']}" : "Memuat cuaca...",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Tombol buka opsi lokasi (Maps + pengaturan cuaca GPS)
                            GestureDetector(
                              onTap: _showLocationOptions,
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                                child: Icon(Icons.location_on, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        
        // SEARCH BAR
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
              onTap: onSeeAll!,
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
      onTap: () => _navigateToPayment(id, title, item['harga']),
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
                    child: (imgUrl != null && imgUrl.isNotEmpty)
                      ? (imgUrl.startsWith('http') 
                          ? Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover))
                          : Image.asset(imgUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover)))
                      : Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover)
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
              return Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Container(
                  width: 280,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 5))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [CircleAvatar(radius: 14, backgroundColor: Colors.grey[200], child: Icon(Icons.person, size: 16, color: Colors.grey)), SizedBox(width: 10), Expanded(child: Text(review['user']?['nama'] ?? 'Pengunjung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1)), Row(children: List.generate(5, (i) => Icon(i < (review['rating'] ?? 5) ? Icons.star : Icons.star_border, size: 14, color: Colors.amber)))]),
                      SizedBox(height: 10),
                      Expanded(child: Text('"${review['komentar'] ?? ''}"', style: TextStyle(fontSize: 13, color: Colors.grey[700], fontStyle: FontStyle.italic), maxLines: 3, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- WIDGET TOMBOL MEMBAL (ANIMASI PRESS) ---
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
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}