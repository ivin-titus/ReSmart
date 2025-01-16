import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// Providers
final settingsProvider = Provider((ref) => SettingsService());

final aodEnabledProvider = StateProvider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.getSetting(SettingsService.aodEnabledKey, true) ?? true;
});

final timeFormatProvider = StateProvider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.getSetting(SettingsService.timeFormatKey, '12') ?? '12';
});

final dateFormatProvider = StateProvider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.getSetting(SettingsService.dateFormatKey, 'mon, 1 jan') ?? 'mon, 1 jan';
});

final temperatureUnitProvider = StateProvider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.getSetting(SettingsService.temperatureUnitKey, 'celsius') ?? 'celsius';
});

final weatherUpdateFrequencyProvider = StateProvider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.getSetting(SettingsService.weatherUpdateFrequencyKey, '30 minutes') ?? '30 minutes';
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
  static const String isAutoLocationKey = 'weather_location_automatic';

  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;

  final _settingsController = StreamController<Map<String, dynamic>>.broadcast();
  late SharedPreferences _prefs;
  
  Stream<Map<String, dynamic>> get settingsStream => _settingsController.stream;

  SettingsService._internal();


  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _initializeDefaultSettings();
    _notifyListeners();
  }

  Future<void> _initializeDefaultSettings() async {
    if (!_prefs.containsKey(temperatureUnitKey)) {
      await _prefs.setString(temperatureUnitKey, 'celsius');
    }
    if (!_prefs.containsKey(weatherUpdateFrequencyKey)) {
      await _prefs.setString(weatherUpdateFrequencyKey, '30 minutes');
    }
    if (!_prefs.containsKey(weatherLocationKey)) {
      await _prefs.setString(weatherLocationKey, 'Automatic');
    }
    if (!_prefs.containsKey(isAutoLocationKey)) {
      await _prefs.setBool(isAutoLocationKey, true);
    }
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
    _notifyListeners();
  }

  T? getSetting<T>(String key, T defaultValue) {
    return _prefs.get(key) as T? ?? defaultValue;
  }

  // Weather specific methods
  Future<void> setWeatherLocation(String location, bool isAutomatic) async {
    await _prefs.setString(weatherLocationKey, location);
    await _prefs.setBool(isAutoLocationKey, isAutomatic);
    _notifyListeners();
  }

  String getWeatherLocation() {
    return _prefs.getString(weatherLocationKey) ?? 'Automatic';
  }

  bool isWeatherLocationAutomatic() {
    return _prefs.getBool(isAutoLocationKey) ?? true;
  }

  Future<Duration> getWeatherUpdateDuration() async {
    final frequency = _prefs.getString(weatherUpdateFrequencyKey) ?? '30 minutes';
    
    switch (frequency) {
      case '15 minutes':
        return const Duration(minutes: 15);
      case '1 hour':
        return const Duration(hours: 1);
      case '3 hours':
        return const Duration(hours: 3);
      default:
        return const Duration(minutes: 30);
    }
  }

  void _notifyListeners() {
    _settingsController.add({
      'temperature_unit': _prefs.getString(temperatureUnitKey),
      'update_frequency': _prefs.getString(weatherUpdateFrequencyKey),
      'weather_location': _prefs.getString(weatherLocationKey),
      'is_auto_location': _prefs.getBool(isAutoLocationKey),
      'theme': _prefs.getString(themeKey),
      'language': _prefs.getString(languageKey),
      'aod_enabled': _prefs.getBool(aodEnabledKey),
      'time_format': _prefs.getString(timeFormatKey),
      'date_format': _prefs.getString(dateFormatKey),
    });
  }

  Future<void> resetAllSettings() async {
    await _prefs.clear();
    await initialize();
  }

  void dispose() {
    _settingsController.close();
  }
}

