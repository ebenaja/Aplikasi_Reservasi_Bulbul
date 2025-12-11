import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FacilityService {
  // Sesuaikan IP Laptop Anda
  //final String baseUrl = 'http://10.0.2.2:8000/api/fasilitas'; 
  final String baseUrl = 'http://172.27.81.234:8000/api/fasilitas';

  Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json', 
    };
  }

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

  // --- 1. ADD FACILITY ---
  Future<bool> addFacility(Map<String, dynamic> data, File? imageFile) async {
    try {
      var uri = Uri.parse(baseUrl);
      var request = http.MultipartRequest('POST', uri);

      Map<String, String> headers = await _getHeaders();
      request.headers.addAll(headers);

      // Masukkan Text Fields
      request.fields['nama_fasilitas'] = data['nama_fasilitas'];
      request.fields['deskripsi'] = data['deskripsi'];
      request.fields['harga'] = data['harga'].toString();
      request.fields['stok'] = data['stok'].toString();
      request.fields['status'] = data['status'];
      
      // --- WAJIB TAMBAHKAN INI ---
      // SAAT TAMBAH/EDIT:
      bool isPromoBool = data['is_promo'] == 1 || data['is_promo'] == true;
      // Agar status promo terkirim ke Laravel
      // Kita kirim sebagai string "1" atau "0"
      request.fields['is_promo'] = isPromoBool ? "1" : "0";
      // ---------------------------

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));
      }

      print("🔵 Kirim Data: ${request.fields}"); // Debugging

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("🟢 Status: ${response.statusCode} Body: ${response.body}");

      return response.statusCode == 201;
    } catch (e) {
      print("Error Add: $e");
      return false;
    }
  }

  // --- 2. UPDATE FACILITY ---
  Future<bool> updateFacility(int id, Map<String, dynamic> data, File? imageFile) async {
    try {
      var uri = Uri.parse('$baseUrl/$id');
      var request = http.MultipartRequest('POST', uri); 

      Map<String, String> headers = await _getHeaders();
      request.headers.addAll(headers);
      
      request.fields['_method'] = 'PUT'; 
      request.fields['nama_fasilitas'] = data['nama_fasilitas'];
      request.fields['deskripsi'] = data['deskripsi'];
      request.fields['harga'] = data['harga'].toString();
      request.fields['stok'] = data['stok'].toString();
      request.fields['status'] = data['status'];
      
      // --- WAJIB TAMBAHKAN INI JUGA ---
      // SAAT TAMBAH/EDIT:
      bool isPromoBool = data['is_promo'] == 1 || data['is_promo'] == true;
      // KIRIM SEBAGAI STRING "1" ATAU "0"
      request.fields['is_promo'] = isPromoBool ? "1" : "0";
      // --------------------------------

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      print("Error Update: $e");
      return false;
    }
  }
  
  // ... fungsi deleteFacility sama ...
  Future<bool> deleteFacility(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

}