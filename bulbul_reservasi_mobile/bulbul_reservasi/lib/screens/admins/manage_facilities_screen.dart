import 'package:flutter/material.dart';

class ManageFacilitiesScreen extends StatefulWidget {
  @override
  _ManageFacilitiesScreenState createState() => _ManageFacilitiesScreenState();
}

class _ManageFacilitiesScreenState extends State<ManageFacilitiesScreen> {
  final Color mainColor = Color(0xFF50C2C9);

  // Dummy Data Fasilitas
  List<Map<String, dynamic>> facilities = [
    {"id": 1, "name": "Pondok VIP 1", "price": "200000", "status": "Tersedia"},
    {"id": 2, "name": "Tenda Besar", "price": "150000", "status": "Disewa"},
    {"id": 3, "name": "Banana Boat", "price": "35000", "status": "Tersedia"},
  ];

  // Fungsi Tambah/Edit (Dialog)
  void _showFormDialog({Map<String, dynamic>? item}) {
    TextEditingController _nameCtrl = TextEditingController(text: item?['name'] ?? '');
    TextEditingController _priceCtrl = TextEditingController(text: item?['price'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? "Tambah Fasilitas" : "Edit Fasilitas"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: "Nama Fasilitas")),
            TextField(controller: _priceCtrl, decoration: InputDecoration(labelText: "Harga (Rp)"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () {
              // Logika Simpan disini (Nanti connect ke API)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data Berhasil Disimpan!")));
            },
            child: Text("Simpan", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text("Kelola Fasilitas", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainColor,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showFormDialog(), // Tambah Baru
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: facilities.length,
        itemBuilder: (context, index) {
          final item = facilities[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: mainColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.house_siding, color: mainColor),
              ),
              title: Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Rp ${item['price']} - ${item['status']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showFormDialog(item: item),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Logika Hapus
                      setState(() { facilities.removeAt(index); });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}