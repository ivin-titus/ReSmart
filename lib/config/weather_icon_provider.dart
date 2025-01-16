import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherIconProvider {
  // Singleton pattern for service
  static final WeatherIconProvider _instance = WeatherIconProvider._internal();
  factory WeatherIconProvider() => _instance;
  WeatherIconProvider._internal();

  static final Map<String, ({IconData day, IconData night})> _weatherIcons = {
    // Clear conditions
    'clear sky': (
      day: WeatherIcons.day_sunny,
      night: WeatherIcons.night_clear
    ),
    'clear': (
      day: WeatherIcons.day_sunny,
      night: WeatherIcons.night_clear
    ),
    
    // Cloudy conditions
    'few clouds': (
      day: WeatherIcons.day_cloudy,
      night: WeatherIcons.night_alt_cloudy
    ),
    'scattered clouds': (
      day: WeatherIcons.day_cloudy_high,
      night: WeatherIcons.night_alt_cloudy_high
    ),
    'broken clouds': (
      day: WeatherIcons.cloudy,
      night: WeatherIcons.cloudy
    ),
    'clouds': (
      day: WeatherIcons.cloud,
      night: WeatherIcons.cloud
    ),
    'overcast clouds': (
      day: WeatherIcons.day_cloudy_windy,
      night: WeatherIcons.night_alt_cloudy_windy
    ),
    
    // Rain conditions
    'shower rain': (
      day: WeatherIcons.day_showers,
      night: WeatherIcons.night_alt_showers
    ),
    'rain': (
      day: WeatherIcons.day_rain,
      night: WeatherIcons.night_alt_rain
    ),
    'light rain': (
      day: WeatherIcons.day_sprinkle,
      night: WeatherIcons.night_alt_sprinkle
    ),
    'drizzle': (
      day: WeatherIcons.day_sprinkle,
      night: WeatherIcons.night_alt_sprinkle
    ),
    'moderate rain': (
      day: WeatherIcons.day_rain_mix,
      night: WeatherIcons.night_alt_rain_mix
    ),
    'heavy rain': (
      day: WeatherIcons.day_rain_wind,
      night: WeatherIcons.night_alt_rain_wind
    ),
    
    // Thunderstorm conditions
    'thunderstorm': (
      day: WeatherIcons.day_thunderstorm,
      night: WeatherIcons.night_alt_thunderstorm
    ),
    'thunderstorm with rain': (
      day: WeatherIcons.day_storm_showers,
      night: WeatherIcons.night_alt_storm_showers
    ),
    'thunderstorm with heavy rain': (
      day: WeatherIcons.day_thunderstorm,
      night: WeatherIcons.night_thunderstorm
    ),
    
    // Snow conditions
    'snow': (
      day: WeatherIcons.day_snow,
      night: WeatherIcons.night_alt_snow
    ),
    'light snow': (
      day: WeatherIcons.day_snow_wind,
      night: WeatherIcons.night_alt_snow_wind
    ),
    'heavy snow': (
      day: WeatherIcons.snowflake_cold,
      night: WeatherIcons.snowflake_cold
    ),
    'sleet': (
      day: WeatherIcons.day_sleet,
      night: WeatherIcons.night_alt_sleet
    ),
    
    // Atmospheric conditions
    'mist': (
      day: WeatherIcons.day_fog,
      night: WeatherIcons.night_fog
    ),
    'fog': (
      day: WeatherIcons.fog,
      night: WeatherIcons.fog
    ),
    'haze': (
      day: WeatherIcons.day_haze,
      night: WeatherIcons.night_fog
    ),
    'smoke': (
      day: WeatherIcons.smoke,
      night: WeatherIcons.smoke
    ),
    'dust': (
      day: WeatherIcons.dust,
      night: WeatherIcons.dust
    ),
    'sand': (
      day: WeatherIcons.sandstorm,
      night: WeatherIcons.sandstorm
    ),
    'tornado': (
      day: WeatherIcons.tornado,
      night: WeatherIcons.tornado
    ),
    'volcanic ash': (
      day: WeatherIcons.volcano,
      night: WeatherIcons.volcano
    ),
    'squalls': (
      day: WeatherIcons.strong_wind,
      night: WeatherIcons.strong_wind
    ),
  };

  // Get icon based on condition and time
  IconData getWeatherIcon(String condition, {DateTime? time, DateTime? sunrise, DateTime? sunset}) {
    final isDay = _isDaytime(time ?? DateTime.now(), sunrise: sunrise, sunset: sunset);
    final normalizedCondition = condition.toLowerCase().trim();
    
    final weatherIcon = _weatherIcons[normalizedCondition] ?? 
      (day: WeatherIcons.na, night: WeatherIcons.na);
    
    return isDay ? weatherIcon.day : weatherIcon.night;
  }

  // Get icon map for compatibility with existing code
  static Map<String, IconData> getIconMap({bool isDay = true}) {
    return Map.fromEntries(
      _weatherIcons.entries.map(
        (entry) => MapEntry(
          entry.key,
          isDay ? entry.value.day : entry.value.night
        )
      )
    );
  }

  // Helper method to determine if it's daytime
  bool _isDaytime(DateTime time, {DateTime? sunrise, DateTime? sunset}) {
    if (sunrise != null && sunset != null) {
      return time.isAfter(sunrise) && time.isBefore(sunset);
    }
    return time.hour >= 6 && time.hour < 18;
  }
}