class AppConstants {
  // Replace this with the key you just generated on OpenWeatherMap
  static const String apiKey = '9b336524e039df2b9733fa82ec118ee4'; 
  
  // Base URL for the API
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Endpoints
  static const String currentWeatherEndpoint = '/weather';
  static const String forecastEndpoint = '/forecast';

  // Units - 'metric' gives us Celsius, 'imperial' gives Fahrenheit
  static const String units = 'metric';

  // Design/Theme Constants (Good for keeping the UI consistent)
  static const double padding = 16.0;
  static const double borderRadius = 12.0;
}