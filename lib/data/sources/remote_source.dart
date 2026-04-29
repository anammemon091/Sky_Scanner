import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/weather_model.dart';

class RemoteWeatherSource {
  final http.Client client;

  RemoteWeatherSource({required this.client});

  // --- METHODS (BY CITY NAME) ---

  Future<Weather> fetchCurrentWeather(String cityName) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.currentWeatherEndpoint}?q=$cityName&appid=${AppConstants.apiKey}&units=${AppConstants.units}',
    );
    return _getWeatherFromUrl(url);
  }

  Future<List<Forecast>> fetchForecast(String cityName) async {
    // UPDATED: Now uses the constant and calls the helper properly
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.forecastEndpoint}?q=$cityName&appid=${AppConstants.apiKey}&units=${AppConstants.units}',
    );
    return _getForecastFromUrl(url);
  }

  // --- METHODS (BY COORDINATES) ---

  Future<Weather> fetchWeatherByLocation(double lat, double lon) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.currentWeatherEndpoint}?lat=$lat&lon=$lon&appid=${AppConstants.apiKey}&units=${AppConstants.units}',
    );
    return _getWeatherFromUrl(url);
  }

  Future<List<Forecast>> fetchForecastByLocation(double lat, double lon) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.forecastEndpoint}?lat=$lat&lon=$lon&appid=${AppConstants.apiKey}&units=${AppConstants.units}',
    );
    return _getForecastFromUrl(url);
  }

  // --- HELPER METHODS ---

  Future<Weather> _getWeatherFromUrl(Uri url) async {
    final response = await client.get(url);
    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<Forecast>> _getForecastFromUrl(Uri url) async {
    final response = await client.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['list'];
      
      return list.map((item) => Forecast.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load forecast');
    }
  }
}