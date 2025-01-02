// location_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String LAT_KEY = 'last_latitude';
  static const String LON_KEY = 'last_longitude';
  final _prefs = SharedPreferences.getInstance();

  Future<void> saveLocation(double latitude, double longitude) async {
    final prefs = await _prefs;
    await prefs.setDouble(LAT_KEY, latitude);
    await prefs.setDouble(LON_KEY, longitude);
  }

  Future<Map<String, double>?> getLastLocation() async {
    final prefs = await _prefs;
    final lat = prefs.getDouble(LAT_KEY);
    final lon = prefs.getDouble(LON_KEY);
    
    if (lat != null && lon != null) {
      return {'latitude': lat, 'longitude': lon};
    }
    return null;
  }
}