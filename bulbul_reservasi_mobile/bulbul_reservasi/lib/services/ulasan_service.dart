import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UlasanService {
  // Sesuaikan IP
  final String baseUrl = 'http://10.0.2.2:8000/api';
  //final String baseUrl = 'http://172.27.81.210:8000/api';  

  // 1. Ambil Ulasan Terbaru (Public)
  Future<List<dynamic>> getRecentUlasan() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ulasan-terbaru'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data']; 
      }
      return [];
    } catch (e) {
      print("Error Get Ulasan: $e");
      return [];
    }
  }

  // 2. Kirim Ulasan (Protected)
  Future<bool> kirimUlasan(int fasilitasId, int rating, String komentar) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/ulasan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fasilitas_id': fasilitasId,
          'rating': rating,
          'komentar': komentar,
        }),
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
  }
}