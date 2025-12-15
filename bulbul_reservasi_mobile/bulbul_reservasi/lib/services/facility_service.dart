import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FacilityService {
  final String baseUrl = 'http://10.0.2.2:8000/api/fasilitas';

  Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  // ================= GET =================
  Future<List<dynamic>> getFacilities() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'];
      }
      return [];
    } catch (e) {
      print("Error Get: $e");
      return [];
    }
  }

  // ================= ADD =================
  Future<bool> addFacility(Map<String, dynamic> data, File? imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.headers.addAll(await _getHeaders());

      // Fields utama
      request.fields['nama_fasilitas'] = data['nama_fasilitas'];
      request.fields['deskripsi'] = data['deskripsi'] ?? '';
      request.fields['harga'] = data['harga'].toString();
      request.fields['stok'] = data['stok'].toString();
      request.fields['status'] = data['status'];

      // is_promo → pastikan 1 / 0
      bool isPromo = data['is_promo'] == true || data['is_promo'] == 1;
      request.fields['is_promo'] = isPromo ? "1" : "0";

      // FOTO: File ATAU Asset
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto', imageFile.path),
        );
      } else {
        request.fields['foto'] = data['foto'] ?? '';
      }

      print("🔵 ADD DATA: ${request.fields}");

      var response =
          await http.Response.fromStream(await request.send());

      print("🟢 ADD STATUS: ${response.statusCode} ${response.body}");

      return response.statusCode == 201;
    } catch (e) {
      print("🔴 Error Add: $e");
      return false;
    }
  }

  // ================= UPDATE =================
  Future<bool> updateFacility(
      int id, Map<String, dynamic> data, File? imageFile) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/$id'));
      request.headers.addAll(await _getHeaders());

      request.fields['_method'] = 'PUT';
      request.fields['nama_fasilitas'] = data['nama_fasilitas'];
      request.fields['deskripsi'] = data['deskripsi'] ?? '';
      request.fields['harga'] = data['harga'].toString();
      request.fields['stok'] = data['stok'].toString();
      request.fields['status'] = data['status'];

      bool isPromo = data['is_promo'] == true || data['is_promo'] == 1;
      request.fields['is_promo'] = isPromo ? "1" : "0";

      // FOTO: File baru atau asset lama
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto', imageFile.path),
        );
      } else {
        request.fields['foto'] = data['foto'] ?? '';
      }

      var response =
          await http.Response.fromStream(await request.send());

      return response.statusCode == 200;
    } catch (e) {
      print("🔴 Error Update: $e");
      return false;
    }
  }

  // ================= DELETE =================
  Future<bool> deleteFacility(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
