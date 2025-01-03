// weather_widget_mini.dart

import 'package:flutter/material.dart';
import './services/weather_service.dart';
import 'weather_widget.dart'; 
import 'shared_styles.dart';

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
          final iconSize = SharedStyles.getResponsiveIconSize(constraints);
          
          return Container(
            decoration: SharedStyles.containerDecoration,
            child: Padding(
              padding: EdgeInsets.all(SharedStyles.containerPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_loading)
                    SharedStyles.loadingIndicator
                  else if (_error != null)
                    Icon(
                      Icons.error_outline,
                      color: SharedStyles.errorColor,
                      size: iconSize.clamp(24.0, 32.0),
                    )
                  else if (_weatherData != null)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            WeatherService.weatherIcons[_weatherData!['weather'][0]['description']] ??
                                Icons.wb_sunny_rounded,
                            color: SharedStyles.textColor,
                            size: iconSize.clamp(24.0, 32.0),
                          ),
                          SizedBox(width: SharedStyles.iconSpacing),
                          Text(
                            '${_weatherData!['main']['temp'].round()}°C',
                            style: SharedStyles.getBaseTextStyle(constraints),
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