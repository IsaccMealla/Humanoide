import 'dart:convert';
import 'package:http/http.dart' as http;

class CintaService {
  // IP local de tu computadora donde corre FastAPI
  static const String baseUrl = 'http://192.168.1.224:8000/api/cinta';

  Future<Map<String, dynamic>> getStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/status'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener estado');
  }

  Future<void> sendCommand(String action) async {
    await http.post(
      Uri.parse('$baseUrl/control'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'action': action}),
    );
  }
}
