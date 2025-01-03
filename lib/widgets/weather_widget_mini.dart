// weather_widget_mini.dart

import 'package:flutter/material.dart';
import './services/weather_service.dart';
import 'weather_widget.dart'; // Add this import

class MiniWeatherWidget extends StatefulWidget {
  const MiniWeatherWidget({Key? key}) : super(key: key);

  @override
  _MiniWeatherWidgetState createState() => _MiniWeatherWidgetState();
}

class _MiniWeatherWidgetState extends State<MiniWeatherWidget> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    _subscribeToWeatherUpdates();
  }

  void _subscribeToWeatherUpdates() {
    _weatherService.weatherStream.listen(
      (data) => setState(() => _weatherData = data),
      onError: (error) => setState(() => _error = error.toString()),
    );
  }

  Future<void> _initialize() async {
    setState(() => _loading = true);

    try {
      final locationData = await _weatherService.initializeLocation();
      if (locationData != null) {
        await _weatherService.fetchWeatherByCoordinates(
          latitude: locationData.latitude!,
          longitude: locationData.longitude!,
        );
      } else {
        _weatherService.showFallbackCityInput(context);
      }
    } catch (e) {
      setState(() => _error = 'Weather update failed');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showWeatherDialog() {
    showDialog(
      context: context,
      builder: (context) => WeatherWidget(
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showWeatherDialog,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final iconSize = constraints.maxWidth * 0.15;
          final tempSize = constraints.maxWidth * 0.12;

          return Container(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_loading)
                    const CircularProgressIndicator(color: Colors.white)
                  else if (_error != null)
                    Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: iconSize.clamp(24.0, 32.0),
                    )
                  else if (_weatherData != null)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            WeatherService.weatherIcons[_weatherData!['weather']
                                    [0]['description']] ??
                                Icons.wb_sunny_rounded,
                            color: Colors.white,
                            size: iconSize.clamp(24.0, 32.0),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${_weatherData!['main']['temp'].round()}°C',
                            style: TextStyle(
                              fontSize: tempSize.clamp(20.0, 28.0),
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
