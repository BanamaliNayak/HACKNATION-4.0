import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HttpService {
  // Base URLs for each detection API.
  // Ensure these URLs are accessible from your client device.
  static const String coinBaseUrl = 'http://192.168.51.181:5002'; // Coin Detection API
  static const String objectBaseUrl = 'http://192.168.51.173:5000'; // Object Detection API
  static const String currencyBaseUrl = 'http://192.168.51.181:5001'; // Currency Detection API

  /// A helper method to send a POST request with a JSON body containing the command.
  /// Expects the response JSON to have a key 'response'.
  static Future<String> _postCommand(String baseUrl, String endpoint, String command) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'command': command}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['response'] != null) {
          return data['response'] as String;
        } else {
          throw Exception("Invalid response format from $endpoint API. Expected key 'response'.");
        }
      } else {
        throw Exception("$endpoint API error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error calling $endpoint API: $e");
    }
  }

  /// Calls the Coin Detection API with a text command.
  /// (If your coin detection is only image based, you might remove or modify this.)
  static Future<String> callCoinDetectionAPI(String command) async {
    return await _postCommand(coinBaseUrl, 'coin-detection', command);
  }

  /// Calls the Coin Detection API with an image file.
  /// Sends a multipart/form-data request with the image file under the key "file"
  /// and expects the Flask API to return a JSON object with a key "detections".
  static Future<String> callCoinDetectionAPIFromImage(File imageFile) async {
    final url = Uri.parse('$coinBaseUrl/coin-detection');
    var request = http.MultipartRequest('POST', url);
    // The Flask API expects the image file with the key "file"
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    // Log the request details
    debugPrint("Sending image to API: ${imageFile.path}");

    var streamedResponse = await request.send();
    final responseData = await streamedResponse.stream.bytesToString();
    debugPrint("API response: $responseData");
    if (streamedResponse.statusCode == 200) {
      final data = jsonDecode(responseData);
      if (data != null && data['detections'] != null) {
        return data['detections'].toString();
      } else {
        throw Exception("Invalid response format from coin-detection API. Expected key 'detections'.");
      }
    } else {
      throw Exception("Coin detection API error: ${streamedResponse.statusCode}");
    }
  }

  /// Calls the Object Detection API with a text command.
  static Future<String> callObjectDetectionAPI(String command) async {
    return await _postCommand(objectBaseUrl, 'object-detection', command);
  }

  /// Calls the Currency Detection API with a text command.
  static Future<String> callCurrencyDetectionAPI(String command) async {
    return await _postCommand(currencyBaseUrl, 'currency-detection', command);
  }

  /// Calls an external Weather API (e.g., OpenWeatherMap) using your API key.
  /// Extracts the city name from the command if provided (e.g., "weather in Mumbai").
  static Future<String> callWeatherAPI(String command) async {
    // Replace with your actual weather API key.
    const String apiKey = '48a30ee4459579325cb2e675b21ec976';
    // Default city if none is extracted.
    String city = 'Bhubaneswar';
    if (command.toLowerCase().contains(" in ")) {
      List<String> parts = command.toLowerCase().split(" in ");
      if (parts.length > 1 && parts[1].trim().isNotEmpty) {
        city = parts[1].trim();
      }
    }
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String description = data['weather'][0]['description'];
        double temp = data['main']['temp'];
        return "The weather in $city is $description with a temperature of ${temp.toStringAsFixed(1)}°C.";
      } else {
        throw Exception("Weather API error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error calling Weather API: $e");
    }
  }
}
