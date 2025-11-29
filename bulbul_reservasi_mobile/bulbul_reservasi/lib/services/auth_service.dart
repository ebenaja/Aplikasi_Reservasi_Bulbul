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
  // 1. FUNGSI LOGIN (ROBUST)
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

      print("🔵 RESPON SERVER: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String token = "";
        Map<String, dynamic> user = {};

        // 1. Cek Token
        if (data['token'] != null) {
          token = data['token'];
        } else if (data['access_token'] != null) {
          token = data['access_token'];
        } else if (data['data'] != null && data['data']['token'] != null) {
          token = data['data']['token'];
        }

        // 2. Cek User
        if (data['user'] != null) {
          user = data['user'];
        } else if (data['data'] != null && data['data']['user'] != null) {
          user = data['data']['user'];
        }
        
        if (user.isEmpty && data['name'] != null) {
          user = {'name': data['name'], 'role': 'user'}; 
        }

        if (token.isEmpty) {
          return {"status": 500, "message": "Token tidak ditemukan di respon server."};
        }

        // 3. Simpan Data ke HP
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', user['name'] ?? user['nama'] ?? 'User');
        await prefs.setString('user_email', email); // Simpan email juga untuk profile
        
        // 4. Ambil Role
        String role = "user";
        if (user['role'] != null) {
          role = user['role'].toString();
        } else if (user['roles'] != null && user['roles'] is List && (user['roles'] as List).isNotEmpty) {
           role = user['roles'][0]['name']; 
        } else if (email.toLowerCase().contains('admin')) {
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
          'password_confirmation': password,
        }),
      );
      return response;
    } catch (e) {
      return http.Response('{"message": "Gagal terhubung ke server"}', 503);
    }
  }

  // ==========================================================================
  // 3. FUNGSI UPDATE NAMA (BARU)
  // ==========================================================================
  Future<bool> updateProfileName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/update-profile'); // Pastikan route ini ada di API Laravel

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Kirim Token Auth
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': newName, // Sesuai field database 'users'
        }),
      );

      if (response.statusCode == 200) {
        // Jika sukses di database, update juga di memori HP
        await prefs.setString('user_name', newName);
        return true;
      } else {
        print("Gagal update nama: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error Update Profile: $e");
      return false;
    }
  }

  // ==========================================================================
  // 4. FUNGSI GANTI PASSWORD (BARU)
  // ==========================================================================
  Future<Map<String, dynamic>> changePassword(String currentPass, String newPass) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/change-password'); // Pastikan route ini ada di API Laravel

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'current_password': currentPass,
          'new_password': newPass,
          'new_password_confirmation': newPass, // Laravel biasanya butuh konfirmasi
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password berhasil diubah'};
      } else {
        // Ambil pesan error dari Laravel (misal: Password lama salah)
        String msg = data['message'] ?? 'Gagal mengubah password';
        if (data['errors'] != null) {
          msg = data['errors'].toString();
        }
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi'};
    }
  }

  // ==========================================================================
  // 5. FUNGSI LOGOUT
  // ==========================================================================
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Hapus data lokal
      await prefs.clear();

      if (token != null) {
        final url = Uri.parse('$baseUrl/logout');
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
      return true; 
    }
  }

  // --- CEK APAKAH SEDANG LOGIN ---
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }
}