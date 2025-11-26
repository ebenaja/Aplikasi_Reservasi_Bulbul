import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // URL API (Sesuaikan nanti)
  final String baseUrl = 'http://10.0.2.2:8000/api'; 

  // --- FUNGSI LOGIN DENGAN CEK ROLE ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    // SEMENTARA: Kita simulasi logic di sini (Hardcode)
    // Nanti ganti dengan request ke API Backend
    
    await Future.delayed(Duration(seconds: 1)); // Simulasi loading

    if (email == "admin@bulbul.com" && password == "admin123") {
      return {
        "status": 200,
        "role": "admin", // KUNCI: Role Admin
        "name": "Admin Pantai",
        "token": "dummy_admin_token"
      };
    } else if (email.isNotEmpty && password.isNotEmpty) {
      return {
        "status": 200,
        "role": "user", // KUNCI: Role User
        "name": email.split('@')[0],
        "token": "dummy_user_token"
      };
    } else {
      return {
        "status": 401,
        "message": "Email atau password salah"
      };
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data sesi
  }
  
  // Fungsi Register tetap sama...
  Future<http.Response> register(String name, String email, String password) async {
    // ... (Kode register lama Anda)
    return http.Response("{}", 200); // Dummy return
  }
}