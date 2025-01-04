import 'package:flutter/material.dart';
import './services/weather_service.dart';
import 'weather_widget.dart';
import 'shared_styles.dart';
import 'dart:async';

class MiniWeatherWidget extends StatefulWidget {
  final TextStyle? textStyle;

  const MiniWeatherWidget({
    Key? key,
    this.textStyle,
  }) : super(key: key);

  @override
  _MiniWeatherWidgetState createState() => _MiniWeatherWidgetState();
}

class _MiniWeatherWidgetState extends State<MiniWeatherWidget> with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  String? _error;
  bool _loading = false;
  StreamSubscription? _weatherSubscription;
  bool _isProcessingTap = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    _initialize();
    _subscribeToWeatherUpdates();
  }

  void _subscribeToWeatherUpdates() {
    _weatherSubscription = _weatherService.weatherStream.listen(
      (data) {
        if (mounted) {
          setState(() {
            _weatherData = data;
            _loading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _error = error.toString();
            _loading = false;
          });
        }
      },
    );
  }

  Future<void> _initialize() async {
    if (!mounted) return;
    
    setState(() => _loading = true);

    try {
      final locationData = await _weatherService.initializeLocation();
      if (!mounted) return;

      if (locationData != null) {
        await _weatherService.fetchWeatherByCoordinates(
          latitude: locationData.latitude!,
          longitude: locationData.longitude!,
        );
      } else {
        _weatherService.showFallbackCityInput(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Weather update failed');
    }
  }

  Future<void> _showWeatherDialog() async {
    if (!mounted || _isProcessingTap) return;
    
    setState(() => _isProcessingTap = true);
    
    try {
      // Simpler animation handling
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => WeatherWidget(
          onClose: () => Navigator.of(context).pop(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingTap = false);
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _weatherSubscription?.cancel();
    super.dispose();
  }

  Widget _buildWeatherContent(TextStyle textStyle) {
    if (_loading) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: SharedStyles.loadingIndicator,
          );
        },
      );
    }

    if (_error != null) {
      return Icon(
        Icons.error_outline,
        color: SharedStyles.errorColor,
        size: textStyle.fontSize,
      );
    }

    if (_weatherData != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              size: textStyle.fontSize! - 5,
            ),
          ),
          const SizedBox(width: 10),
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
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AbsorbPointer(
        absorbing: _isProcessingTap,
        child: InkWell(
          onTap: _showWeatherDialog,
          borderRadius: BorderRadius.circular(100),
          splashColor: const Color.fromARGB(255, 210, 210, 210),
          highlightColor: const Color.fromARGB(255, 219, 219, 219),
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildWeatherContent(textStyle),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}