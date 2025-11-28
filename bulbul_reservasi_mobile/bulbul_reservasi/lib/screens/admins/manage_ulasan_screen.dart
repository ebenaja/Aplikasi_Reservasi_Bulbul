import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/admin_service.dart';

class ManageUlasanScreen extends StatefulWidget {
  const ManageUlasanScreen({super.key});
  @override
  _ManageUlasanScreenState createState() => _ManageUlasanScreenState();
}

class _ManageUlasanScreenState extends State<ManageUlasanScreen> {
  final AdminService _service = AdminService();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      appBar: AppBar(
        title: Text("Semua Ulasan", style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: Color(0xFF50C2C9), 
        foregroundColor: Colors.white
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator()) 
          : _ulasan.isEmpty 
              ? Center(child: Text("Belum ada ulasan masuk"))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _ulasan.length,
                  itemBuilder: (context, index) {
                    final item = _ulasan[index];
                    
                    // PENGAMANAN NULL (Agar tidak crash jika data relasi hilang)
                    final namaUser = item['user'] != null ? item['user']['nama'] : 'User Dihapus';
                    final namaFasilitas = item['fasilitas'] != null ? item['fasilitas']['nama_fasilitas'] : 'Fasilitas Dihapus';
                    final rating = item['rating'] ?? 0;
                    final komentar = item['komentar'] ?? '-';

                    return Card(
                      margin: EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(namaFasilitas, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text("$namaUser :", style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('"$komentar"', style: TextStyle(fontStyle: FontStyle.italic)),
                            SizedBox(height: 5),
                            Row(
                              children: List.generate(5, (i) => Icon(
                                i < rating ? Icons.star : Icons.star_border,
                                size: 16, color: Colors.amber
                              )),
                            )
                          ],
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            // Konfirmasi Hapus
                            bool confirm = await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("Hapus Ulasan"),
                                content: Text("Yakin ingin menghapus ulasan ini?"),
                                actions: [
                                  TextButton(onPressed: ()=>Navigator.pop(ctx, false), child: Text("Batal")),
                                  TextButton(onPressed: ()=>Navigator.pop(ctx, true), child: Text("Hapus", style: TextStyle(color: Colors.red))),
                                ],
                              )
                            ) ?? false;

                            if (confirm) {
                              await _service.deleteUlasan(item['id']);
                              _fetchData();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}