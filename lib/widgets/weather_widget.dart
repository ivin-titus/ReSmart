import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import 'dart:async';
import './config/env.dart';

class WeatherWidget extends StatefulWidget {
  final VoidCallback? onClose;
  const WeatherWidget({
    Key? key, 
    this.onClose,
  }) : super(key: key);

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
  
  Map<String, Image> _iconCache = {};

  // Weather icon mapping
  final Map<String, IconData> _weatherIcons = {
    'Clear': Icons.wb_sunny_rounded,
    'Clouds': Icons.cloud_rounded,
    'Rain': Icons.water_drop_rounded,
    'Drizzle': Icons.grain_rounded,
    'Thunderstorm': Icons.flash_on_rounded,
    'Snow': Icons.ac_unit_rounded,
    'Mist': Icons.cloud_rounded,
    'Smoke': Icons.cloud_rounded,
    'Haze': Icons.cloud_rounded,
    'Dust': Icons.cloud_rounded,
    'Fog': Icons.cloud_rounded,
  };

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
    
    
  return Center(
    child: Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildContent(),
          ),
          if (widget.onClose != null)
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: widget.onClose,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    ),
  );
}

  

  Widget _buildContent() {
    if (_loading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
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
      height: 120,
      child: Center(
        child: Text(
          'No weather data available',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo() {
    final weatherMain = _weatherData!['weather'][0]['main'] as String;
    final IconData weatherIcon = _weatherIcons[weatherMain] ?? Icons.question_mark_rounded;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _weatherData!['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white70,
              ),
              onPressed: _fetchWeatherWithLocation,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              weatherIcon,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(width: 16),
            Text(
              '${_weatherData!['main']['temp'].round()}°C',
              style: const TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _weatherData!['weather'][0]['description'].toString().toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildDetailColumn(
                    Icons.water_drop_outlined,
                    'Humidity',
                    '${_weatherData!['main']['humidity']}%',
                  ),
                ),
                VerticalDivider(
                  color: Colors.white.withOpacity(0.2),
                  thickness: 1,
                ),
                Expanded(
                  child: _buildDetailColumn(
                    Icons.air_rounded,
                    'Wind',
                    '${_weatherData!['wind']['speed']} m/s',
                  ),
                ),
                VerticalDivider(
                  color: Colors.white.withOpacity(0.2),
                  thickness: 1,
                ),
                Expanded(
                  child: _buildDetailColumn(
                    Icons.thermostat_rounded,
                    'Feels Like',
                    '${_weatherData!['main']['feels_like'].round()}°C',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailColumn(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.redAccent,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          _error ?? 'Error loading weather data',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _initializeLocationWithRetry,
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text(
            'Try Again',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}