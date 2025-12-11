import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  // Ganti IP Laptop Anda (Pastikan benar, misal 192.168.x.x atau 10.0.2.2)
  final String baseUrl = 'http://10.0.2.2:8000/api/admin';
  //final String baseUrl = 'http://172.27.81.234:8000/api/admin'; 

  Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET USERS
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body)['data'];
      return [];
    } catch (e) { return []; }
  }

  // DELETE USER
  Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/$id'), headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // --- FUNGSI INI YANG KITA DEBUG ---
  Future<List<dynamic>> getReservations() async {
    try {
      print("🔵 Admin: Request Reservasi ke $baseUrl/reservasi");
      
      final response = await http.get(
        Uri.parse('$baseUrl/reservasi'), 
        headers: await _getHeaders()
      );
      
      print("🟢 Status: ${response.statusCode}");
      print("🟢 Body: ${response.body}"); // Cek apakah data masuk

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return [];
    } catch (e) { 
      print("🔴 Error Admin Reservasi: $e");
      return []; 
    }
  }

  // UPDATE STATUS RESERVASI
  Future<bool> updateStatusReservasi(int id, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservasi/$id/status'), 
        headers: await _getHeaders(),
        body: {'status': status}
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

    // HAPUS RESERVASI (ADMIN)
  Future<bool> deleteReservasi(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reservasi/$id'), 
        headers: await _getHeaders()
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // GET ULASAN
  Future<List<dynamic>> getUlasan() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ulasan'), headers: await _getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return [];
    } catch (e) { return []; }
  }

  // DELETE ULASAN
  Future<bool> deleteUlasan(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/ulasan/$id'), headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // GET STATISTICS
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics'), 
        headers: await _getHeaders()
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return {};
    } catch (e) {
      print("Error Stats: $e");
      return {};
    }
  }
}