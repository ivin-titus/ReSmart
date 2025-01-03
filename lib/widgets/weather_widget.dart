// weather_widget.dart
import 'package:flutter/material.dart';
import 'services/weather_service.dart';

class WeatherWidget extends StatefulWidget {
  final VoidCallback? onClose;
  const WeatherWidget({Key? key, this.onClose}) : super(key: key);

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
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

  @override
  Widget build(BuildContext context) {
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
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
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
    final weatherDescription = _weatherData!['weather'][0]['description'];
    final IconData weatherIcon = WeatherService.weatherIcons[weatherDescription] ?? 
        Icons.question_mark_rounded;

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
                  const Icon(Icons.location_on_rounded, 
                    color: Colors.white70, size: 20),
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
              icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
              onPressed: _initialize,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(weatherIcon, color: Colors.white, size: 40),
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
          weatherDescription.toString().toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _buildWeatherDetails(),
      ],
    );
  }

  Widget _buildWeatherDetails() {
    return Container(
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
            VerticalDivider(color: Colors.white.withOpacity(0.2), thickness: 1),
            Expanded(
              child: _buildDetailColumn(
                Icons.air_rounded,
                'Wind',
                '${_weatherData!['wind']['speed']} m/s',
              ),
            ),
            VerticalDivider(color: Colors.white.withOpacity(0.2), thickness: 1),
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
    );
  }

  Widget _buildDetailColumn(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
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
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
        const SizedBox(height: 8),
        Text(
          _error ?? 'Error loading weather data',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _initialize,
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text('Try Again', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}