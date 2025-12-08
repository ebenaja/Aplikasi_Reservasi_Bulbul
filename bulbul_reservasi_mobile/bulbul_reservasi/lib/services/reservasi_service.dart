import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReservasiService {
  // ------------------------------------------------------------------------
  // BASE URL
  // Gunakan 10.0.2.2 jika pakai Emulator
  // Gunakan IP Laptop (misal 192.168.1.10) jika pakai HP Fisik
  // ------------------------------------------------------------------------
  final String baseUrl = 'http://10.0.2.2:8000/api';

  // ========================================================================
  // 1. BUAT RESERVASI
  // Mengembalikan Map agar PaymentScreen bisa dapat ID & Pesan Error
  // ========================================================================
  Future<Map<String, dynamic>> createReservasi(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {'success': false, 'message': 'Sesi habis, silakan login ulang.'};
    }

    try {
      print("🔵 Mengirim Data Reservasi: $data");

      final response = await http.post(
        Uri.parse('$baseUrl/reservasi'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print("🟢 Status Reservasi: ${response.statusCode}");
      print("🟢 Response Body: ${response.body}");

      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Reservasi Berhasil',
          'data': body['data'] // ID reservasi ada di sini
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Gagal membuat reservasi.'
        };
      }
    } catch (e) {
      print("🔴 Error Create Reservasi: $e");
      return {'success': false, 'message': 'Koneksi Error: $e'};
    }
  }

  // ========================================================================
  // 2. AMBIL RIWAYAT (HISTORY)
  // ========================================================================
  Future<List<dynamic>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservasi/history'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? [];
      } else {
        print("🔴 Gagal Ambil History: ${response.body}");
      }
    } catch (e) {
      print("🔴 Error Get History: $e");
    }
    return [];
  }

  // ========================================================================
  // 3. UPLOAD BUKTI PEMBAYARAN (GAMBAR)
  // ========================================================================
  Future<bool> uploadBukti(int reservasiId, File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return false;

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/pembayaran'));

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['reservasi_id'] = reservasiId.toString();
      request.fields['status'] = 'menunggu';

      // Attach File Gambar
      request.files.add(await http.MultipartFile.fromPath(
        'bukti',
        imageFile.path,
      ));

      print("🔵 Uploading Bukti...");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("🟢 Status Upload: ${response.statusCode}");
      print("🟢 Body Upload: ${response.body}");

      return (response.statusCode == 201 || response.statusCode == 200);
    } catch (e) {
      print("🔴 Error Upload: $e");
      return false;
    }
  }

  // ========================================================================
  // 4. KONFIRMASI PEMBAYARAN (TEXT NO. REFERENSI)
  // ========================================================================
  Future<bool> konfirmasiPembayaran(int reservasiId, String noReferensi) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pembayaran'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reservasi_id': reservasiId,
          'bukti': noReferensi,
          'status': 'menunggu'
        }),
      );

      print("🟢 Status Konfirmasi: ${response.statusCode}");
      return (response.statusCode == 201 || response.statusCode == 200);
    } catch (e) {
      print("🔴 Error Konfirmasi: $e");
      return false;
    }
  }

  // ========================================================================
  // 5. BATALKAN RESERVASI
  // ========================================================================
  Future<bool> cancelReservasi(int reservasiId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) return false;

    try {
      // Pastikan route ini ada di Laravel: Route::post('/reservasi/{id}/cancel', ...)
      final response = await http.post(
        Uri.parse('$baseUrl/reservasi/$reservasiId/cancel'), 
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print("🟢 Status Cancel: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("🔴 Error Cancel: $e");
      return false;
    }
  }
}