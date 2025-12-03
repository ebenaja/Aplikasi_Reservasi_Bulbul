import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReservasiService {
  // Ganti IP sesuai Laptop (10.0.2.2 untuk Emulator)
  final String baseUrl = 'http://10.0.2.2:8000/api'; 

  // 1. BUAT RESERVASI (POST)
  Future<Map<String, dynamic>> createReservasi(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/reservasi');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return {'success': false, 'message': 'Belum login'};

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Berhasil', 'data': responseData['data']};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Gagal reservasi'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi Error: $e'};
    }
  }

  // 2. AMBIL RIWAYAT (GET)
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
        return json['data'] ?? []; 
      }
    } catch (e) {
      print("Error History: $e");
    }
    return [];
  }

  // 3. KONFIRMASI PEMBAYARAN (TEXT)
  // Fungsi ini dipanggil di PemesananTab
  Future<bool> konfirmasiPembayaran(int reservasiId, String noReferensi) async {
    final url = Uri.parse('$baseUrl/pembayaran'); 
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
          'bukti': noReferensi, // Kirim teks referensi
          'status': 'menunggu'
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 4. UPLOAD BUKTI (GAMBAR)
  Future<bool> uploadBukti(int reservasiId, File imageFile) async {
    final url = Uri.parse('$baseUrl/pembayaran'); 
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return false;

    try {
      var request = http.MultipartRequest('POST', url);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['reservasi_id'] = reservasiId.toString();
      request.fields['status'] = 'menunggu';
      
      request.files.add(await http.MultipartFile.fromPath(
        'bukti', 
        imageFile.path
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
 
  // 5. BATALKAN RESERVASI
  Future<bool> cancelReservasi(int reservasiId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/reservasi/$reservasiId/cancel'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Gagal Batal: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error Cancel: $e");
      return false;
    }
  }
}