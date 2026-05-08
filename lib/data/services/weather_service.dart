import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  final String apiKey = const String.fromEnvironment('WEATHER_API_KEY');

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    // Safety check: if key is missing, throw a clear error
    if (apiKey.isEmpty) {
      throw "API Key is missing. Check your GitHub Secrets and --dart-define.";
    }

    final url = 'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('weather_cache', response.body);
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw "Invalid API Key. Please check your OpenWeather account.";
      } else if (response.statusCode == 404) {
        throw "City not found. Please check the spelling.";
      } else {
        throw "Error: ${response.statusCode}";
      }
    } catch (e) {
      // General error handling that works on both Web and Mobile
      final prefs = await SharedPreferences.getInstance();
      String? cache = prefs.getString('weather_cache');
      
      if (cache != null) {
        return jsonDecode(cache);
      }
      
      if (e.toString().contains('SocketException') || e.toString().contains('XMLHttpRequest')) {
        throw "No connection and no cached data found.";
      }
      throw e.toString();
    }
  }
}