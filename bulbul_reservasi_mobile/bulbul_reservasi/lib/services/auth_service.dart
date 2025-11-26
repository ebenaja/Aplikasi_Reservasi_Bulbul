import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // --------------------------------------------------------------------------
  // KONFIGURASI URL API
  // --------------------------------------------------------------------------
  // Jika menggunakan Emulator Android, gunakan: 'http://10.0.2.2:8000/api'
  // Jika menggunakan HP Fisik (USB/Wifi), gunakan IP Laptop: 'http://192.168.x.x:8000/api'
  // --------------------------------------------------------------------------
  final String baseUrl = 'http://10.0.2.2:8000/api'; 

  // --- 1. LOGIN USER & ADMIN ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json', // Agar Laravel tahu kita minta JSON
        },
        body: {
          'email': email,
          'password': password,
        },
      );

      // Cek Respon dari Server
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ASUMSI STRUKTUR JSON DARI BACKEND LARAVEL:
        // {
        //    "message": "Login successful",
        //    "token": "eyJhbGciOiJIUzI1Ni...",
        //    "user": {
        //        "id": 1,
        //        "name": "Admin Ganteng",
        //        "email": "admin@bulbul.com",
        //        "role": "admin"  <-- Backend harus mengirim ini (hasil join tabel roles)
        //    }
        // }

        String token = data['token'];
        Map<String, dynamic> user = data['user'];

        // Simpan data penting ke SharedPreferences agar user tidak perlu login ulang
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', user['name']);
        await prefs.setString('user_role', user['role']); // Simpan role (admin/user)

        return {
          "status": 200,
          "role": user['role'], // Kembalikan role untuk navigasi di LoginScreen
          "name": user['name'],
          "token": token,
        };
      } else {
        // Jika password salah atau email tidak ditemukan
        final errorData = jsonDecode(response.body);
        return {
          "status": response.statusCode,
          "message": errorData['message'] ?? "Email atau password salah",
        };
      }
    } catch (e) {
      // Jika Server Mati / Tidak ada Internet
      print("Error Login: $e");
      return {
        "status": 500,
        "message": "Gagal terhubung ke server. Periksa koneksi internet/API.",
      };
    }
  }

  // --- 2. REGISTER USER BARU ---
  Future<http.Response> register(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, // Laravel biasanya butuh konfirmasi
          // 'role_id': '2' // Optional: Jika backend tidak otomatis set role user
        },
      );
      
      return response;
    } catch (e) {
      print("Error Register: $e");
      // Kembalikan response error buatan jika koneksi gagal
      return http.Response('{"message": "Koneksi error"}', 500);
    }
  }

  // --- 3. LOGOUT ---
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('$baseUrl/logout');

      // Kirim request logout ke server (untuk menghapus token di database)
      await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Wajib kirim token
        },
      );

      // Hapus data di aplikasi
      await prefs.clear();
      return true;

    } catch (e) {
      print("Error Logout: $e");
      // Tetap hapus lokal data meski server error, agar user bisa keluar
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return false;
    }
  }

  // --- 4. CEK APAKAH SEDANG LOGIN ---
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }
}