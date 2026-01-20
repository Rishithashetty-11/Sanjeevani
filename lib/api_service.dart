import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sanjeevani/main.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

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

  static Future<bool> bookAppointment({
    required String name,
    required String phone,
    required DateTime date,
    required List<CartItem> cartItems,
  }) async {
    final url = Uri.parse('$baseUrl/book-appointment');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'date': date.toIso8601String(),
          'cartItems': cartItems.map((item) => {
            'testName': item.test.name,
            'centerName': item.center.name,
            'price': item.test.price,
          }).toList(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to book appointment: $e');
    }
  }
}
