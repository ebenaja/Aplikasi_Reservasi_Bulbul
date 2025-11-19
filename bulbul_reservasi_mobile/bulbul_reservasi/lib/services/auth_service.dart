import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Ganti URL ini sesuai IP Laptop/PC jika pakai HP Fisik
  // Jika pakai Android Emulator gunakan 10.0.2.2
  final String baseUrl = 'http://10.0.2.2:8000/api'; 

Future<http.Response> register(String name, String email, String password) async {
  return await http.post(
    Uri.parse('$baseUrl/register'),
    headers: {
      'Accept': 'application/json',
    },
    body: {
      'name': name,
      'email': email,
      'password': password,
    },
  );
}

Future<Map<String, dynamic>> login(String email, String password) async {
  final url = Uri.parse('$baseUrl/login');

  print("🔵 REQUEST: POST $url");
  print("🔵 EMAIL: $email");

  try {
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
      },
      body: {
        'email': email,
        'password': password,
      },
    );

    print("🟢 STATUS CODE: ${response.statusCode}");
    print("🟢 RESPONSE BODY: ${response.body}");

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body)
    };
  } catch (e) {
    print("🔴 ERROR LOGIN: $e");
    return {
      "status": 0,
      "body": {"message": "Login error"}
    };
  }
}


  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    await prefs.remove('token');
  }
}