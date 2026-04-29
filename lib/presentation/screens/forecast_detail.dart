import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../data/models/weather_model.dart'; 

class ForecastDetail extends StatelessWidget {
  final DateTime selectedDate;
  final List<Forecast> hourlyForecasts;

  const ForecastDetail({
    super.key,
    required this.selectedDate,
    required this.hourlyForecasts,
  });

  String _getWeatherAnimation(String? condition, String? pod) {
    if (condition == null || pod == null) return 'assets/animations/sunny.json';

    bool isNight = pod == 'n'; 

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1D1E33), Color(0xFF111328)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      DateFormat('EEEE, d MMMM').format(selectedDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Hourly List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: hourlyForecasts.length,
                  itemBuilder: (context, index) {
                    final hour = hourlyForecasts[index];
                    final time = DateFormat('hh:mm a').format(DateTime.parse(hour.date));

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Time
                          SizedBox(
                            width: 80,
                            child: Text(
                              time,
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                          
                          // Animation & Condition
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  _getWeatherAnimation(hour.condition, hour.partOfDay),
                                  height: 50,
                                  width: 50,
                                ),
                                const SizedBox(width: 12),
                                // Details
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.water_drop, size: 12, color: Colors.cyanAccent),
                                        const SizedBox(width: 4),
                                        Text("${hour.humidity}%", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.air, size: 12, color: Colors.cyanAccent),
                                        const SizedBox(width: 4),
                                        Text("${hour.windSpeed}m/s", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),

                          // Temp
                          Text(
                            "${hour.temp.toStringAsFixed(0)}°C",
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}