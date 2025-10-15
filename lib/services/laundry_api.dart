import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LaundryService {
  static const String apiToken = 'Y'; // ganti token asli
  static const String baseUrl = 'https://cleancloudapp.com/api';

  static Future<List<Map<String, dynamic>>> fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');

    if (customerId == null) {
      throw Exception('Customer ID tidak ditemukan. Silakan login ulang.');
    }

    final url = Uri.parse('$baseUrl/getOrders');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'api_token': apiToken,
        'customerID': customerId,
      }),
    );

    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      final List orders = json['orders'] ?? [];
      return orders.map((o) => Map<String, dynamic>.from(o)).toList();
    } else {
      throw Exception('Gagal memuat history: ${resp.statusCode}');
    }
  }
}
