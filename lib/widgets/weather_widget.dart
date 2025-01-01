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

class _WeatherWidgetState extends State<WeatherWidget> {
  Map<String, dynamic>? _weatherData;
  String? _error;
  bool _loading = false;
  final Location _location = Location();
  String? _fallbackCity;
  final TextEditingController _cityController = TextEditingController();
  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocationWithRetry();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocationWithRetry() async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        await _initializeLocationAndWeather();
        break;
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          _showFallbackCityInput();
          break;
        }
        // Wait before retrying
        await Future.delayed(Duration(seconds: 2 * retryCount));
      }
    }
  }

  Future<void> _initializeLocationAndWeather() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Configure location settings for better accuracy on older devices
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 10000, // Update interval in milliseconds
        distanceFilter: 10, // Minimum distance (meters) before updates
      );

      // Check if location service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled');
        }
      }

      // Check permissions
      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) {
          throw Exception('Location permission denied');
        }
      }

      // Get location with timeout
      LocationData? locationData = await _getLocationWithTimeout();
      
      if (locationData != null) {
        await _fetchWeather(
          lat: locationData.latitude,
          lon: locationData.longitude,
        );
        
        // Set up periodic location updates
        _setupLocationUpdates();
      } else {
        throw Exception('Could not get location');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      _showFallbackCityInput();
    }
  }

  Future<LocationData?> _getLocationWithTimeout() async {
    try {
      return await _location.getLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Location request timed out'),
      );
    } on TimeoutException {
      return null;
    }
  }

  void _setupLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _fetchWeatherWithLocation();
    });
  }

  Future<void> _fetchWeatherWithLocation() async {
    try {
      LocationData locationData = await _location.getLocation();
      await _fetchWeather(
        lat: locationData.latitude,
        lon: locationData.longitude,
      );
    } catch (e) {
      if (_weatherData == null) {
        setState(() {
          _error = 'Error updating location';
          _loading = false;
        });
      }
    }
  }

  Future<void> _fetchWeatherByCity(String city) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=${Environment.weatherApiKey}&units=metric'));

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _loading = false;
          _fallbackCity = city;
        });
      } else {
        throw Exception('Failed to load weather data for $city');
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading weather data. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _fetchWeather({double? lat, double? lon}) async {
    try {
      final String url = lat != null && lon != null
          ? 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=${Environment.weatherApiKey}&units=metric'
          : 'https://api.openweathermap.org/data/2.5/weather?q=${_fallbackCity ?? "London"}&appid=${Environment.weatherApiKey}&units=metric';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _loading = false;
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading weather data. Please try again.';
        _loading = false;
      });
    }
  }

  void _showFallbackCityInput() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Your City'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Location services not available. Please enter your city manually.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  hintText: 'Enter city name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                textCapitalization: TextCapitalization.words,
                autofocus: true,
                onSubmitted: (value) {
                  Navigator.of(context).pop();
                  if (value.isNotEmpty) {
                    _fetchWeatherByCity(value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeLocationWithRetry();
              },
              child: const Text('Try Location Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_cityController.text.isNotEmpty) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Getting weather information...'),
                  ],
                ),
              )
            else if (_error != null) ...[
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _initializeLocationWithRetry,
                    child: const Text('Try Again'),
                  ),
                  SizedBox(width: 16),
                  TextButton(
                    onPressed: _showFallbackCityInput,
                    child: const Text('Enter City Manually'),
                  ),
                ],
              ),
            ] else if (_weatherData != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _weatherData!['name'],
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_weatherData!['sys']?['country'] != null)
                          Text(
                            _weatherData!['sys']['country'],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_location),
                    onPressed: _showFallbackCityInput,
                    tooltip: 'Change location',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Image.network(
                'https://openweathermap.org/img/wn/${_weatherData!['weather'][0]['icon']}@2x.png',
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.cloud, size: 100, color: Colors.blue);
                },
              ),
              Text(
                '${_weatherData!['main']['temp'].round()}°C',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                _weatherData!['weather'][0]['description'].toString().toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('Humidity'),
                      Text('${_weatherData!['main']['humidity']}%'),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Wind'),
                      Text('${_weatherData!['wind']['speed']} m/s'),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Feels Like'),
                      Text('${_weatherData!['main']['feels_like'].round()}°C'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _initializeLocationWithRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Update Location'),
              ),
            ] else
              const Center(
                child: Text('No weather data available'),
              ),
          ],
        ),
      ),
    );
  }
}