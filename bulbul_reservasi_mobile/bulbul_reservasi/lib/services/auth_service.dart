import 'dart:convert';
import 'dart:io'; // Untuk menangani SocketException (Koneksi)
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // --------------------------------------------------------------------------
  // KONFIGURASI URL API
  // --------------------------------------------------------------------------
  // Gunakan 10.0.2.2 jika pakai Emulator Android.
  // Gunakan IP Laptop (misal 192.168.1.x) jika pakai HP Fisik.
  // --------------------------------------------------------------------------
  final String baseUrl = 'http://10.0.2.2:8000/api'; 

  // ==========================================================================
  // 1. FUNGSI LOGIN (REVISI ROBUST / TAHAN BANTING)
  // ==========================================================================
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print("🔵 RESPON SERVER: ${response.body}"); // Cek di Debug Console

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // --- LOGIKA DETEKSI FORMAT JSON (Agar tidak Null) ---
        String token = "";
        Map<String, dynamic> user = {};

        // 1. Cek Token (Bisa 'token', 'access_token', atau di dalam 'data')
        if (data['token'] != null) token = data['token'];
        else if (data['access_token'] != null) token = data['access_token'];
        else if (data['data'] != null && data['data']['token'] != null) token = data['data']['token'];

        // 2. Cek User (Bisa 'user', 'data.user', atau langsung di root)
        if (data['user'] != null) user = data['user'];
        else if (data['data'] != null && data['data']['user'] != null) user = data['data']['user'];
        
        // Jika user kosong, coba cari nama langsung di root (fallback)
        if (user.isEmpty && data['name'] != null) {
          user = {'name': data['name'], 'role': 'user'}; 
        }

        // JIKA TOKEN TIDAK DITEMUKAN
        if (token.isEmpty) {
          return {"status": 500, "message": "Token tidak ditemukan di respon server."};
        }

        // 3. Simpan Data ke HP
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', user['name'] ?? user['nama'] ?? 'User');
        
        // 4. Ambil Role
        String role = "user";
        if (user['role'] != null) role = user['role'].toString();
        else if (user['roles'] != null && user['roles'] is List && (user['roles'] as List).isNotEmpty) {
           // Jika formatnya array roles: [{"name": "admin"}]
           role = user['roles'][0]['name']; 
        }
        // Fallback manual jika role kosong tapi email mengandung 'admin'
        else if (email.toLowerCase().contains('admin')) {
          role = "admin"; 
        }

        await prefs.setString('user_role', role);

        return {
          "status": 200,
          "role": role,
          "name": user['name'] ?? 'User',
          "token": token,
        };

      } else {
        // Error dari server (401/422)
        final errorData = jsonDecode(response.body);
        return {
          "status": response.statusCode,
          "message": errorData['message'] ?? "Email atau password salah",
        };
      }
    } catch (e) {
      if (e is SocketException) {
        return {"status": 503, "message": "Gagal terhubung. Cek server/internet."};
      }
      print("🔴 Error Login: $e");
      return {"status": 500, "message": "Terjadi kesalahan aplikasi."};
    }
  }

  // ==========================================================================
  // 2. FUNGSI REGISTER
  // ==========================================================================
  Future<http.Response> register(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, // Laravel biasanya butuh ini
        }),
      );
      
      return response;
    } catch (e) {
      print("🔴 Error Register: $e");
      return http.Response('{"message": "Gagal terhubung ke server"}', 503);
    }
  }

  // ==========================================================================
  // 3. FUNGSI LOGOUT
  // ==========================================================================
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Hapus data lokal dulu (Prioritas)
      await prefs.clear();

      if (token != null) {
        final url = Uri.parse('$baseUrl/logout');
        // Request hapus token di database
        await http.post(
          url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
      return true;

    } catch (e) {
      print("🔴 Error Logout: $e");
      // Tetap return true agar user bisa keluar dari tampilan aplikasi
      return true; 
    }
  }

  // --- CEK APAKAH SEDANG LOGIN ---
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }
}