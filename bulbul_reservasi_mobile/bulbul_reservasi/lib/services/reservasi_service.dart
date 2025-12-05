import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReservasiService {
  // BASE URL NORMAL
  final String baseUrl = 'http://10.0.2.2:8000/api';

  // ============================================================
  // 1. FUNGSI BARU: createReservasiWithResponse
  // ============================================================
  Future<Map<String, dynamic>> createReservasiWithResponse(
      Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      return {'success': false, 'message': 'Belum login'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservasi'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Berhasil',
          'data': body['data'] // karena PaymentScreen butuh ID reservasi
        };
      } else if (response.statusCode == 409) {
        // contoh: stok penuh, jadwal bentrok
        return {
          'success': false,
          'message': body['message'] ?? 'Fasilitas penuh!'
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Gagal reservasi'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi Error: $e'};
    }
  }

  // ============================================================
  // 2. FUNGSI LAMA (Tetap Dipertahankan): createReservasi
  // ============================================================
  Future<Map<String, dynamic>> createReservasi(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return {'success': false, 'message': 'Belum login'};

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservasi'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Berhasil',
          'data': responseData['data']
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal reservasi'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi Error: $e'};
    }
  }

  // ============================================================
  // 3. Ambil Riwayat Reservasi
  // ============================================================
  Future<List<dynamic>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) return [];

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
      }
    } catch (e) {
      print("Error History: $e");
    }

    return [];
  }

  // ============================================================
  // 4. Konfirmasi Pembayaran (No Referensi)
  // ============================================================
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

      return (response.statusCode == 200 || response.statusCode == 201);
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // 5. Upload Bukti Pembayaran (Gambar)
  // ============================================================
  Future<bool> uploadBukti(int reservasiId, File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return false;

    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/pembayaran'));

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['reservasi_id'] = reservasiId.toString();
      request.fields['status'] = 'menunggu';

      request.files.add(await http.MultipartFile.fromPath(
        'bukti',
        imageFile.path,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return (response.statusCode == 201 || response.statusCode == 200);
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // 6. Batal Reservasi
  // ============================================================
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

      return response.statusCode == 200;
    } catch (e) {
      print("Error Cancel: $e");
      return false;
    }
  }
}
