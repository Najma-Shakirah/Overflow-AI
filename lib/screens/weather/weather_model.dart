// lib/screens/home/weather_model.dart
class WeatherModel {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final double rainfall;   // mm in last hour
  final double humidity;
  final String icon;
  final bool isFloodRisk;
  final double windSpeed;

  WeatherModel({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.rainfall,
    required this.humidity,
    required this.icon,
    required this.isFloodRisk,
    required this.windSpeed,
  });

  // Parses the free data/2.5/weather response
  // units=metric so temp is already Celsius — no Kelvin conversion needed
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final rain = (json['rain']?['1h'] ?? 0.0).toDouble();

    return WeatherModel(
      location: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      condition: json['weather'][0]['description'] ?? '',
      rainfall: rain,
      humidity: (json['main']['humidity'] as num).toDouble(),
      icon: json['weather'][0]['icon'] ?? '01d',
      isFloodRisk: rain > 10.0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }
}