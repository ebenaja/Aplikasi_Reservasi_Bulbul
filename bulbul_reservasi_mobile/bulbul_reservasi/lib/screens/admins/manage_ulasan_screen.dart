import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/admin_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

class ManageUlasanScreen extends StatefulWidget {
  const ManageUlasanScreen({super.key});
  @override
  _ManageUlasanScreenState createState() => _ManageUlasanScreenState();
}

class _ManageUlasanScreenState extends State<ManageUlasanScreen> {
  final AdminService _service = AdminService();
  
  // Palette Warna
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  final Color bgPage = const Color(0xFFF5F7FA);

  List<dynamic> _ulasan = [];
  bool _isLoading = true;
  int? _deletingId;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => _isLoading = true);
    final data = await _service.getUlasan();
    if (mounted) {
      setState(() {
        _ulasan = data;
        _isLoading = false;
      });
    }
  }

  // Fungsi Hapus dengan Dialog Keren
  void _deleteReview(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
              child: Icon(Icons.warning_amber_rounded, size: 40, color: Colors.redAccent),
            ),
            SizedBox(height: 15),
            Text("Hapus Ulasan?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text("Ulasan ini akan dihapus permanen dan tidak bisa dikembalikan.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
        actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: Text("Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      )
    ) ?? false;

    if (confirm) {
      setState(() => _deletingId = id);
      try {
        bool success = await _service.deleteUlasan(id);
        if (success) {
          _fetchData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Ulasan berhasil dihapus", style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              )
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Gagal menghapus ulasan", style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.grey[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              )
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $e", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
          );
        }
      } finally {
        if (mounted) setState(() => _deletingId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      // HEADER GRADIENT MENARIK
      body: RefreshIndicator(
        onRefresh: () async => _fetchData(),
        color: mainColor,
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            // HEADER GRADIENT
            SliverAppBar(
              expandedHeight: 220,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mainColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(top: -60, left: -40, child: CircleAvatar(radius: 120, backgroundColor: Colors.white.withOpacity(0.08))),
                      Positioned(bottom: -30, right: -30, child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.08))),
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FadeInDown(child: Text("Manajemen Ulasan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white))),
                              FadeInUp(
                                delay: Duration(milliseconds: 100),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Total Ulasan", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                                        Text("${_ulasan.length}", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                          SizedBox(width: 6),
                                          Text("Rating", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              backgroundColor: mainColor,
              elevation: 0,
              foregroundColor: Colors.white,
            ),
            // CONTENT BODY
            SliverToBoxAdapter(
              child: _isLoading
                ? Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: mainColor)))
                : _ulasan.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.star_border_rounded, size: 50, color: Colors.orange[300]),
                            ),
                            SizedBox(height: 20),
                            Text("Belum Ada Ulasan", style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text("Ulasan dari pengunjung akan muncul di sini", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                            SizedBox(height: 30),
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                                  SizedBox(width: 10),
                                  Expanded(child: Text("Tunggu pengunjung memberikan ulasan terbaik", style: TextStyle(color: Colors.blue[700], fontSize: 12))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _ulasan.length,
                        itemBuilder: (context, index) => FadeInUp(
                          delay: Duration(milliseconds: index * 100),
                          child: _buildReviewCard(_ulasan[index]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET KARTU ULASAN MODERN ---
  Widget _buildReviewCard(Map<String, dynamic> item) {
    final namaUser = item['user'] != null ? item['user']['nama'] : 'User Dihapus';
    final namaFasilitas = item['fasilitas'] != null ? item['fasilitas']['nama_fasilitas'] : 'Fasilitas Dihapus';
    final rating = item['rating'] ?? 0;
    final komentar = item['komentar'] ?? '-';
    final id = item['id'];
    bool isDeleting = _deletingId == id;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER KARTU (Fasilitas & Tombol)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mainColor.withOpacity(0.08), secondaryColor.withOpacity(0.08)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(color: mainColor.withOpacity(0.15), shape: BoxShape.circle),
                        child: Icon(Icons.location_on_outlined, size: 16, color: mainColor),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          namaFasilitas,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tombol Hapus dengan Loading State
                GestureDetector(
                  onTap: isDeleting ? null : () => _deleteReview(id),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(isDeleting ? 0.3 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: isDeleting
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                      : Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                  ),
                )
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RATING BINTANG DENGAN ANIMASI
                Row(
                  children: List.generate(5, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 20,
                        color: Colors.amber,
                      ),
                    );
                  }),
                ),

                SizedBox(height: 14),

                // KOMENTAR (Quote Style)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote_rounded, color: mainColor.withOpacity(0.3), size: 18),
                      SizedBox(height: 4),
                      Text(
                        komentar,
                        style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.5, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14),
                Divider(height: 1, color: Colors.grey[200]),
                SizedBox(height: 14),

                // USER INFO (Footer)
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [mainColor, secondaryColor],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          namaUser.isNotEmpty ? namaUser[0].toUpperCase() : '?',
                          style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namaUser,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)
                          ),
                          Text("Pengunjung Terverifikasi", style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text("✓ Asli", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
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
}