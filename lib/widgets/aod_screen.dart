import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resmart/widgets/weather_widget_mini.dart';
import 'time_widget.dart';
import 'date_widget.dart';
import 'weather_widget.dart';

class AODScreen extends StatefulWidget {
  const AODScreen({Key? key}) : super(key: key);

  @override
  State<AODScreen> createState() => _AODScreenState();
}

class _AODScreenState extends State<AODScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  Widget _buildMainContent(BuildContext context, BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final isLandscape = screenWidth > screenHeight;

    // Calculate sizes based on screen dimensions
    final timeWidth = isLandscape ? screenWidth * 0.4 : screenWidth * 0.8;
    final dateWeatherWidth =
        isLandscape ? screenWidth * 0.30 : screenWidth * 0.7;

    Widget contentStack = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //isLandscape ? const SizedBox(height: 50) : const SizedBox(height: 1),

        // Time widget with larger font
        SizedBox(
          width: timeWidth,
          child: const TimeWidget(),
        ),
        // Date and Weather in a row
        SizedBox(
          width: dateWeatherWidth,
          child: Row(
            children: [
              Expanded(
                child: DateWidget(),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: MiniWeatherWidget(),
              ),
            ],
          ),
        ),
      ],
    );

    // Wrap content in appropriate layout based on orientation
    if (isLandscape) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.1, top: screenWidth * 0.05),
              child: contentStack,
            ),
          ),
          const Expanded(
            flex: 2,
            child: SizedBox(), // Reserved space for future updates
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.22,
                top: screenHeight * 0.10,
              ),
              child: contentStack,
            ),
          ),
          const Expanded(
            flex: 2,
            child: SizedBox(), // Reserved space for future updates
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) => SafeArea(
            child: _buildMainContent(context, constraints),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }
}
