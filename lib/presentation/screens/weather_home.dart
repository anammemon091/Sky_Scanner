import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart'; // <--- 1. Add this import
import '../../logic/weather_provider.dart';
import '../../core/constants.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherByCurrentLocation();
    });
  }

  // --- NEW: Helper to return the correct Lottie JSON path ---
  String _getWeatherAnimation(String? condition) {
    if (condition == null) return 'assets/animations/sunny.json';

    switch (condition.toLowerCase()) {
      case 'clouds':
        return 'assets/animations/cloudy.json';
      case 'rain':
      case 'drizzle':
        return 'assets/animations/Rainy.json';
      case 'clear':
        return 'assets/animations/sunny.json';
      default:
        return 'assets/animations/sunny.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1D1E33), Color(0xFF111328)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Column(
                children: [
                  // 1. SEARCH BAR
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Search city...",
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                            prefixIcon: const Icon(Icons.search, color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              context.read<WeatherProvider>().fetchWeather(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        child: IconButton(
                          icon: const Icon(Icons.my_location, color: Colors.cyanAccent),
                          onPressed: () {
                            _searchController.clear();
                            context.read<WeatherProvider>().fetchWeatherByCurrentLocation();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 2. WEATHER DISPLAY AREA
                  Consumer<WeatherProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(
                            // --- NEW: Using a Lottie animation for loading ---
                            child: Lottie.asset('assets/animations/loading.json', width: 200),
                          ),
                        );
                      }

                      if (provider.weather == null) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(
                            child: Text(
                              provider.error.isNotEmpty ? provider.error : "Search for a city!",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70, fontSize: 18),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Text(
                            provider.weather!.cityName,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            DateFormat('EEEE, d MMMM').format(DateTime.now()),
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          
                          // --- NEW: Main Lottie Animation ---
                          Lottie.asset(
                            _getWeatherAnimation(provider.weather!.condition),
                            height: 180,
                            repeat: true,
                          ),
                          
                          const SizedBox(height: 10),
                          Text(
                            "${provider.weather!.temperature.toStringAsFixed(0)}°C",
                            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w200, color: Colors.white),
                          ),
                          Text(
                            provider.weather!.condition.toUpperCase(),
                            style: const TextStyle(fontSize: 18, letterSpacing: 4, color: Colors.cyanAccent),
                          ),

                          const SizedBox(height: 50),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "5-Day Forecast",
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: provider.forecast.length,
                              itemBuilder: (context, index) {
                                final day = provider.forecast[index];
                                DateTime dateObj = DateTime.parse(day.date);

                                return Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('E').format(dateObj), 
                                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
                                      ),
                                      const SizedBox(height: 10),
                                      
                                      // --- NEW: Small Lotties for the Forecast ---
                                      Lottie.asset(
                                        _getWeatherAnimation(day.condition),
                                        height: 50,
                                      ),
                                      
                                      const SizedBox(height: 10),
                                      Text(
                                        "${day.temp.toStringAsFixed(0)}°C",
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}