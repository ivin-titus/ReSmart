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
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAODScreen = _selectedIndex == 3;
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: isAODScreen
          ? null
          : NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: brightness == Brightness.light
                    ? Colors.white
                    : const Color(0xFF1E1E1E),
                indicatorColor: brightness == Brightness.light
                    ? Colors.deepPurpleAccent.withOpacity(0.15)
                    : Colors.deepPurpleAccent.withOpacity(0.3),
                labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      );
                    }
                    return const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    );
                  },
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
                    label: 'AI',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.screen_lock_portrait_outlined),
                    selectedIcon: Icon(Icons.screen_lock_portrait),
                    label: 'AOD',
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
