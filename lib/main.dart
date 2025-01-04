// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'navbar.dart';

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

    // Optimize memory usage
    imageCache.maximumSize = 50;
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
                    child: child ?? const SizedBox.shrink(),
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