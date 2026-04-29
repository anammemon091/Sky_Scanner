import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../data/models/weather_model.dart';
import '../data/sources/remote_source.dart';

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

  // --- Robust Daily Summary ---
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

  // --- FETCH BY CITY NAME ---
  Future<void> fetchWeather(String cityName) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final fetchedWeather = await _source.fetchCurrentWeather(cityName);
      final fetchedForecast = await _source.fetchForecast(cityName); 
      
      _weather = fetchedWeather;
      _fullForecast = fetchedForecast; 

      // --- SAVE SEARCH TO PERSISTENCE ---
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_city', cityName);

    } catch (e) {
      _error = "Could not find city. Please try again.";
      _weather = null;
      _fullForecast = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- FETCH BY CURRENT GPS LOCATION ---
  Future<void> fetchWeatherByCurrentLocation() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Location permissions are denied.';
      }
      
      if (permission == LocationPermission.deniedForever) throw 'Location permissions are permanently denied.';

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      
      final fetchedWeather = await _source.fetchWeatherByLocation(position.latitude, position.longitude);
      final fetchedForecast = await _source.fetchForecastByLocation(position.latitude, position.longitude);
      
      _weather = fetchedWeather;
      _fullForecast = fetchedForecast;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_city');

    } catch (e) {
      _error = e.toString();
      _weather = null;
      _fullForecast = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}