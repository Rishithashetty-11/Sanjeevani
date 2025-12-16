import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your laptop's IPv4 address (run `ipconfig` to find it)
  static const String baseUrl = 'http://192.168.0.105:3000'; // 👈 change this

  static Future<bool> sendBloodRequest({
    required String name,
    required String bloodType,
    required int units,
    required String contact,
    required String purpose,
  }) async {
    final url = Uri.parse('$baseUrl/blood-request');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'bloodType': bloodType,
          'units': units,
          'contact': contact,
          'purpose': purpose,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to send blood request: $e');
    }
  }
}
