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
  //final String baseUrl = 'http://10.0.2.2:8000/api';
  final String baseUrl = 'http://172.27.81.234:8000/api';

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
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';
      String paymentUrl = baseUrl.replaceAll('api', 'api/pembayaran');

      var uri = Uri.parse(paymentUrl);
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['reservasi_id'] = reservasiId.toString();
      request.files.add(await http.MultipartFile.fromPath('bukti', imageFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 201;
    } catch (e) {
      print("Error Upload: $e");
      return false;
    }
  }

  // ========================================================================
  // 4. KONFIRMASI MANUAL (TEXT / REFERENSI) - TAMBAHAN BARU
  // ========================================================================
  Future<bool> konfirmasiManual(int reservasiId, String catatan) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';
      String paymentUrl = baseUrl.replaceAll('api', 'api/pembayaran');

      final response = await http.post(
        Uri.parse(paymentUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // Kita kirim teks sebagai 'bukti' (Backend harus support string)
        body: jsonEncode({
          'reservasi_id': reservasiId,
          'bukti': "MANUAL: $catatan", 
          'is_manual': true // Penanda buat backend (opsional)
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error Konfirmasi Manual: $e");
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