import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeState {
  final ThemeMode themeMode;
  final bool isAmoled;

  ThemeState({
    required this.themeMode,
    required this.isAmoled,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isAmoled,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isAmoled: isAmoled ?? this.isAmoled,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
      : super(ThemeState(themeMode: ThemeMode.system, isAmoled: false)) {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme') ?? 'system';
    final isAmoled = prefs.getBool('isAmoled') ?? false;
    
    state = ThemeState(
      themeMode: _getThemeMode(savedTheme),
      isAmoled: isAmoled,
    );
  }

  ThemeMode _getThemeMode(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void updateTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    
    state = state.copyWith(themeMode: _getThemeMode(theme));
  }

  void toggleAmoled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAmoled', value);
    
    state = state.copyWith(isAmoled: value);
  }
}
