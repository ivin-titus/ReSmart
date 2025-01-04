// weather_widget_mini.dart
import 'package:flutter/material.dart';
import './services/weather_service.dart';
import 'weather_widget.dart';
import 'shared_styles.dart';

class MiniWeatherWidget extends StatefulWidget {
  final TextStyle? textStyle;

  const MiniWeatherWidget({
    Key? key,
    this.textStyle,
  }) : super(key: key);

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
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textStyle = widget.textStyle?.copyWith(
              fontSize: SharedStyles.getResponsiveSize(constraints).clamp(20.0, 28.0),
              color: SharedStyles.textColor,
            ) ?? SharedStyles.getBaseTextStyle(constraints);
            
            return Container(
              decoration: SharedStyles.containerDecoration,
              padding: EdgeInsets.all(SharedStyles.containerPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_loading)
                    SharedStyles.loadingIndicator
                  else if (_error != null)
                    Icon(
                      Icons.error_outline,
                      color: SharedStyles.errorColor,
                      size: textStyle.fontSize,
                    )
                  else if (_weatherData != null)
                    Baseline(
                      baseline: textStyle.fontSize! * 0.8,
                      baselineType: TextBaseline.alphabetic,
                      child: Icon(
                        _weatherService.getWeatherIcon(
                          _weatherData!['weather'][0]['description'],
                          time: DateTime.now(),
                          sunrise: DateTime.fromMillisecondsSinceEpoch(
                            _weatherData!['sys']['sunrise'] * 1000
                          ),
                          sunset: DateTime.fromMillisecondsSinceEpoch(
                            _weatherData!['sys']['sunset'] * 1000
                          ),
                        ),
                        color: SharedStyles.textColor,
                        size: textStyle.fontSize,
                      ),
                    ),
                  if (_weatherData != null) ...[
                    const SizedBox(width: 4), // Reduced spacing
                    Baseline(
                      baseline: textStyle.fontSize! * 0.8,
                      baselineType: TextBaseline.alphabetic,
                      child: Text(
                        '${_weatherData!['main']['temp'].round()}°C',
                        style: textStyle,
                        textScaler: const TextScaler.linear(1.0),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}