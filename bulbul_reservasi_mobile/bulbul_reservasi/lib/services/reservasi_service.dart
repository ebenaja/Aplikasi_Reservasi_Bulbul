import 'dart:convert';
import 'dart:io'; // Untuk File gambar
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReservasiService {
  // Ganti IP sesuai device (10.0.2.2 untuk Emulator, 192.168.x.x untuk HP Fisik)
  final String baseUrl = 'http://10.0.2.2:8000/api'; 

  // ===========================================================================
  // 1. BUAT RESERVASI (Create)
  // ===========================================================================
  Future<bool> createReservasi(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/reservasi');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("🔴 Token kosong");
      return false;
    }

    try {
      print("🔵 Kirim Data Reservasi: $data");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print("🔵 Status Code: ${response.statusCode}");
      print("🔵 Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("🔴 Error Create Reservasi: $e");
      return false;
    }
  }

  // ===========================================================================
  // 2. AMBIL HISTORY (Read)
  // ===========================================================================
  Future<List<dynamic>> getHistory() async {
    final url = Uri.parse('$baseUrl/reservasi/history');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return [];

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Sesuaikan dengan format response Laravel Anda (biasanya dibungkus 'data')
        return json['data'] ?? json; 
      }
    } catch (e) {
      print("🔴 Error Get History: $e");
    }
    return [];
  }

  // 3. KONFIRMASI PEMBAYARAN (Tanpa File)
  Future<bool> konfirmasiPembayaran(int reservasiId, String noReferensi) async {
    final url = Uri.parse('$baseUrl/pembayaran'); // Sesuaikan dengan route API
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return false;

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reservasi_id': reservasiId,
          'bukti': noReferensi, // Kirim sebagai string teks
          // Backend harus siap menerima 'bukti' berupa string, bukan file
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error Konfirmasi: $e");
      return false;
    }
  }


  // ===========================================================================
  // 4. UPLOAD BUKTI (File Gambar)
  // ===========================================================================
  Future<bool> uploadBukti(int reservasiId, File imageFile) async {
    final url = Uri.parse('$baseUrl/pembayaran'); // Endpoint sama, metode Multipart
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return false;

    try {
      var request = http.MultipartRequest('POST', url);
      
      // Header Auth
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Data Body
      request.fields['reservasi_id'] = reservasiId.toString();
      
      // File Gambar
      request.files.add(await http.MultipartFile.fromPath(
        'bukti', // Nama field harus 'bukti' sesuai controller Laravel
        imageFile.path
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("🔵 Upload Bukti: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("🔴 Error Upload: $e");
      return false;
    }
  }
}