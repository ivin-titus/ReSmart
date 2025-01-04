import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'devices_tab.dart';
import 'ai_tab.dart';
import 'aod_screen.dart';
import 'settings.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const DevicesTab(),
    const AITab(),
    const AODScreen(),
    const SettingsTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAODScreen = _selectedIndex == 3;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: isAODScreen
          ? null
          : NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: const Color(0xFF1E1E1E),
                indicatorColor: Colors.deepPurpleAccent.withOpacity(0.3),
                labelTextStyle: MaterialStateProperty.all(
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.devices_outlined),
                    selectedIcon: Icon(Icons.devices),
                    label: 'Device',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.smart_toy_outlined),
                    selectedIcon: Icon(Icons.smart_toy),
                    label: 'AI Assistant',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.screen_lock_portrait_outlined),
                    selectedIcon: Icon(Icons.screen_lock_portrait),
                    label: 'AOD Screen',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
    );
  }
}