import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
static String get apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';  
  // Base URL for the API
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Endpoints
  static const String currentWeatherEndpoint = '/weather';
  static const String forecastEndpoint = '/forecast';

  static const String units = 'metric';

  static const double padding = 16.0;
  static const double borderRadius = 12.0;
}