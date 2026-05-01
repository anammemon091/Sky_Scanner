import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../data/models/weather_model.dart';
import '../data/sources/remote_source.dart';
import 'dart:io'; // Needed for SocketException

class WeatherProvider with ChangeNotifier {
  final RemoteWeatherSource _source = RemoteWeatherSource(client: http.Client());

  Weather? _weather;
  List<Forecast> _fullForecast = []; 
  bool _isLoading = false;
  String _error = '';

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String get error => _error;
  List<Forecast> get fullForecast => _fullForecast;

  List<Forecast> get dailySummary {
    if (_fullForecast.isEmpty) return [];
    List<Forecast> summary = [];
    Set<String> datesSeen = {};

    for (var forecast in _fullForecast) {
      String dateOnly = forecast.date.split(' ')[0];
      if (!datesSeen.contains(dateOnly)) {
        summary.add(forecast);
        datesSeen.add(dateOnly);
      }
    }
    return summary.take(5).toList();
  }

  // --- NEW: INITIALIZE APP DATA ---
  Future<void> initApp() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastCity = prefs.getString('last_city');
    
    if (lastCity != null && lastCity.isNotEmpty) {
      await fetchWeather(lastCity);
    } else {
      // If no history, try GPS silently or show a default
      await fetchWeatherByCurrentLocation(isInitialLoad: true);
    }
  }

  // --- FETCH BY CITY NAME (Updated Error Handling) ---
  Future<void> fetchWeather(String cityName) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final fetchedWeather = await _source.fetchCurrentWeather(cityName);
      final fetchedForecast = await _source.fetchForecast(cityName); 
      
      _weather = fetchedWeather;
      _fullForecast = fetchedForecast; 

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_city', cityName);

    } on SocketException {
      _error = "No internet connection. Please check your data or Wi-Fi.";
    } catch (e) {
      _error = "City '$cityName' not found. Please check the spelling.";
      _weather = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- FETCH BY CURRENT GPS (Updated UX Logic) ---
  Future<void> fetchWeatherByCurrentLocation({bool isInitialLoad = false}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (isInitialLoad) return; // Silent fail on start
        throw 'Location services are disabled in your settings.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
           // USER DENIED: Keep the app open, let them use search.
           _error = "Location access denied. Use the search bar instead.";
           _isLoading = false;
           notifyListeners();
           return; 
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _error = "Location is permanently blocked. Please enable it in settings or use search.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      
      final fetchedWeather = await _source.fetchWeatherByLocation(position.latitude, position.longitude);
      final fetchedForecast = await _source.fetchForecastByLocation(position.latitude, position.longitude);
      
      _weather = fetchedWeather;
      _fullForecast = fetchedForecast;

    } on SocketException {
      _error = "Network error. Please verify your internet connection.";
    } catch (e) {
      _error = "Failed to get weather for your location.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}