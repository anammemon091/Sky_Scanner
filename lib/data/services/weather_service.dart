import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  final String apiKey = 'YOUR_API_KEY';

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final url = 'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Cache the successful data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('weather_cache', response.body);
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw "City not found. Please check the spelling.";
      } else if (response.statusCode == 429) {
        throw "API limit reached. Please try again later.";
      } else {
        throw "Server error: ${response.statusCode}";
      }
    } on SocketException {
      // Offline: Try to load from cache
      final prefs = await SharedPreferences.getInstance();
      String? cache = prefs.getString('weather_cache');
      if (cache != null) {
        return jsonDecode(cache);
      }
      throw "No Internet connection and no cached data found.";
    } on HttpException {
      throw "Couldn't find the weather service.";
    } catch (e) {
      throw e.toString();
    }
  }
}