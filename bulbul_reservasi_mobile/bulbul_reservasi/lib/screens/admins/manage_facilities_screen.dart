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

  // AMBIL DATA DARI DATABASE (BUKAN DUMMY)
  void _fetchData() async {
    final data = await _facilityService.getFacilities();
    setState(() {
      _facilities = data;
      _isLoading = false;
    });
  }

  // HELPER TAMPILKAN GAMBAR ASET
  Widget _buildImageDisplay(String? path) {
    if (path == null || path.isEmpty) {
      return Icon(Icons.image, color: Colors.grey, size: 30);
    }
    // Asumsi path yang disimpan di DB adalah string aset: "assets/images/pondok.jpg"
    return Image.asset(
      path, 
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.broken_image, color: Colors.red);
      },
    );
  }

  // FORM DIALOG (KONEK KE API)
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
        title: Text(item == null ? "Tambah Fasilitas" : "Edit Fasilitas"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: namaCtrl, decoration: InputDecoration(labelText: "Nama Fasilitas")),
              TextField(controller: deskripsiCtrl, decoration: InputDecoration(labelText: "Deskripsi Singkat")),
              TextField(controller: hargaCtrl, decoration: InputDecoration(labelText: "Harga (Rp)"), keyboardType: TextInputType.number),
              TextField(controller: stokCtrl, decoration: InputDecoration(labelText: "Stok"), keyboardType: TextInputType.number),
              TextField(controller: statusCtrl, decoration: InputDecoration(labelText: "Status (tersedia/disewa)")),
              // Input Manual Path Aset
              TextField(
                controller: fotoCtrl, 
                decoration: InputDecoration(
                  labelText: "Path Foto Aset",
                  hintText: "assets/images/nama_file.jpg"
                )
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () async {
              // 1. SIAPKAN DATA UNTUK DIKIRIM KE SERVER
              Map<String, dynamic> data = {
                'nama_fasilitas': namaCtrl.text,
                'deskripsi': deskripsiCtrl.text,
                'harga': hargaCtrl.text,
                'stok': stokCtrl.text,
                'status': statusCtrl.text,
                'foto': fotoCtrl.text, // Kirim string path aset
              };

              // 2. PANGGIL SERVICE API (ADD/UPDATE)
              bool success;
              // Karena service kita pakai MultipartRequest untuk upload, 
              // kita perlu sesuaikan service agar bisa terima data tanpa File fisik jika cuma kirim string path.
              // TAPI, cara termudah tanpa ubah service yang kompleks adalah:
              // Pastikan FacilityService.dart Anda mendukung pengiriman 'foto' sebagai text field biasa jika imageFile null.
              
              // SEMENTARA: Kita pakai logika addFacility yang sudah ada, tapi parameternya null untuk file gambar.
              // (Pastikan FacilityService Anda sudah diupdate seperti instruksi sebelumnya agar tidak error null)
              
              if (item == null) {
                success = await _facilityService.addFacility(data, null); // null image file
              } else {
                success = await _facilityService.updateFacility(item['id'], data, null);
              }

              if (success) {
                Navigator.pop(context);
                _fetchData(); // Refresh data dari server
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Berhasil disimpan ke Database!"), backgroundColor: Colors.green));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan. Cek koneksi/server."), backgroundColor: Colors.red));
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
    bool success = await _facilityService.deleteFacility(id);
    if (success) {
      _fetchData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data Dihapus"), backgroundColor: Colors.red));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus"), backgroundColor: Colors.grey));
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainColor,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showFormDialog(),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _facilities.isEmpty
              ? Center(child: Text("Belum ada data. Silakan tambah."))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _facilities.length,
                  itemBuilder: (context, index) {
                    final item = _facilities[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _buildImageDisplay(item['foto']),
                          ),
                        ),
                        title: Text(item['nama_fasilitas'] ?? '-', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Rp ${item['harga']} | Stok: ${item['stok']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showFormDialog(item: item)),
                            IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteItem(item['id'])),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}