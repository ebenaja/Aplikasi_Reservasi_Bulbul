import 'dart:convert';
import 'dart:io'; // PENTING: Wajib import ini untuk tipe data File
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReservasiService {
  // Sesuaikan IP (10.0.2.2 untuk Emulator, atau IP Laptop untuk HP Fisik)
  final String baseUrl = 'http://10.0.2.2:8000/api/reservasi'; 

  // 1. BUAT RESERVASI (POST)
  Future<bool> createReservasi(Map<String, dynamic> data) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      print("🔵 Mengirim Reservasi: $data");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print("🟢 Status Code: ${response.statusCode}");
      
      if (response.statusCode == 201) {
        return true;
      } else {
        print("🔴 Gagal: ${response.body}");
        return false;
      }
    } catch (e) {
      print("🔴 Error Connection: $e");
      return false;
    }
  }

  // 2. AMBIL RIWAYAT (GET)
  Future<List<dynamic>> getHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      // Panggil endpoint /reservasi/history
      final response = await http.get(
        Uri.parse('$baseUrl/history'), 
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data']; 
      } else {
        print("Gagal ambil history: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error History: $e");
      return [];
    }
  }

// GANTI FUNGSI UPLOAD GAMBAR MENJADI INI:
  Future<bool> konfirmasiPembayaran(int reservasiId, String noReferensi) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      // URL Endpoint Pembayaran
      String paymentUrl = baseUrl.replaceAll('reservasi', 'pembayaran');

      final response = await http.post(
        Uri.parse(paymentUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reservasi_id': reservasiId,
          'bukti': noReferensi, // Kirim nomor referensi sebagai bukti
        }),
      );

      print("Konfirmasi: ${response.body}");

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error Konfirmasi: $e");
      return false;
    }
  }
}