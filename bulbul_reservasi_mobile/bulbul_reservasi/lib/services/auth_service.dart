import 'dart:convert';
import 'dart:io'; 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Ganti 10.0.2.2 dengan IP Laptop jika pakai HP Fisik
  final String baseUrl = 'http://10.0.2.2:8000/api'; 
  //final String baseUrl = 'http://172.27.81.210:8000/api'; 

  // ==========================================================================
  // 1. LOGIN
  // ==========================================================================
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        String token = data['token'] ?? data['access_token'] ?? '';
        Map<String, dynamic> user = data['user'] ?? data['data']?['user'] ?? {};
        
        if (user.isEmpty && data['name'] != null) user = data; // Fallback

        if (token.isEmpty) return {"status": 500, "message": "Token tidak valid"};

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', user['name'] ?? user['nama'] ?? 'User');
        await prefs.setString('user_email', email);

        String role = "user";
        if (user['role'] != null) {
           if (user['role'] is Map) {
             role = user['role']['nama_role'] ?? 'user';
           } else {
             role = user['role'].toString();
           }
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
        final error = jsonDecode(response.body);
        return {"status": response.statusCode, "message": error['message'] ?? "Login Gagal"};
      }
    } catch (e) {
      return {"status": 500, "message": "Koneksi Error: $e"};
    }
  }

  // ==========================================================================
  // 2. REGISTER (DIPERBAIKI)
  // ==========================================================================
  Future<http.Response> register(String name, String email, String password) async {
    try {
      // PERBAIKAN: Hapus 'url:' dan langsung masukkan Uri.parse
      return await http.post(
        Uri.parse('$baseUrl/register'), 
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name, 
          'email': email, 
          'password': password, 
          'password_confirmation': password
        }),
      );
    } catch (e) {
      return http.Response('{"message": "Gagal koneksi: $e"}', 503);
    }
  }

  // ==========================================================================
  // 3. LOGOUT
  // ==========================================================================
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      await prefs.clear(); // Hapus lokal dulu

      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
        );
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  // ==========================================================================
  // 4. RESET PASSWORD (LUPA PASSWORD)
  // ==========================================================================
  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'new_password': newPassword}),
      );
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message'] ?? 'Gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error'};
    }
  }

  // ==========================================================================
  // 5. UPDATE PROFILE NAME
  // ==========================================================================
  Future<bool> updateProfileName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'name': newName}),
      );

      if (response.statusCode == 200) {
        await prefs.setString('user_name', newName); // Update lokal
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==========================================================================
  // 6. CHANGE PASSWORD
  // ==========================================================================
  Future<Map<String, dynamic>> changePassword(String currentPass, String newPass) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'current_password': currentPass,
          'new_password': newPass,
          'new_password_confirmation': newPass,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password berhasil diubah'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal mengubah password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error'};
    }
  }
}