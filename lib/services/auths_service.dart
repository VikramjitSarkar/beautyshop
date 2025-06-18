import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl =
      'https://api.thebeautyshop.io/verify'; // replace if hosted

  Future<bool> sendOtp(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    return response.statusCode == 200;
  }

  Future<bool> verifyOtp(String phone, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'code': code}),
    );
    return response.statusCode == 200;
  }
}
