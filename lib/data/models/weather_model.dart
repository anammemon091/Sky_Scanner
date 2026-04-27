// Main weather for the top of the screen
class Weather {
  final String cityName;
  final double temperature;
  final String condition;
  final String description;
  final int humidity;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
    );
  }
}

// Forecast weather for the bottom list
class Forecast {
  final String date;
  final double temp;
  final String condition;

  Forecast({required this.date, required this.temp, required this.condition});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      date: json['dt_txt'], 
      temp: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
    );
  }
}