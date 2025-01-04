import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsProvider extends ChangeNotifier {
  static final SettingsProvider _instance = SettingsProvider._internal();
  factory SettingsProvider() => _instance;
  SettingsProvider._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  // Theme
  bool _isDarkMode = true;
  String _selectedFont = 'Roboto';
  double _fontSize = 1.0;
  
  // Weather
  bool _showWeather = true;
  String _temperatureUnit = 'celsius';
  
  // Date & Time
  bool _show24HourFormat = false;
  String _dateFormat = 'E, d MMM';
  
  // Display
  double _brightness = 1.0;
  
  // Getters
  bool get isDarkMode => _isDarkMode;
  String get selectedFont => _selectedFont;
  double get fontSize => _fontSize;
  bool get showWeather => _showWeather;
  String get temperatureUnit => _temperatureUnit;
  bool get show24HourFormat => _show24HourFormat;
  String get dateFormat => _dateFormat;
  double get brightness => _brightness;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    
    _isDarkMode = _prefs.getBool('isDarkMode') ?? true;
    _selectedFont = _prefs.getString('selectedFont') ?? 'Roboto';
    _fontSize = _prefs.getDouble('fontSize') ?? 1.0;
    _showWeather = _prefs.getBool('showWeather') ?? true;
    _temperatureUnit = _prefs.getString('temperatureUnit') ?? 'celsius';
    _show24HourFormat = _prefs.getBool('show24HourFormat') ?? false;
    _dateFormat = _prefs.getString('dateFormat') ?? 'E, d MMM';
    _brightness = _prefs.getDouble('brightness') ?? 1.0;
    
    _initialized = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setFont(String font) async {
    _selectedFont = font;
    await _prefs.setString('selectedFont', font);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await _prefs.setDouble('fontSize', size);
    notifyListeners();
  }

  Future<void> setShowWeather(bool value) async {
    _showWeather = value;
    await _prefs.setBool('showWeather', value);
    notifyListeners();
  }

  Future<void> setTemperatureUnit(String unit) async {
    _temperatureUnit = unit;
    await _prefs.setString('temperatureUnit', unit);
    notifyListeners();
  }

  Future<void> set24HourFormat(bool value) async {
    _show24HourFormat = value;
    await _prefs.setBool('show24HourFormat', value);
    notifyListeners();
  }

  Future<void> setDateFormat(String format) async {
    _dateFormat = format;
    await _prefs.setString('dateFormat', format);
    notifyListeners();
  }

  Future<void> setBrightness(double value) async {
    _brightness = value;
    await _prefs.setDouble('brightness', value);
    notifyListeners();
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: Theme.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          elevation: 0,
        ),
        body: ListView(
          children: [
            _buildThemeSection(context),
            _buildDisplaySection(context),
            _buildWeatherSection(context),
            _buildDateTimeSection(context),
            _buildFontSection(context),
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    final settings = SettingsProvider();
    
    return _buildSection(
      'Theme',
      [
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: settings.isDarkMode,
          onChanged: settings.setDarkMode,
        ),
        ListTile(
          title: const Text('Brightness'),
          subtitle: Slider(
            value: settings.brightness,
            onChanged: settings.setBrightness,
          ),
        ),
      ],
    );
  }

  Widget _buildDisplaySection(BuildContext context) {
    final settings = SettingsProvider();
    
    return _buildSection(
      'Display',
      [
        SwitchListTile(
          title: const Text('Show Weather'),
          value: settings.showWeather,
          onChanged: settings.setShowWeather,
        ),
      ],
    );
  }

  Widget _buildWeatherSection(BuildContext context) {
    final settings = SettingsProvider();
    
    return _buildSection(
      'Weather',
      [
        ListTile(
          title: const Text('Temperature Unit'),
          trailing: DropdownButton<String>(
            value: settings.temperatureUnit,
            items: const [
              DropdownMenuItem(value: 'celsius', child: Text('Celsius')),
              DropdownMenuItem(value: 'fahrenheit', child: Text('Fahrenheit')),
            ],
            onChanged: (value) => settings.setTemperatureUnit(value!),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(BuildContext context) {
    final settings = SettingsProvider();
    
    return _buildSection(
      'Date & Time',
      [
        SwitchListTile(
          title: const Text('24-Hour Format'),
          value: settings.show24HourFormat,
          onChanged: settings.set24HourFormat,
        ),
        ListTile(
          title: const Text('Date Format'),
          trailing: DropdownButton<String>(
            value: settings.dateFormat,
            items: const [
              DropdownMenuItem(value: 'E, d MMM', child: Text('Mon, 1 Jan')),
              DropdownMenuItem(value: 'EEEE, d MMMM', child: Text('Monday, 1 January')),
              DropdownMenuItem(value: 'd/M/y', child: Text('1/1/2024')),
            ],
            onChanged: (value) => settings.setDateFormat(value!),
          ),
        ),
      ],
    );
  }

  Widget _buildFontSection(BuildContext context) {
    final settings = SettingsProvider();
    
    return _buildSection(
      'Font Settings',
      [
        ListTile(
          title: const Text('Font Family'),
          trailing: DropdownButton<String>(
            value: settings.selectedFont,
            items: [
              'Roboto',
              'Poppins',
              'Montserrat',
              'OpenSans',
              'Lato'
            ].map((font) => DropdownMenuItem(value: font, child: Text(font))).toList(),
            onChanged: (value) => settings.setFont(value!),
          ),
        ),
        ListTile(
          title: const Text('Font Size'),
          subtitle: Slider(
            value: settings.fontSize,
            min: 0.8,
            max: 1.2,
            divisions: 4,
            label: '${(settings.fontSize * 100).round()}%',
            onChanged: settings.setFontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      'About',
      [
        const ListTile(
          title: Text('Version'),
          trailing: Text('1.0.0'),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}