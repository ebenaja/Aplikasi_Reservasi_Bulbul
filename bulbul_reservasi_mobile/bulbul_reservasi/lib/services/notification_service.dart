import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  // Sesuaikan IP (10.0.2.2 untuk Emulator)
  final String baseUrl = 'http://10.0.2.2:8000/api/notifikasi';
  //final String baseUrl = 'http://172.27.81.234:8000/api/notifikasi'; 

  Future<List<dynamic>> getNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return [];
    } catch (e) {
      print("Error Notif: $e");
      return [];
    }
  }
}