import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/aod_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

Future<void> initializeApp() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Set preferred orientations to portrait only to save memory
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Optimize system UI for older devices
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    // Load environment variables with error handling
    await dotenv.load(fileName: ".env").catchError((error) {
      debugPrint('Error loading .env file: $error');
      // Provide fallback values if needed
    });

    // Optimize memory usage
    imageCache.maximumSize = 50; // Reduce image cache size
    imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50 MB limit
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
}

void main() async {
  ErrorWidget.builder = (FlutterErrorDetails details) => const CustomErrorWidget();
  
  await initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReSmart AOD',
      theme: ThemeData.dark().copyWith(
        // Optimize theme for performance
        platform: TargetPlatform.android,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
        visualDensity: VisualDensity.compact,
        // Use system fonts instead of downloading custom fonts
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Roboto',
        ),
      ),
      builder: (context, child) {
        // Add error boundary and performance optimizations
        return ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(
            physics: const ClampingScrollPhysics(),
            platform: TargetPlatform.android,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AODScreen(),
    );
  }
}