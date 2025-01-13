import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'navbar.dart';
import './widgets/location_dialog.dart';
import './widgets/services/settings_service.dart';
import './widgets/services/theme_provider.dart';

// Custom error widget for lower memory usage
class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text('An error occurred', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

Future<bool> checkAndRequestLocationPermission() async {
  final Location location = Location();
  bool serviceEnabled;
  PermissionStatus permissionGranted;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return false;
    }
  }

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
    WidgetsFlutterBinding.ensureInitialized();

    final settingsService = SettingsService();
    await settingsService.initialize();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.top, // Status/notification bar
        SystemUiOverlay.bottom, // Navigation bar
      ],
    );

    await dotenv.load(fileName: ".env").catchError((error) {
      debugPrint('Error loading .env file: $error');
    });

    final hasLocationPermission = await checkAndRequestLocationPermission();
    if (hasLocationPermission) {
      final Location location = Location();
      final currentLocation = await location.getLocation();
      await settingsService.setWeatherLocation(
          '${currentLocation.latitude},${currentLocation.longitude}', true);
    }

    imageCache.maximumSize = 50;
    imageCache.maximumSizeBytes = 50 * 1024 * 1024;
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReSmart',
      themeMode: themeState.themeMode,
      locale: const Locale('en'),
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      theme: ThemeData.light(useMaterial3: true).copyWith(
        platform: TargetPlatform.android,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
        visualDensity: VisualDensity.compact,
        textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'Roboto',
            ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        platform: TargetPlatform.android,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
        visualDensity: VisualDensity.compact,
        scaffoldBackgroundColor: themeState.isAmoled ? Colors.black : null,
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'Roboto',
            ),
        colorScheme: themeState.isAmoled
            ? ColorScheme.dark(
                background: Colors.black,
                surface: Colors.black,
                primary: Colors.white,
                secondary: Colors.white70,
              )
            : null,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: OrientationBuilder(
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
                      child: LocationPermissionWrapper(
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      home: const NavBar(),
    );
  }
}

class LocationPermissionWrapper extends StatefulWidget {
  final Widget child;

  const LocationPermissionWrapper({Key? key, required this.child})
      : super(key: key);

  @override
  _LocationPermissionWrapperState createState() =>
      _LocationPermissionWrapperState();
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
                    true);
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
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder =
      (FlutterErrorDetails details) => const CustomErrorWidget();
  await initializeApp();
  await SettingsService().initialize();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
