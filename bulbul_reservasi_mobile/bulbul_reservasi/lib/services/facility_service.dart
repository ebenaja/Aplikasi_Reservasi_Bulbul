import 'dart:convert';
import 'dart:io'; // Untuk File
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FacilityService {
  // Ganti IP Laptop Anda
   final String baseUrl = 'http://10.0.2.2:8000/api/fasilitas'; 

  Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json', 
      // Content-Type jangan diset manual saat Multipart, biarkan otomatis
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

  // POST DENGAN GAMBAR
// POST (TAMBAH DATA)
  Future<bool> addFacility(Map<String, dynamic> data, File? imageFile) async {
    try {
      var uri = Uri.parse(baseUrl);
      var request = http.MultipartRequest('POST', uri);

      // Header Token
      Map<String, String> headers = await _getHeaders();
      request.headers.addAll(headers);

      // Field Text
      request.fields['nama_fasilitas'] = data['nama_fasilitas'];
      request.fields['deskripsi'] = data['deskripsi'] ?? '';
      request.fields['harga'] = data['harga'].toString();
      request.fields['stok'] = data['stok'].toString();
      request.fields['status'] = data['status'];
      request.fields['foto'] = data['foto'] ?? '';

      // File Gambar
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));
      }

      print("🔵 Mengirim Data ke: $uri");
      print("🔵 Data: ${request.fields}");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("🟢 Status Code: ${response.statusCode}");
      print("🟢 Response Body: ${response.body}"); // INI YANG PENTING DIBACA

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("🔴 Error Connection: $e");
      return false;
    }
  }

  // UPDATE DENGAN GAMBAR
  // Laravel PUT Multipart agak tricky, kita pakai POST dengan _method: PUT
  Future<bool> updateFacility(int id, Map<String, dynamic> data, File? imageFile) async {
    try {
      var uri = Uri.parse('$baseUrl/$id');
      var request = http.MultipartRequest('POST', uri); 

      Map<String, String> headers = await _getHeaders();
      request.headers.addAll(headers);
      
      // Trik Laravel untuk PUT dengan gambar
      request.fields['_method'] = 'PUT'; 

      request.fields['nama_fasilitas'] = data['nama_fasilitas'];
      request.fields['deskripsi'] = data['deskripsi'];
      request.fields['harga'] = data['harga'];
      request.fields['stok'] = data['stok'];
      request.fields['status'] = data['status'];

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Gagal Update: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error Update: $e");
      return false;
    }
  }

  Future<bool> deleteFacility(int id) async {
    // ... (Code delete sama seperti sebelumnya)
    try {
      final headers = await _getHeaders();
      final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}