import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import 'dart:async';
import './config/env.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> with AutomaticKeepAliveClientMixin {
  Map<String, dynamic>? _weatherData;
  String? _error;
  bool _loading = false;
  final Location _location = Location();
  String? _fallbackCity;
  final TextEditingController _cityController = TextEditingController();
  Timer? _locationUpdateTimer;
  Timer? _weatherUpdateTimer;
  bool _isDisposed = false;
  
  // Cache weather icon
  Map<String, Image> _iconCache = {};

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _initializeWithDelay();
  }

  // Delayed initialization to prevent UI jank during app startup
  Future<void> _initializeWithDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_isDisposed) {
      _initializeLocationWithRetry();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _locationUpdateTimer?.cancel();
    _weatherUpdateTimer?.cancel();
    _cityController.dispose();
    _iconCache.clear();
    super.dispose();
  }

  Future<void> _initializeLocationWithRetry() async {
    if (_loading || _isDisposed) return;

    int retryCount = 0;
    const maxRetries = 2;

    while (retryCount < maxRetries && !_isDisposed) {
      try {
        await _initializeLocationAndWeather();
        break;
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          if (!_isDisposed) {
            _showFallbackCityInput();
          }
          break;
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }

  Future<void> _initializeLocationAndWeather() async {
    if (_isDisposed) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Optimize location settings for legacy devices
      await _location.changeSettings(
        accuracy: LocationAccuracy.balanced,
        interval: 30000,
        distanceFilter: 100,
      );

      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) throw Exception('Location disabled');
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) {
          throw Exception('Permission denied');
        }
      }

      final locationData = await _getLocationWithTimeout();
      if (locationData != null) {
        await _fetchWeather(
          lat: locationData.latitude,
          lon: locationData.longitude,
        );
        _setupUpdates();
      } else {
        throw Exception('Location unavailable');
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _error = 'Location error';
          _loading = false;
        });
        _showFallbackCityInput();
      }
    }
  }

  Future<LocationData?> _getLocationWithTimeout() async {
    try {
      return await _location.getLocation().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Timeout'),
      );
    } catch (e) {
      return null;
    }
  }

  void _setupUpdates() {
    // Cancel existing timers
    _locationUpdateTimer?.cancel();
    _weatherUpdateTimer?.cancel();

    // Update weather every 30 minutes
    _weatherUpdateTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _fetchWeatherWithLocation(),
    );

    // Update location every hour
    _locationUpdateTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _fetchWeatherWithLocation(),
    );
  }

  Future<void> _fetchWeatherWithLocation() async {
    if (_loading || _isDisposed) return;

    try {
      final locationData = await _location.getLocation();
      await _fetchWeather(
        lat: locationData.latitude,
        lon: locationData.longitude,
      );
    } catch (e) {
      // Don't update state if we already have weather data
      if (_weatherData == null && !_isDisposed) {
        setState(() {
          _error = 'Update failed';
          _loading = false;
        });
      }
    }
  }

  Future<void> _fetchWeather({double? lat, double? lon}) async {
    if (_isDisposed) return;

    try {
      final String url = lat != null && lon != null
          ? 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=${Environment.weatherApiKey}&units=metric'
          : 'https://api.openweathermap.org/data/2.5/weather?q=${_fallbackCity ?? "London"}&appid=${Environment.weatherApiKey}&units=metric';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (_isDisposed) return;

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _loading = false;
        });
      } else {
        throw Exception('API Error');
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _error = 'Weather update failed';
          _loading = false;
        });
      }
    }
  }

void _showFallbackCityInput() {
  if (_isDisposed || !mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
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
                controller: _cityController,
                decoration: const InputDecoration(
                  hintText: 'City name',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    Navigator.of(context).pop();
                    _fetchWeatherByCity(value);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeLocationWithRetry();
            },
            child: const Text('Try Location'),
          ),
          TextButton(
            onPressed: () {
              if (_cityController.text.isNotEmpty) {
                Navigator.of(context).pop();
                _fetchWeatherByCity(_cityController.text);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}

Future<void> _fetchWeatherByCity(String city) async {
  if (_isDisposed || !mounted) return;

  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final response = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=${Environment.weatherApiKey}&units=metric'
      ),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 5));

    if (_isDisposed) return;

    if (response.statusCode == 200) {
      setState(() {
        _weatherData = json.decode(response.body);
        _loading = false;
        _fallbackCity = city;
      });

      // Setup updates after successful manual city entry
      _setupUpdates();
    } else {
      throw Exception('City not found');
    }
  } catch (e) {
    if (!_isDisposed) {
      setState(() {
        _error = 'Invalid city. Please try again.';
        _loading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return RepaintBoundary(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_weatherData != null) {
      return _buildWeatherInfo();
    }

    return const SizedBox(
      height: 100,
      child: Center(
        child: Text('No data'),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.red),
        const SizedBox(height: 8),
        Text(_error ?? 'Error'),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _initializeLocationWithRetry,
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildWeatherInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _weatherData!['name'],
                style: const TextStyle(fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchWeatherWithLocation,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${_weatherData!['main']['temp'].round()}°C',
          style: const TextStyle(fontSize: 24),
        ),
        Text(
          _weatherData!['weather'][0]['description'].toString(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        _buildWeatherDetails(),
      ],
    );
  }

  Widget _buildWeatherDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildDetailColumn('Humidity', '${_weatherData!['main']['humidity']}%'),
        _buildDetailColumn('Wind', '${_weatherData!['wind']['speed']} m/s'),
        _buildDetailColumn('Feels', '${_weatherData!['main']['feels_like'].round()}°C'),
      ],
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

