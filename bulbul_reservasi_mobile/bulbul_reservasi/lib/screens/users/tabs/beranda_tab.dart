import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/screens/users/user_facilities_screen.dart';
import 'package:bulbul_reservasi/screens/users/payment_screen.dart';
import 'package:bulbul_reservasi/services/facility_service.dart';
import 'package:bulbul_reservasi/services/ulasan_service.dart';

class BerandaTab extends StatefulWidget {
  const BerandaTab({super.key});

  @override
  _BerandaTabState createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  final Color mainColor = Color(0xFF50C2C9);
  final FacilityService _facilityService = FacilityService();
  final UlasanService _ulasanService = UlasanService();
  
  bool _isLoading = true;

  // List Data dari Database
  List<dynamic> _allFacilities = [];
  List<dynamic> _testimonials = []; 

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    try {
      // Ambil data Fasilitas dan Ulasan secara paralel
      final results = await Future.wait([
        _facilityService.getFacilities(),
        _ulasanService.getRecentUlasan()
      ]);

      if (mounted) {
        setState(() {
          _allFacilities = results[0];
          _testimonials = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error Fetch Data: $e");
    }
  }

  // --- NAVIGASI ---
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
          // 1. HEADER & KATEGORI
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 60, bottom: 30),
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40), 
                bottomRight: Radius.circular(40)
              ),
              boxShadow: [
                BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 10, offset: Offset(0, 5))
              ]
            ),
            child: Column(
              children: [
                Text(
                  "BulbulHolidays", 
                  style: TextStyle(
                    fontFamily: "Serif", 
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white,
                    letterSpacing: 1.2
                  )
                ),
                SizedBox(height: 10),
                Text(
                  "Temukan Tempat Liburan Impianmu", 
                  style: TextStyle(fontSize: 14, color: Colors.white70)
                ),
                
                SizedBox(height: 35),
                
                // BARIS KATEGORI (3 ITEM SEJAJAR)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Jarak merata
                    children: [
                      _buildCategoryButton("Pondok", Icons.bungalow_outlined),
                      _buildCategoryButton("Tenda", Icons.holiday_village_outlined),
                      _buildCategoryButton("Homestay", Icons.house_siding_outlined),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 25),

          // 2. PROMO AKHIR PEKAN
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Promo Akhir Pekan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text("Lihat Semua", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mainColor)),
              ],
            ),
          ),
          SizedBox(height: 15),

          // LIST HORIZONTAL (DATA DARI DATABASE)
          SizedBox(
            height: 240, // Tinggi Card
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: mainColor))
              : _allFacilities.isEmpty 
                  ? Center(child: Text("Belum ada data tersedia", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      // Tampilkan maksimal 5 item di promo
                      itemCount: _allFacilities.take(5).length,
                      itemBuilder: (context, index) {
                        final item = _allFacilities[index];
                        return _buildPromoCard(item);
                      },
                    ),
          ),

          SizedBox(height: 20),

          // TOMBOL VIEW MORE (KE SEMUA DATA)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _navigateToCategory("Semua"), // Menampilkan semua
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 3,
                  shadowColor: mainColor.withOpacity(0.4),
                ),
                child: Text("Lihat Semua Fasilitas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),

          SizedBox(height: 30),

          // 3. KENAPA PILIH BULBULHOLIDAYS?
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(20), 
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Kenapa Pilih BulbulHolidays?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 20),
                  _buildCheckItem("Reservasi Instan & Real-time"),
                  _buildCheckItem("Harga Terjamin Akurat"),
                  _buildCheckItem("Pembayaran Aman & Lengkap"),
                  _buildCheckItem("Fasilitas Terbaik & Terawat"),
                ],
              ),
            ),
          ),

          SizedBox(height: 30),

          // 4. APA KATA PENGUNJUNG?
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(20), 
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Apa Kata Pengunjung?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Icon(Icons.format_quote, color: mainColor.withOpacity(0.5), size: 30)
                    ],
                  ),
                  SizedBox(height: 20),

                  if (_testimonials.isEmpty)
                    Center(child: Text("Belum ada ulasan.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))
                  else
                    ..._testimonials.take(3).map((t) => Column(
                      children: [
                        _buildTestimonialItem(
                          t['user']?['nama'] ?? 'Pengunjung', 
                          t['komentar'] ?? '-', 
                          t['rating'] ?? 5
                        ),
                        Divider(height: 30, color: Colors.grey[200]),
                      ],
                    )),
                ],
              ),
            ),
          ),

          SizedBox(height: 30),

          // 5. KONTAK & LOKASI
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: EdgeInsets.all(25),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(20), 
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Kontak & Lokasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 20),
                  Row(children: [
                    Icon(Icons.location_on, size: 24, color: mainColor), 
                    SizedBox(width: 15), 
                    Expanded(child: Text("Pantai Bulbul, Balige, Kab. Toba, Sumatera Utara", style: TextStyle(color: Colors.grey[800], height: 1.5)))
                  ]),
                  SizedBox(height: 15),
                  Row(children: [
                    Icon(Icons.phone, size: 24, color: mainColor), 
                    SizedBox(width: 15), 
                    Text("083492468871", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500))
                  ]),
                ],
              ),
            ),
          ),

          SizedBox(height: 50), // Padding bawah akhir
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  // 1. TOMBOL KATEGORI (Clean Design)
  Widget _buildCategoryButton(String label, IconData icon) {
    return GestureDetector(
      onTap: () => _navigateToCategory(label),
      child: Column(
        children: [
          Container(
            width: 65, height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4))]
            ),
            child: Icon(icon, color: mainColor, size: 30),
          ),
          SizedBox(height: 10),
          Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  // 2. KARTU PROMO (Desain Konsisten)
  Widget _buildPromoCard(Map<String, dynamic> item) {
    // Parsing Data
    String imgPath = (item['foto'] != null && item['foto'] != '') 
        ? item['foto'] 
        : 'assets/images/pantai_landingscreens.jpg';
    
    String title = item['nama_fasilitas'] ?? 'Tanpa Nama';
    String price = "Rp ${item['harga']}";
    
    // Mengambil Rating Rata-rata (jika ada dari backend)
    String rating = item['ulasan_avg_rating'] != null 
        ? double.parse(item['ulasan_avg_rating'].toString()).toStringAsFixed(1) 
        : "4.8";

    return GestureDetector(
      onTap: () => _navigateToPayment(item['id'], item['nama_fasilitas'], item['harga']),
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: 15, bottom: 10, top: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: Offset(0, 4))]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            Expanded(
              flex: 6, // Proporsi gambar lebih besar
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      imgPath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover),
                    ),
                  ),
                  // Badge Diskon (Opsional/Dummy)
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
                      child: Text("Promo", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text("Pantai Bulbul", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(price, style: TextStyle(fontSize: 14, color: mainColor, fontWeight: FontWeight.bold)),
                        Row(children: [Icon(Icons.star, size: 14, color: Colors.amber), SizedBox(width: 4), Text(rating, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 22, color: mainColor),
          SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildTestimonialItem(String name, String review, int rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 18, backgroundColor: Colors.grey[200], child: Icon(Icons.person, size: 22, color: Colors.grey)), 
            SizedBox(width: 10), 
            Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 14)),
            Spacer(),
            Row(children: List.generate(5, (index) => Icon(index < rating ? Icons.star : Icons.star_border, size: 16, color: Colors.amber))),
          ],
        ),
        SizedBox(height: 8),
        Text(review, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic, height: 1.4)),
      ],
    );
  }
}