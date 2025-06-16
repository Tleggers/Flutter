class DailyWeather {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final double windSpeed;
  final double rain;
  final String description;
  final String icon;

  DailyWeather({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.windSpeed,
    required this.rain,
    required this.description,
    required this.icon,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    final weatherInfo = json['weather'][0];

    return DailyWeather(
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      minTemp: (json['temp']['min'] as num).toDouble(),
      maxTemp: (json['temp']['max'] as num).toDouble(),
      windSpeed: (json['wind_speed'] as num).toDouble(),
      rain: json.containsKey('rain') ? (json['rain'] as num).toDouble() : 0.0,
      description: weatherInfo['description'] as String,
      icon: weatherInfo['icon'] as String,
    );
  }
}
