import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/admin_service.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Column(
          children: [
            Icon(Icons.warning_amber_rounded, size: 50, color: Colors.redAccent),
            SizedBox(height: 10),
            Text("Hapus Ulasan?", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text("Ulasan ini akan dihapus permanen dan tidak bisa dikembalikan.", textAlign: TextAlign.center),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: Text("Hapus", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      )
    ) ?? false;

    if (confirm) {
      await _service.deleteUlasan(id);
      _fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ulasan berhasil dihapus"), backgroundColor: Colors.redAccent)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      
      // HEADER GRADIENT
      appBar: AppBar(
        title: Text("Kelola Ulasan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white
      ),

      body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: mainColor)) 
          : _ulasan.isEmpty 
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_border_rounded, size: 80, color: Colors.grey[300]),
                    SizedBox(height: 15),
                    Text("Belum ada ulasan masuk.", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: _ulasan.length,
                  itemBuilder: (context, index) => _buildReviewCard(_ulasan[index]),
                ),
    );
  }

  // --- WIDGET KARTU ULASAN MODERN ---
  Widget _buildReviewCard(Map<String, dynamic> item) {
    // PENGAMANAN DATA
    final namaUser = item['user'] != null ? item['user']['nama'] : 'User Dihapus';
    final namaFasilitas = item['fasilitas'] != null ? item['fasilitas']['nama_fasilitas'] : 'Fasilitas Dihapus';
    final rating = item['rating'] ?? 0;
    final komentar = item['komentar'] ?? '-';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER KARTU (Fasilitas & Tombol Hapus)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.place, size: 16, color: mainColor),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          namaFasilitas, 
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tombol Hapus Kecil
                GestureDetector(
                  onTap: () => _deleteReview(item['id']),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete_outline, color: Colors.red, size: 18),
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
                // RATING BINTANG
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 20, 
                      color: Colors.amber
                    );
                  }),
                ),
                
                SizedBox(height: 12),
                
                // KOMENTAR (Quote Style)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[200]!)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote_rounded, color: Colors.grey[400], size: 20),
                      Text(
                        komentar, 
                        style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.4, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15),
                Divider(height: 1, color: Colors.grey[200]),
                SizedBox(height: 15),

                // USER INFO (Footer)
                Row(
                  children: [
                    // Avatar Inisial
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: secondaryColor.withOpacity(0.2),
                      child: Text(
                        namaUser.isNotEmpty ? namaUser[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 12, color: secondaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      namaUser, 
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)
                    ),
                    Spacer(),
                    Text("Pengunjung", style: TextStyle(fontSize: 11, color: Colors.grey)),
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