import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Import Animasi
import 'package:intl/intl.dart'; // Import untuk format tanggal
import 'package:bulbul_reservasi/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _service = NotificationService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Ambil Data dari API
  Future<void> _fetchData() async {
    final data = await _service.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  // Helper Format Tanggal
  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt); // Contoh: 12 Dec 2025, 10:30
    } catch (e) {
      return dateStr.substring(0, 10); // Fallback jika gagal parse
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      appBar: AppBar(
        title: FadeInDown(
          child: Text("Notifikasi", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF50C2C9)))
          : RefreshIndicator( // FITUR BARU: Tarik untuk refresh
              onRefresh: _fetchData,
              color: Color(0xFF50C2C9),
              child: _notifications.isEmpty
                  ? Center(
                      child: FadeInUp(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                            SizedBox(height: 15),
                            Text("Belum ada notifikasi", style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(20),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final item = _notifications[index];
                        
                        // Logika Warna Ikon
                        Color iconColor = Color(0xFF50C2C9); // Default Tosca
                        IconData iconData = Icons.notifications;

                        String tipe = item['tipe'] ?? 'info';

                        if (tipe == 'promo') {
                          iconColor = Colors.orange;
                          iconData = Icons.discount;
                        } else if (tipe == 'warning') {
                          iconColor = Colors.redAccent;
                          iconData = Icons.warning_amber_rounded;
                        }

                        // --- ANIMASI LIST ITEM (Satu per satu) ---
                        return FadeInUp(
                          delay: Duration(milliseconds: index * 100), // Delay bertahap
                          child: Container(
                            margin: EdgeInsets.only(bottom: 15),
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))]
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ikon Bulat
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                                  child: Icon(iconData, color: iconColor, size: 24),
                                ),
                                SizedBox(width: 15),
                                
                                // Teks Konten
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['judul'] ?? 'Info', // Null safety
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            _formatDate(item['created_at']), // Format tanggal rapi
                                            style: TextStyle(fontSize: 10, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        item['pesan'] ?? '', 
                                        style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4)
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}