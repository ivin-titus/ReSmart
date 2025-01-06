// settings
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added import
import 'widgets/shared_styles.dart';
import 'widgets/services/settings_service.dart';
import 'widgets/services/weather_service.dart';
import 'widgets/services/theme_provider.dart';

// Make SettingsScreen a ConsumerStatefulWidget instead of StatefulWidget
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

// Change State to ConsumerState
class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Services
  final SettingsService _settingsService = SettingsService();

  // Controllers
  final TextEditingController _customFontSizeController =
      TextEditingController();

  // Theme settings
  String _selectedTheme = 'system';
  String _selectedLanguage = 'english';

  // AOD settings
  bool _isAODEnabled = true;
  String _selectedStyle = 'Default';
  String _selectedFontFamily = 'Roboto';
  String _selectedFontSize = 'Medium';
  bool _avoidScreenBurnIn = true;
  String _timeFormat = '12';
  String _dateFormat = 'mon, 1 jan';
  String _temperatureUnit = 'celsius';
  String _weatherLocation = 'Not set';
  String _weatherUpdateFrequency = '30 minutes';

  // Available options
  final List<String> _availableStyles = ['Default', 'Custom'];
  final List<String> _availableFontFamilies = [
    'Roboto',
    'Arial',
    'Helvetica',
    'Times New Roman',
    'Georgia',
    'Courier New',
    'Verdana',
    'Tahoma',
    'Impact',
    'Comic Sans MS',
  ];

  final List<String> _availableDateFormats = [
    'mon, 1 jan',
    '1/1/2025',
    'jan 1, 2025',
    '1 jan 2025',
  ];

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    await _settingsService.initialize();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _selectedTheme =
          _settingsService.getSetting(SettingsService.themeKey, 'system') ??
              'system';
      _selectedLanguage =
          _settingsService.getSetting(SettingsService.languageKey, 'english') ??
              'english';
      _isAODEnabled =
          _settingsService.getSetting(SettingsService.aodEnabledKey, true) ??
              true;
      _selectedStyle = _settingsService.getSetting(
              SettingsService.selectedStyleKey, 'Default') ??
          'Default';
      _selectedFontFamily = _settingsService.getSetting(
              SettingsService.fontFamilyKey, 'Roboto') ??
          'Roboto';
      _selectedFontSize =
          _settingsService.getSetting(SettingsService.fontSizeKey, 'Medium') ??
              'Medium';
      _avoidScreenBurnIn =
          _settingsService.getSetting(SettingsService.avoidBurnInKey, true) ??
              true;
      _timeFormat =
          _settingsService.getSetting(SettingsService.timeFormatKey, '12') ??
              '12';
      ref.read(timeFormatProvider.notifier).state = _timeFormat;
      _dateFormat = _settingsService.getSetting(
              SettingsService.dateFormatKey, 'mon, 1 jan') ??
          'mon, 1 jan';
      _temperatureUnit = _settingsService.getSetting(
              SettingsService.temperatureUnitKey, 'celsius') ??
          'celsius';
      _weatherUpdateFrequency = _settingsService.getSetting(
              SettingsService.weatherUpdateFrequencyKey, '30 minutes') ??
          '30 minutes';

      String? customFontSize =
          _settingsService.getSetting(SettingsService.customFontSizeKey, '');
      _customFontSizeController.text = customFontSize ?? '';

      String? location = _settingsService.getWeatherLocation();
      _weatherLocation = location;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    await _settingsService.setSetting(key, value);
  }

  Future<void> _resetSettings() async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Settings'),
            content: const Text(
                'This will reset all settings to their default values. Continue?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Reset'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await _settingsService.resetAllSettings();
      _loadSettings();
      ref.read(themeProvider.notifier).updateTheme('system');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings reset successfully')),
        );
      }
    }
  }

  void _updateTimeFormat(String? newValue) async {
    if (newValue != null) {
      await _saveSetting(SettingsService.timeFormatKey, newValue);
      setState(() => _timeFormat = newValue);
      ref.read(timeFormatProvider.notifier).state = newValue;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required Widget trailing,
    String? subtitle,
    IconData? icon,
  }) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: Colors.blue) : null,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
    );
  }

  Widget _buildGeneralSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('General Settings'),
        _buildSettingTile(
          title: 'Theme',
          icon: Icons.palette_outlined,
          trailing: DropdownButton<String>(
            value: _selectedTheme,
            onChanged: (String? newValue) async {
              if (newValue != null) {
                await _saveSetting(SettingsService.themeKey, newValue);
                setState(() => _selectedTheme = newValue);
                // Update the theme using the provider
                ref.read(themeProvider.notifier).updateTheme(newValue);
              }
            },
            items: ['system', 'dark', 'light']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.capitalize()),
              );
            }).toList(),
          ),
        ),
        _buildSettingTile(
          title: 'Language',
          icon: Icons.language,
          trailing: DropdownButton<String>(
            value: _selectedLanguage,
            onChanged: null, // Disabled as only English is available
            items: ['english'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.capitalize()),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplaySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Display Settings'),
        _buildSettingTile(
          title: 'Always On Display',
          icon: Icons.screen_lock_portrait_outlined,
          trailing: Switch(
            value: _isAODEnabled,
            onChanged: (bool value) async {
              await _saveSetting(SettingsService.aodEnabledKey, value);
              setState(() => _isAODEnabled = value);
            },
          ),
        ),
        _buildAODSettings(),
      ],
    );
  }

  Widget _buildAODSettings() {
    return Column(
      children: [
        _buildSettingTile(
          title: 'Style',
          icon: Icons.style,
          trailing: DropdownButton<String>(
            value: _selectedStyle,

            // introduced later
            onChanged: null,
            /* (String? newValue) async {
              if (newValue != null) {
                await _saveSetting(SettingsService.selectedStyleKey, newValue);
                setState(() => _selectedStyle = newValue);
              }
            },*/
            items:
                _availableStyles.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        if (_selectedStyle == 'Custom') ...[
          _buildCustomStyleSettings(),
        ],
        _buildSettingTile(
          title: 'Avoid Screen Burn-in',
          icon: Icons.screen_rotation,
          trailing: Switch(
            value: _avoidScreenBurnIn,
            // introduced later
            onChanged:
                null, /*(bool value) async {
              await _saveSetting(SettingsService.avoidBurnInKey, value);
              setState(() => _avoidScreenBurnIn = value);
            },*/
          ),
        ),
        _buildTimeAndDateSettings(),
        _buildWeatherSettings(),
      ],
    );
  }

  Widget _buildCustomStyleSettings() {
    return Column(
      children: [
        const SizedBox(height: 15),
        ListTile(
          leading: const Icon(Icons.widgets_outlined, color: Colors.blue),
          title: const Text('Customize Widgets'),
          trailing: ElevatedButton(
            onPressed: () {
              // Navigate to widget customization screen
            },
            child: const Text('Customize'),
          ),
        ),
        _buildSettingTile(
          title: 'Font Family',
          icon: Icons.font_download_outlined,
          trailing: DropdownButton<String>(
            value: _selectedFontFamily,
            onChanged: (String? newValue) async {
              if (newValue != null) {
                await _saveSetting(SettingsService.fontFamilyKey, newValue);
                setState(() => _selectedFontFamily = newValue);
              }
            },
            items: _availableFontFamilies
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.text_fields, color: Colors.blue),
          title: const Text('Font Size'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: _selectedFontSize,
                onChanged: (String? newValue) async {
                  if (newValue != null) {
                    await _saveSetting(SettingsService.fontSizeKey, newValue);
                    setState(() => _selectedFontSize = newValue);
                  }
                },
                items: ['Small', 'Medium', 'Large', 'Custom']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              if (_selectedFontSize == 'Custom') ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _customFontSizeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onChanged: (value) async {
                      await _saveSetting(
                          SettingsService.customFontSizeKey, value);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildTimeAndDateSettings() {
    return Column(
      children: [
        _buildSettingTile(
          title: 'Time Format',
          icon: Icons.access_time,
          trailing: DropdownButton<String>(
            value: _timeFormat,
            onChanged: _updateTimeFormat,
            items: ['12', '24'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('${value}h'),
              );
            }).toList(),
          ),
        ),
        _buildSettingTile(
          title: 'Date Format',
          icon: Icons.calendar_today,
          trailing: DropdownButton<String>(
            value: _dateFormat,
            onChanged: (String? newValue) async {
              if (newValue != null) {
                await _saveSetting(SettingsService.dateFormatKey, newValue);
                setState(() => _dateFormat = newValue);
                // Update the provider state
                ref.read(dateFormatProvider.notifier).state = newValue;
              }
            },
            items: _availableDateFormats
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherSettings() {
    return Column(
      children: [
        _buildSettingTile(
          title: 'Temperature Unit',
          icon: Icons.thermostat_outlined,
          trailing: DropdownButton<String>(
            value: _temperatureUnit,
            onChanged: (String? newValue) async {
              if (newValue != null) {
                await _saveSetting(
                    SettingsService.temperatureUnitKey, newValue);
                setState(() => _temperatureUnit = newValue);
              }
            },
            items: ['celsius', 'fahrenheit']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.capitalize()),
              );
            }).toList(),
          ),
        ),
        _buildWeatherLocationField(),
        _buildSettingTile(
          title: 'Update Frequency',
          icon: Icons.update,
          trailing: DropdownButton<String>(
            value: _weatherUpdateFrequency,
            onChanged: (String? newValue) async {
              if (newValue != null) {
                await _saveSetting(
                    SettingsService.weatherUpdateFrequencyKey, newValue);
                setState(() => _weatherUpdateFrequency = newValue);
              }
            },
            items: ['15 minutes', '30 minutes', '1 hour', '3 hours']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherLocationField() {
    final isAutomatic = _settingsService.isWeatherLocationAutomatic();
    final location = _settingsService.getWeatherLocation();

    return _buildSettingTile(
      title: 'Location',
      icon: Icons.location_on_outlined,
      subtitle: isAutomatic ? 'Using automatic location' : location,
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        // introduced late
        onPressed:
            null, /*() async {
          await WeatherService().handleLocationSelection(context);
          _loadSettings();
        },*/
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('About'),
        ListTile(
          leading: const Icon(Icons.info_outline, color: Colors.blue),
          title: const Text('Version'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined, color: Colors.blue),
          title: const Text('Privacy Policy & Terms'),
          onTap: () {
            // Navigate to privacy policy
          },
        ),
        ListTile(
          leading: const Icon(Icons.person_outline, color: Colors.blue),
          title: const Text('Developer Info'),
          onTap: () {
            // Show developer info
          },
        ),
      ],
    );
  }

  Widget _buildTroubleshootSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Troubleshoot'),
        ListTile(
          leading: const Icon(Icons.restart_alt, color: Colors.blue),
          title: const Text('Reset Settings'),
          subtitle: const Text('Restore all settings to default values'),
          onTap: _resetSettings,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            expandedHeight: 120.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reserved space for account login (future feature)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(171, 40, 40, 40),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.account_circle_outlined),
                      SizedBox(width: 16),
                      Text('Login feature coming soon'),
                    ],
                  ),
                ),
                _buildGeneralSettings(),
                _buildDisplaySettings(),
                _buildTroubleshootSection(),
                //const SizedBox(height: 32),
                _buildAboutSection(),
                const SizedBox(height: 32), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
