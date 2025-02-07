import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  // Set the base URL to your Flask server.
  static const String _baseUrl = "http://192.168.51.172:5000";

  // This method sends a POST request with the recognized command.
  static Future<String> callVoiceCommandAPI(String command) async {
    final url = Uri.parse("$_baseUrl/process_text");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"text": command}),
    );

    if (response.statusCode == 200) {
      // Decode the JSON response.
      final data = json.decode(response.body);
      // For example, you can return the message received.
      return data["message"] as String;
    } else {
      throw Exception("Failed to call voice command API: ${response.statusCode}");
    }
  }
}
