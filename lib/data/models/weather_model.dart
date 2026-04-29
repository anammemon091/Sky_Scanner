// Main weather for the top of the screen (Current Weather)
class Weather {
  final String cityName;
  final double temperature;
  final String condition;
  final String description;
  final int humidity;
  final String iconCode; 

  Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.iconCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      iconCode: json['weather'][0]['icon'], 
    );
  }
}

// Forecast weather - FIXED with partOfDay
class Forecast {
  final String date;
  final double temp;
  final String condition;
  final double windSpeed; 
  final int humidity; 
  final String iconCode;
  final String partOfDay; // <--- ADD THIS

  Forecast({
    required this.date, 
    required this.temp, 
    required this.condition,
    required this.windSpeed,
    required this.humidity,
    required this.iconCode,
    required this.partOfDay, // <--- ADD THIS
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      date: json['dt_txt'], 
      temp: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      humidity: json['main']['humidity'],
      iconCode: json['weather'][0]['icon'], 
      // This is what makes 3 AM vs 3 PM work perfectly in Pakistan
      partOfDay: json['sys']['pod'], // <--- ADD THIS
    );
  }
}