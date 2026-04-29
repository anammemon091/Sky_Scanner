import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../logic/weather_provider.dart';
import '../../core/constants.dart';
import 'forecast_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final prefs = await SharedPreferences.getInstance();
    String? lastCity = prefs.getString('last_city');

    if (lastCity != null && lastCity.isNotEmpty) {
      // 1. Fill the search bar text
      _searchController.text = lastCity;
      // 2. Fetch weather for that city
      context.read<WeatherProvider>().fetchWeather(lastCity);
    } else {
      // Fallback to current location if no history exists
      context.read<WeatherProvider>().fetchWeatherByCurrentLocation();
    }
  });
}

  // --- Animation Helper ---
  String _getWeatherAnimation(String? condition, String? iconCode) {
    if (condition == null || iconCode == null) return 'assets/animations/sunny.json';

    bool isNight = iconCode.endsWith('n');

    switch (condition.toLowerCase()) {
      case 'clouds':
        return isNight ? 'assets/animations/cloudy_night.json' : 'assets/animations/cloudy.json';
      case 'rain':
      case 'drizzle':
        return 'assets/animations/rainy.json';
      case 'clear':
        return isNight ? 'assets/animations/moon.json' : 'assets/animations/sunny.json';
      case 'snow':
        return 'assets/animations/snow.json';
      default:
        return isNight ? 'assets/animations/moon.json' : 'assets/animations/sunny.json';
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Search city...",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon: const Icon(Icons.search, color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
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
                        backgroundColor: Colors.white.withOpacity(0.1),
                        child: IconButton(
                          icon: const Icon(Icons.my_location, color: Colors.cyanAccent),
                          onPressed: () async {
                            // CLEAR SEARCH HISTORY WHEN USING GPS
                            _searchController.clear();
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('last_city'); 
                            
                            if (mounted) {
                              context.read<WeatherProvider>().fetchWeatherByCurrentLocation();
                            }
                          }
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 2. WEATHER DISPLAY AREA
                  Consumer<WeatherProvider>(
                    builder: (context, provider, child) {
                      // A. LOADING STATE
                      if (provider.isLoading) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(
                            child: Lottie.asset('assets/animations/loading.json', width: 200),
                          ),
                        );
                      }

                      if (provider.error.isNotEmpty) {
                        IconData errorIcon = Icons.error_outline;
                        String errorMsg = provider.error.toLowerCase();

                        if (errorMsg.contains("internet") || errorMsg.contains("socket")) {
                          errorIcon = Icons.wifi_off;
                        } else if (errorMsg.contains("permission") || errorMsg.contains("location")) {
                          errorIcon = Icons.location_off;
                        } else if (errorMsg.contains("not found") || errorMsg.contains("404")) {
                          errorIcon = Icons.search_off;
                        } else if (errorMsg.contains("limit") || errorMsg.contains("429")) {
                          errorIcon = Icons.speed;
                        }

                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(errorIcon, size: 80, color: Colors.cyanAccent.withOpacity(0.5)),
                                  const SizedBox(height: 20),
                                  Text(
                                    provider.error,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 18),
                                  ),
                                  const SizedBox(height: 30),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (_searchController.text.isNotEmpty) {
                                        provider.fetchWeather(_searchController.text);
                                      } else {
                                        provider.fetchWeatherByCurrentLocation();
                                      }
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text("Retry Now"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // C. EMPTY STATE
                      if (provider.weather == null) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const Center(
                            child: Text(
                              "Search for a city to begin!",
                              style: TextStyle(color: Colors.white70, fontSize: 18),
                            ),
                          ),
                        );
                      }

                      // D. SUCCESS STATE
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
                          
                          Lottie.asset(
                            _getWeatherAnimation(
                              provider.weather!.condition, 
                              provider.weather!.iconCode
                            ),
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
                              physics: const BouncingScrollPhysics(),
                              itemCount: provider.dailySummary.length,
                              itemBuilder: (context, index) {
                                final day = provider.dailySummary[index];
                                DateTime dateObj = DateTime.parse(day.date);

                                return GestureDetector(
                                  onTap: () {
                                    final String selectedDateString = day.date.split(' ')[0];                                    
                                    final hourlyList = provider.fullForecast
                                    .where((f) => f.date.contains(selectedDateString))
                                    .toList();
                                    
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ForecastDetail(
                                          selectedDate: dateObj,
                                          hourlyForecasts: hourlyList,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat('E').format(dateObj), 
                                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
                                        ),
                                        const SizedBox(height: 10),
                                        Lottie.asset(
                                          _getWeatherAnimation(day.condition, day.iconCode),
                                          height: 50,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "${day.temp.toStringAsFixed(0)}°C",
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
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