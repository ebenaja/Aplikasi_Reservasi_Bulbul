import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/facility_service.dart';

class ManageFacilitiesScreen extends StatefulWidget {
  const ManageFacilitiesScreen({super.key});

  @override
  _ManageFacilitiesScreenState createState() => _ManageFacilitiesScreenState();
}

class _ManageFacilitiesScreenState extends State<ManageFacilitiesScreen> {
  final FacilityService _facilityService = FacilityService();
  
  // Palette Warna
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  final Color bgPage = const Color(0xFFF5F7FA);

  List<dynamic> _facilities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final data = await _facilityService.getFacilities();
    if (mounted) {
      setState(() {
        _facilities = data;
        _isLoading = false;
      });
    }
  }

  // --- HELPER STYLE INPUT ---
  InputDecoration _cleanInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: mainColor, size: 20),
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: mainColor, width: 1.5)),
    );
  }

  Widget _buildImageDisplay(String? path) {
    if (path == null || path.isEmpty) {
      return Container(color: Colors.grey[200], child: Icon(Icons.image, color: Colors.grey, size: 50));
    }
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (_,__,___)=> Icon(Icons.broken_image, color: Colors.grey));
    }
    return Image.asset(path, fit: BoxFit.cover, errorBuilder: (_,__,___) => Image.asset('assets/images/pantai_landingscreens.jpg', fit: BoxFit.cover));
  }

  // --- DIALOG FORM ---
  void _showFormDialog({Map<String, dynamic>? item}) {
    final namaCtrl = TextEditingController(text: item?['nama_fasilitas'] ?? '');
    final deskripsiCtrl = TextEditingController(text: item?['deskripsi'] ?? '');
    final hargaCtrl = TextEditingController(text: item?['harga']?.toString() ?? '');
    final stokCtrl = TextEditingController(text: item?['stok']?.toString() ?? '1');
    final statusCtrl = TextEditingController(text: item?['status'] ?? 'tersedia');
    final fotoCtrl = TextEditingController(text: item?['foto'] ?? '');
    
    bool isPromo = (item?['is_promo'] == 1 || item?['is_promo'] == true);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: mainColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(item == null ? Icons.add : Icons.edit, color: mainColor)),
                  SizedBox(width: 10),
                  Text(item == null ? "Tambah Fasilitas" : "Edit Fasilitas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    TextField(controller: namaCtrl, decoration: _cleanInputDecoration("Nama Fasilitas", Icons.label_outline)),
                    SizedBox(height: 15),
                    TextField(controller: deskripsiCtrl, decoration: _cleanInputDecoration("Deskripsi", Icons.description_outlined), maxLines: 2),
                    SizedBox(height: 15),
                    TextField(controller: hargaCtrl, decoration: _cleanInputDecoration("Harga (Rp)", Icons.monetization_on_outlined), keyboardType: TextInputType.number),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: stokCtrl, decoration: _cleanInputDecoration("Stok", Icons.inventory_2_outlined), keyboardType: TextInputType.number)),
                        SizedBox(width: 10),
                        Expanded(child: TextField(controller: statusCtrl, decoration: _cleanInputDecoration("Status", Icons.info_outline))),
                      ],
                    ),
                    SizedBox(height: 15),
                    TextField(controller: fotoCtrl, decoration: _cleanInputDecoration("Path Foto", Icons.image_outlined)),
                    
                    SizedBox(height: 20),
                    
                    // --- SWITCH PROMO CARD ---
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: isPromo ? Colors.orange[50] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isPromo ? Colors.orange : Colors.grey[300]!)
                      ),
                      child: SwitchListTile(
                        title: Text("Promo Akhir Pekan?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isPromo ? Colors.orange[800] : Colors.black87)),
                        subtitle: Text("Tampilkan di slider halaman depan.", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        value: isPromo,
                        activeThumbColor: Colors.orange,
                        secondary: Icon(Icons.local_fire_department_rounded, color: isPromo ? Colors.orange : Colors.grey),
                        onChanged: (val) {
                          setStateDialog(() {
                            isPromo = val;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        child: Text("Batal", style: TextStyle(color: Colors.grey[700])),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        onPressed: () async {
                          Map<String, dynamic> data = {
                            'nama_fasilitas': namaCtrl.text,
                            'deskripsi': deskripsiCtrl.text,
                            'harga': hargaCtrl.text,
                            'stok': stokCtrl.text,
                            'status': statusCtrl.text,
                            'foto': fotoCtrl.text,
                            'is_promo': isPromo ? 1 : 0,
                          };

                          bool success;
                          if (item == null) {
                            success = await _facilityService.addFacility(data, null); 
                          } else {
                            success = await _facilityService.updateFacility(item['id'], data, null);
                          }

                          if (success) {
                            Navigator.pop(context);
                            _fetchData(); 
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Berhasil disimpan!"), backgroundColor: Colors.green));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan."), backgroundColor: Colors.red));
                          }
                        },
                        child: Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            );
          }
        );
      },
    );
  }

  void _deleteItem(int id) async {
    bool confirm = await showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: Text("Konfirmasi Hapus"),
        content: Text("Yakin ingin menghapus fasilitas ini permanen?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(ctx, false), child: Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: ()=>Navigator.pop(ctx, true), 
            child: Text("Hapus", style: TextStyle(color: Colors.white))
          ),
        ],
      )
    ) ?? false;

    if (confirm) {
      if (await _facilityService.deleteFacility(id)) {
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data Berhasil Dihapus"), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      // HEADER GRADIENT
      appBar: AppBar(
        title: Text("Kelola Fasilitas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
      ),
      // FAB MODERN
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: mainColor,
        icon: Icon(Icons.add_rounded, color: Colors.white),
        label: Text("Tambah Baru", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showFormDialog(),
        elevation: 4,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _facilities.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.inventory_2_outlined, size: 45, color: Colors.blue[300]),
                        ),
                        SizedBox(height: 20),
                        Text("Belum Ada Fasilitas", style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Tambahkan fasilitas baru untuk memulai", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _facilities.length,
                  itemBuilder: (context, index) => _buildAdminCard(_facilities[index]),
                ),
    );
  }

  // --- CARD ADMIN YANG KEREN ---
  Widget _buildAdminCard(Map<String, dynamic> item) {
    bool isPromo = (item['is_promo'] == 1 || item['is_promo'] == true);
    bool isAvailable = (item['status'] == 'tersedia');

    return Container(
      margin: EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: Offset(0, 4))],
        // Border oranye tebal jika promo
        border: isPromo ? Border.all(color: Colors.orange, width: 2) : Border.all(color: Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BAGIAN GAMBAR
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(height: 160, width: double.infinity, child: _buildImageDisplay(item['foto'])),
              ),
              
              // Gradient Overlay untuk teks di atas gambar
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.transparent]
                    )
                  ),
                ),
              ),

              // BADGES (Kanan Atas)
              Positioned(
                top: 10, right: 10,
                child: Row(
                  children: [
                    if (isPromo)
                      Container(
                        margin: EdgeInsets.only(right: 5),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                        child: Row(
                          children: [
                            Icon(Icons.local_fire_department, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text("PROMO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isAvailable ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                      ),
                      child: Text(item['status'] ?? '-', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // STOK (Kiri Atas)
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                  child: Text("Stok: ${item['stok']}", style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
            ],
          ),
          
          // BAGIAN KONTEN
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['nama_fasilitas'] ?? 'Tanpa Nama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 5),
                Text("Rp ${item['harga']}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: mainColor)),
                SizedBox(height: 8),
                Text(
                  item['deskripsi'] ?? '-', 
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.3),
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis
                ),
                SizedBox(height: 15),
                Divider(height: 1, color: Colors.grey[200]),
                SizedBox(height: 15),
                
                // TOMBOL AKSI (Full Width Row)
                Row(
                  children: [
                    // Tombol Edit
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.edit_rounded, size: 16),
                          label: Text("Edit"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[50],
                            foregroundColor: Colors.blue[700],
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                          ),
                          onPressed: () => _showFormDialog(item: item),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Tombol Hapus
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.delete_rounded, size: 16),
                          label: Text("Hapus"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red[700],
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                          ),
                          onPressed: () => _deleteItem(item['id']),
                        ),
                      ),
                    ),
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