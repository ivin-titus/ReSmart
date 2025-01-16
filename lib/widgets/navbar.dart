import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/tools_tab.dart';
import '../screens/devices_tab.dart';
import '../screens/assistant_tab.dart';
import '../screens/aod_screen.dart';
import '../screens/settings_tab.dart';
import '../config/theme.dart';

class NavBar extends ConsumerStatefulWidget {
  const NavBar({super.key});

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DevicesTab(),
    const ToolsTab(),
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
    final themeState = ref.watch(themeProvider);
    final bool isAODScreen = _selectedIndex == 3;
    final brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;

    // Determine background color based on theme and AMOLED mode
    final backgroundColor = isDark
        ? (themeState.isAmoled
            ? Colors.black
            : const Color.fromARGB(255, 27, 27, 27))
        : Colors.white;

    // Adjust indicator color for AMOLED mode
    final indicatorColor = isDark
        ? (themeState.isAmoled
            ? Colors.deepPurpleAccent.withOpacity(0.4)
            : Colors.deepPurpleAccent.withOpacity(0.3))
        : Colors.deepPurpleAccent.withOpacity(0.15);

    // Adjust text and icon colors for AMOLED mode
    final selectedColor = isDark && themeState.isAmoled ? Colors.white : null;
    final unselectedColor =
        isDark && themeState.isAmoled ? Colors.white.withOpacity(0.7) : null;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: isAODScreen
          ? null
          : NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: backgroundColor,
                indicatorColor: indicatorColor,
                labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: selectedColor,
                      );
                    }
                    return TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: unselectedColor,
                    );
                  },
                ),
                iconTheme: MaterialStateProperty.resolveWith<IconThemeData>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return IconThemeData(color: selectedColor);
                    }
                    return IconThemeData(color: unselectedColor);
                  },
                ),
                height: 65,
                surfaceTintColor: Colors.transparent,
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.devices_outlined),
                    selectedIcon: Icon(Icons.devices),
                    label: 'Devices',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.handyman_outlined),
                    selectedIcon: Icon(Icons.handyman),
                    label: 'Tools',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.assistant_outlined),
                    selectedIcon: Icon(Icons.assistant),
                    label: 'Assistant',
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
