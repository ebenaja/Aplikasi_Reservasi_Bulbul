import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/facility_service.dart';

class ManageFacilitiesScreen extends StatefulWidget {
  const ManageFacilitiesScreen({super.key});

  @override
  _ManageFacilitiesScreenState createState() => _ManageFacilitiesScreenState();
}

class _ManageFacilitiesScreenState extends State<ManageFacilitiesScreen> {
  final FacilityService _facilityService = FacilityService();
  final Color mainColor = Color(0xFF50C2C9);
  
  List<dynamic> _facilities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // AMBIL DATA DARI DATABASE
  void _fetchData() async {
    final data = await _facilityService.getFacilities();
    if (mounted) {
      setState(() {
        _facilities = data;
        _isLoading = false;
      });
    }
  }

  // HELPER TAMPILKAN GAMBAR (Aset / Network)
  Widget _buildImageDisplay(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Icon(Icons.image, color: Colors.grey, size: 40),
      );
    }
    // Cek apakah URL Internet atau Aset Lokal
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (_,__,___)=> Icon(Icons.broken_image));
    }
    return Image.asset(
      path, 
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback ke gambar default jika path salah
        return Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover);
      },
    );
  }

  // --- DIALOG FORM (INPUT DATA) ---
  void _showFormDialog({Map<String, dynamic>? item}) {
    final namaCtrl = TextEditingController(text: item?['nama_fasilitas'] ?? '');
    final deskripsiCtrl = TextEditingController(text: item?['deskripsi'] ?? '');
    final hargaCtrl = TextEditingController(text: item?['harga']?.toString() ?? '');
    final stokCtrl = TextEditingController(text: item?['stok']?.toString() ?? '1');
    final statusCtrl = TextEditingController(text: item?['status'] ?? 'tersedia');
    final fotoCtrl = TextEditingController(text: item?['foto'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(item == null ? "Tambah Fasilitas" : "Edit Fasilitas", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: namaCtrl, decoration: InputDecoration(labelText: "Nama Fasilitas", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              SizedBox(height: 10),
              TextField(controller: deskripsiCtrl, decoration: InputDecoration(labelText: "Deskripsi Singkat", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              SizedBox(height: 10),
              TextField(controller: hargaCtrl, decoration: InputDecoration(labelText: "Harga (Rp)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), keyboardType: TextInputType.number),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: stokCtrl, decoration: InputDecoration(labelText: "Stok", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), keyboardType: TextInputType.number)),
                  SizedBox(width: 10),
                  Expanded(child: TextField(controller: statusCtrl, decoration: InputDecoration(labelText: "Status", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: fotoCtrl, 
                decoration: InputDecoration(
                  labelText: "Path Foto (assets/...)", 
                  hintText: "assets/images/nama_file.jpg",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                )
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              Map<String, dynamic> data = {
                'nama_fasilitas': namaCtrl.text,
                'deskripsi': deskripsiCtrl.text,
                'harga': hargaCtrl.text,
                'stok': stokCtrl.text,
                'status': statusCtrl.text,
                'foto': fotoCtrl.text, 
              };

              bool success;
              // Panggil Service API (Pastikan di backend controller store/update handle input 'foto')
              if (item == null) {
                // Untuk 'addFacility', pastikan service Anda support parameter ke-2 (file) sbg null
                // Jika service Anda masih wajib file, Anda perlu modifikasi service sedikit atau kirim null.
                // Di sini saya asumsikan Anda sudah pakai service versi terakhir yang kita bahas.
                success = await _facilityService.addFacility(data, null); 
              } else {
                success = await _facilityService.updateFacility(item['id'], data, null);
              }

              if (success) {
                Navigator.pop(context);
                _fetchData(); 
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data Berhasil Disimpan!"), backgroundColor: Colors.green));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan."), backgroundColor: Colors.red));
              }
            },
            child: Text("Simpan", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // HAPUS DARI DATABASE
  void _deleteItem(int id) async {
    bool confirm = await showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: Text("Hapus Data"),
        content: Text("Yakin ingin menghapus item ini?"),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(ctx, false), child: Text("Batal")),
          TextButton(onPressed: ()=>Navigator.pop(ctx, true), child: Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      )
    ) ?? false;

    if (confirm) {
      bool success = await _facilityService.deleteFacility(id);
      if (success) {
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data Dihapus"), backgroundColor: Colors.red));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus"), backgroundColor: Colors.grey));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      appBar: AppBar(
        title: Text("Kelola Fasilitas", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainColor,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showFormDialog(),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _facilities.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 60, color: Colors.grey[300]),
                    SizedBox(height: 10),
                    Text("Belum ada data fasilitas.", style: TextStyle(color: Colors.grey)),
                  ],
                ))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _facilities.length,
                  itemBuilder: (context, index) {
                    final item = _facilities[index];
                    return _buildAdminCard(item);
                  },
                ),
    );
  }

  // --- CARD UI YANG LEBIH BAGUS (Mirip User) ---
  Widget _buildAdminCard(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GAMBAR
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  child: _buildImageDisplay(item['foto']),
                ),
              ),
              // Label Status
              Positioned(
                top: 10, right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (item['status'] == 'tersedia') ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(
                    item['status'] ?? '-',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
          
          // KONTEN
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['nama_fasilitas'] ?? 'Tanpa Nama', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text("Stok: ${item['stok']}", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
                SizedBox(height: 5),
                Text(item['deskripsi'] ?? '-', style: TextStyle(color: Colors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 10),
                Divider(),
                
                // FOOTER (HARGA & TOMBOL AKSI)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rp ${item['harga']}", 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainColor)
                    ),
                    Row(
                      children: [
                        // Tombol Edit
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                            onPressed: () => _showFormDialog(item: item),
                            tooltip: "Edit",
                            constraints: BoxConstraints(), // Compact
                            padding: EdgeInsets.all(8),
                          ),
                        ),
                        // Tombol Hapus
                        Container(
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _deleteItem(item['id']),
                            tooltip: "Hapus",
                            constraints: BoxConstraints(),
                            padding: EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}