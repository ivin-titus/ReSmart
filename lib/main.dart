import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';
import 'navbar.dart';
import './widgets/location_dialog.dart';
import './widgets/services/settings_service.dart';

// Custom error widget for lower memory usage
class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text('An error occurred',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

Future<bool> checkAndRequestLocationPermission() async {
  final Location location = Location();
  bool serviceEnabled;
  PermissionStatus permissionGranted;

  // Check if location services are enabled
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return false;
    }
  }

  // Check location permission
  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return false;
    }
  }

  return true;
}

Future<void> initializeApp() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize settings service
    final settingsService = SettingsService();
    await settingsService.initialize();

    // Enable all orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Set fullscreen mode - hide status bar and navigation buttons
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [], // Empty array means hide all system UI overlays
    );

    // Load environment variables with error handling
    await dotenv.load(fileName: ".env").catchError((error) {
      debugPrint('Error loading .env file: $error');
      // Provide fallback values if needed
    });

    // Check location permissions
    final hasLocationPermission = await checkAndRequestLocationPermission();
    if (hasLocationPermission) {
      // Get current location and save it
      final Location location = Location();
      final currentLocation = await location.getLocation();
      await settingsService.setWeatherLocation(
        '${currentLocation.latitude},${currentLocation.longitude}',
        true
      );
    }

    // Optimize memory usage
    imageCache.maximumSize = 50;
    imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50 MB limit
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReSmart AOD',
      theme: ThemeData.dark().copyWith(
        platform: TargetPlatform.android,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
        visualDensity: VisualDensity.compact,
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Roboto',
        ),
      ),
      builder: (context, child) {
        return OrientationBuilder(
          builder: (context, orientation) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    padding: EdgeInsets.zero,
                    viewPadding: EdgeInsets.zero,
                    viewInsets: EdgeInsets.zero,
                  ),
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(
                      physics: const ClampingScrollPhysics(),
                      platform: TargetPlatform.android,
                    ),
                    child: LocationPermissionWrapper(child: child ?? const SizedBox.shrink()),
                  ),
                );
              },
            );
          },
        );
      },
      home: const NavBar(),
    );
  }
}

class LocationPermissionWrapper extends StatefulWidget {
  final Widget child;

  const LocationPermissionWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _LocationPermissionWrapperState createState() => _LocationPermissionWrapperState();
}

class _LocationPermissionWrapperState extends State<LocationPermissionWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationAndShowDialog();
    });
  }

  Future<void> _checkLocationAndShowDialog() async {
    final settingsService = SettingsService();
    final hasLocation = settingsService.getWeatherLocation() != null;
    
    if (!hasLocation) {
      final hasPermission = await checkAndRequestLocationPermission();
      if (!hasPermission && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => LocationDialog(
            onLocationSubmitted: (location) async {
              await settingsService.setWeatherLocation(location, false);
            },
            onAutoLocationRequested: () async {
              final hasPermission = await checkAndRequestLocationPermission();
              if (hasPermission) {
                final location = Location();
                final currentLocation = await location.getLocation();
                await settingsService.setWeatherLocation(
                  '${currentLocation.latitude},${currentLocation.longitude}',
                  true
                );
              }
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

void main() async {
  ErrorWidget.builder = (FlutterErrorDetails details) => const CustomErrorWidget();
  
  await initializeApp();
  
  runApp(const MyApp());
}