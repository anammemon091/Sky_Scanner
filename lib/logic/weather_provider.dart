import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // <--- 1. Add this import
import '../data/models/weather_model.dart';
import '../data/sources/remote_source.dart';

class WeatherProvider with ChangeNotifier {
  final RemoteWeatherSource _source = RemoteWeatherSource(client: http.Client());

  Weather? _weather;
  List<Forecast> _forecast = [];
  bool _isLoading = false;
  String _error = '';

  Weather? get weather => _weather;
  List<Forecast> get forecast => _forecast;
  bool get isLoading => _isLoading;
  String get error => _error;

  // --- FETCH BY CITY NAME ---
  Future<void> fetchWeather(String cityName) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final fetchedWeather = await _source.fetchCurrentWeather(cityName);
      final fetchedForecast = await _source.fetchForecast(cityName);
      
      _weather = fetchedWeather;
      _forecast = fetchedForecast;
    } catch (e) {
      _error = "Could not find city. Please try again.";
      _weather = null;
      _forecast = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- NEW: FETCH BY CURRENT GPS LOCATION ---
  Future<void> fetchWeatherByCurrentLocation() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // 1. Check if location services are enabled on the phone
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled. Please turn on GPS.';
      }

      // 2. Handle Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied. Please enable them in settings.';
      }

      // 3. Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low // Lower accuracy saves battery
      );

      // 4. Use coordinates to fetch data
      final fetchedWeather = await _source.fetchWeatherByLocation(
        position.latitude, 
        position.longitude
      );
      final fetchedForecast = await _source.fetchForecastByLocation(
        position.latitude, 
        position.longitude
      );
      
      _weather = fetchedWeather;
      _forecast = fetchedForecast;
    } catch (e) {
      _error = e.toString();
      _weather = null;
      _forecast = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}