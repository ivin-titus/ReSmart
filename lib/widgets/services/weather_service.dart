// weatherservice

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:resmart/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import '../config/env.dart';
import './weather_icon_provider.dart';
import 'package:resmart/widgets/services/settings_service.dart';
import 'package:resmart/widgets/location_dialog.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;

  final _weatherController = StreamController<Map<String, dynamic>>.broadcast();
  final Location _location = Location();
  final WeatherIconProvider _iconProvider = WeatherIconProvider();
  Timer? _updateTimer;
  DateTime? _lastFetch;
  bool _isDisposed = false;

  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  static const Duration _cacheValidity = Duration(minutes: 15);
  static const String _lastLocationKey = 'last_location';
  static const String _lastWeatherKey = 'last_weather';
  static const String _locationPermissionKey = 'location_permission_status';

  WeatherService._internal();

  Stream<Map<String, dynamic>> get weatherStream => _weatherController.stream;

  // Get weather icon based on condition and time
  IconData getWeatherIcon(String condition,
      {DateTime? time, DateTime? sunrise, DateTime? sunset}) {
    return _iconProvider.getWeatherIcon(condition,
        time: time, sunrise: sunrise, sunset: sunset);
  }

  Future<LocationData?> initializeLocation() async {
    try {
      // Check if we already have permission
      final prefs = await SharedPreferences.getInstance();
      final hasStoredPermission =
          prefs.getBool(_locationPermissionKey) ?? false;

      if (hasStoredPermission) {
        // Try to get last known location first
        final lastLocation = await getLastLocation();
        if (lastLocation != null) {
          await fetchWeatherByCoordinates(
            latitude: lastLocation['latitude'],
            longitude: lastLocation['longitude'],
          );
        }
      }

      await _location.changeSettings(
        accuracy: LocationAccuracy.balanced,
        interval: 30000,
        distanceFilter: 100,
      );

      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return _fallbackToLastLocation();
        }
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) {
          return _fallbackToLastLocation();
        }
      }

      // Store permission status
      if (permission == PermissionStatus.granted) {
        await prefs.setBool(_locationPermissionKey, true);
      }

      return await _location.getLocation().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Location timeout'),
          );
    } catch (e) {
      return _fallbackToLastLocation();
    }
  }

  Future<LocationData?> _fallbackToLastLocation() async {
    final lastLocation = await getLastLocation();
    if (lastLocation != null) {
      return LocationData.fromMap({
        'latitude': lastLocation['latitude'],
        'longitude': lastLocation['longitude'],
      });
    }
    return null;
  }

  // In weather_service.dart
  Future<void> handleLocationSelection(BuildContext context) async {
    final settingsService = SettingsService();
    final currentLocation = settingsService.getWeatherLocation();

    showDialog(
      context: context,
      builder: (context) => LocationDialog(
        initialLocation: currentLocation,
        onLocationSubmitted: (location) async {
          await settingsService.setWeatherLocation(location, false);
          await fetchWeatherByCity(location);
        },
        onAutoLocationRequested: () async {
          final locationData = await initializeLocation();
          if (locationData != null) {
            await fetchWeatherByCoordinates(
              latitude: locationData.latitude!,
              longitude: locationData.longitude!,
            );
            await settingsService.setWeatherLocation('Automatic', true);
          } else {
            _showLocationPermissionDialog(context);
          }
        },
      ),
    );
  }

  void _showLocationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Access Required'),
        content: const Text(
            'Please enable location services and grant location permissions to use automatic location.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SettingsScreen();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void showFallbackCityInput(BuildContext context) {
    // Only show if we don't have any cached location
    getLastLocation().then((lastLocation) {
      if (lastLocation == null) {
        _showCityInputDialog(context);
      }
    });
  }

  void _showCityInputDialog(BuildContext context) {
    final TextEditingController cityController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Enter City'),
        content: SizedBox(
          width: double.minPositive,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Location unavailable. Enter city manually.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  hintText: 'City name',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    Navigator.of(context).pop(value);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final locationData = await initializeLocation();
              if (locationData != null) {
                await fetchWeatherByCoordinates(
                  latitude: locationData.latitude!,
                  longitude: locationData.longitude!,
                );
              } else {
                if (!_isDisposed) _showCityInputDialog(context);
              }
            },
            child: const Text('Try Location'),
          ),
          TextButton(
            onPressed: () {
              if (cityController.text.isNotEmpty) {
                Navigator.of(context).pop(cityController.text);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    ).then((city) {
      if (city != null && city is String) {
        fetchWeatherByCity(city);
      }
    });
  }

  Future<Map<String, dynamic>> fetchWeatherByCoordinates({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheValidity) {
      final cached = await _getCachedWeather();
      if (cached != null) {
        _weatherController.add(cached);
        return cached;
      }
    }

    final weatherData = await _fetchFromApi(
      queryParams: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      },
    );

    await _cacheLocation(latitude, longitude);
    await _cacheWeather(weatherData);

    _weatherController.add(weatherData);
    _lastFetch = DateTime.now();
    _setupUpdateTimer();

    return weatherData;
  }

  Future<Map<String, dynamic>> fetchWeatherByCity(String city) async {
    final weatherData = await _fetchFromApi(
      queryParams: {'q': city},
    );

    _weatherController.add(weatherData);
    _lastFetch = DateTime.now();
    _setupUpdateTimer();

    await _cacheWeather(weatherData);
    return weatherData;
  }

  Future<Map<String, dynamic>> _fetchFromApi({
    required Map<String, String> queryParams,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        ...queryParams,
        'appid': Environment.weatherApiKey,
        'units': 'metric',
      },
    );

    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw WeatherException('API Error: ${response.statusCode}');
    } catch (e) {
      throw WeatherException(e.toString());
    }
  }

  void _setupUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _lastFetch = null,
    );
  }

  Future<Map<String, dynamic>?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationJson = prefs.getString(_lastLocationKey);
    if (locationJson == null) return null;
    return json.decode(locationJson);
  }

  Future<void> _cacheLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLocationKey,
        json.encode({'latitude': latitude, 'longitude': longitude}));
  }

  Future<Map<String, dynamic>?> _getCachedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final weatherJson = prefs.getString(_lastWeatherKey);
    if (weatherJson == null) return null;
    return json.decode(weatherJson);
  }

  Future<void> _cacheWeather(Map<String, dynamic> weather) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastWeatherKey, json.encode(weather));
  }

  void dispose() {
    _isDisposed = true;
    _updateTimer?.cancel();
    _weatherController.close();
  }
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);
  @override
  String toString() => message;
}
