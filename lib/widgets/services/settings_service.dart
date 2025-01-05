// settings_service
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsProvider = Provider((ref) => SettingsService());

final aodEnabledProvider = StateProvider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.getSetting(SettingsService.aodEnabledKey, true) ?? true;
});

class SettingsService {
  static const String themeKey = 'theme';
  static const String languageKey = 'language';
  static const String aodEnabledKey = 'aod_enabled';
  static const String selectedStyleKey = 'selected_style';
  static const String fontFamilyKey = 'font_family';
  static const String fontSizeKey = 'font_size';
  static const String customFontSizeKey = 'custom_font_size';
  static const String avoidBurnInKey = 'avoid_burn_in';
  static const String timeFormatKey = 'time_format';
  static const String dateFormatKey = 'date_format';
  static const String temperatureUnitKey = 'temperature_unit';
  static const String weatherLocationKey = 'weather_location';
  static const String weatherUpdateFrequencyKey = 'weather_update_frequency';

  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setSetting(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    }
  }

  T? getSetting<T>(String key, T defaultValue) {
    return _prefs.get(key) as T? ?? defaultValue;
  }

  // Weather location specific methods
  Future<void> setWeatherLocation(String location, bool isAutomatic) async {
    await _prefs.setString(weatherLocationKey, location);
    await _prefs.setBool('weather_location_automatic', isAutomatic);
  }

  String? getWeatherLocation() {
    return _prefs.getString(weatherLocationKey);
  }

  bool isWeatherLocationAutomatic() {
    return _prefs.getBool('weather_location_automatic') ?? true;
  }


  Future<void> resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await initialize(); // Reinitialize with default values
  }
}


  final timeFormatProvider = StateProvider<String>((ref) {
    final settings = ref.watch(settingsProvider);
    return settings.getSetting(SettingsService.timeFormatKey, '12') ?? '12';
  });
