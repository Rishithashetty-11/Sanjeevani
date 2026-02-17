import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:sanjeevani/models/cart_item.dart';
import 'package:sanjeevani/diagnostic.dart';

class ApiService {
  // ⚠️ IMPORTANT: change localhost to your laptop IP when testing on real mobile
  static const String baseUrl = 'http://localhost:3000';

  // ===================== BLOOD REQUEST API =====================
  static Future<bool> sendBloodRequest({
    required String name,
    required String bloodType,
    required int units,
    required String contact,
    required String urgency,
    required double latitude,
    required double longitude,
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
          'urgency': urgency,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to send blood request: $e');
    }
  }

  // ===================== DIAGNOSTIC APPOINTMENT API =====================
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
          'cartItems': cartItems
              .map(
                (item) => {
                  'testName': item.test.name,
                  'centerName': item.center.name,
                  'price': item.test.price,
                },
              )
              .toList(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to book appointment: $e');
    }
  }
}

// ===================== LOCATION SERVICE =====================
Future<Position> getUserLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  // Check permission
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  // Permission permanently denied
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, please enable them from settings.',
    );
  }

  // Get current position
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}
