import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/reservasi_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ReservasiTab extends StatefulWidget {
  const ReservasiTab({super.key});

  @override
  _ReservasiTabState createState() => _ReservasiTabState();
}

class _ReservasiTabState extends State<ReservasiTab> {
  final ReservasiService _reservasiService = ReservasiService();
  final Color mainColor = const Color(0xFF50C2C9);
  final Color secondaryColor = const Color(0xFF2E8B91);
  
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() async {
    final data = await _reservasiService.getHistory();
    if (mounted) {
      setState(() {
        _history = data;
        _isLoading = false;
      });
    }
  }

  void _uploadBukti(int reservasiId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      
      showDialog(
        context: context, 
        barrierDismissible: false,
        builder: (ctx) => Center(child: CircularProgressIndicator(color: mainColor))
      );

      bool success = await _reservasiService.uploadBukti(reservasiId, imageFile);
      
      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bukti Terkirim!"), backgroundColor: Colors.green));
        _fetchHistory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal Upload"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Riwayat Pesanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [mainColor, secondaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : _history.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 80, color: Colors.grey[300]),
                    SizedBox(height: 10),
                    Text("Belum ada pesanan", style: TextStyle(color: Colors.grey)),
                  ],
                ))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return _buildHistoryCard(item);
                  },
                ),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    final fasilitas = item['fasilitas'];
    final status = item['status'] ?? 'pending';
    final totalHarga = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(double.tryParse(item['total_harga'].toString()) ?? 0);
    bool isPending = status == 'pending';

    Color statusColor = isPending ? Colors.orange : (status == 'selesai' ? Colors.green : Colors.blue);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[100]!))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fasilitas != null ? fasilitas['nama_fasilitas'] : 'Item dihapus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text(totalHarga, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                )
              ],
            ),
          ),
          if (isPending)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _uploadBukti(item['id']),
                  icon: Icon(Icons.upload_file, size: 18),
                  label: Text("Upload Bukti Bayar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text("Pesanan sedang diproses/selesai", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
        ],
      ),
    );
  }
}