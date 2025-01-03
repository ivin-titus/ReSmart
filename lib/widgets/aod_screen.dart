import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resmart/widgets/weather_widget_mini.dart';
import 'time_widget.dart';
import 'date_widget.dart';

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

  double _getResponsivePadding(double dimension, {bool isWidth = true}) {
    if (dimension < 600) {
      return isWidth ? 0.15 : 0.08;
    } else if (dimension < 1200) {
      return isWidth ? 0.18 : 0.10;
    } else if (dimension < 2000) {
      return isWidth ? 0.20 : 0.12;
    } else {
      return isWidth ? 0.22 : 0.15;
    }
  }

  double _getResponsiveWidth(double screenWidth, bool isLandscape) {
    if (screenWidth < 600) {
      return isLandscape ? 0.45 : 0.85;
    } else if (screenWidth < 1200) {
      return isLandscape ? 0.42 : 0.80;
    } else if (screenWidth < 2000) {
      return isLandscape ? 0.40 : 0.75;
    } else {
      return isLandscape ? 0.38 : 0.70;
    }
  }

  double _getResponsiveFontSize(double screenWidth) {
    if (screenWidth < 600) {
      return 18;
    } else if (screenWidth < 1200) {
      return 22;
    } else if (screenWidth < 2000) {
      return 24;
    } else {
      return 28;
    }
  }

  Widget _buildMainContent(BuildContext context, BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final isLandscape = screenWidth > screenHeight;

    // Get responsive measurements
    final timeWidth = screenWidth * _getResponsiveWidth(screenWidth, isLandscape);
    final dateWeatherWidth = screenWidth * (_getResponsiveWidth(screenWidth, isLandscape) * 0.9);
    final fontSize = _getResponsiveFontSize(screenWidth);
    
    // Calculate responsive spacing
    final verticalSpacing = screenHeight * (isLandscape ? 0.02 : 0.015);

    Widget contentStack = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: verticalSpacing),
        SizedBox(
          width: timeWidth,
          child: const TimeWidget(),
        ),
        SizedBox(height: verticalSpacing * 0.5),
        SizedBox(
          width: dateWeatherWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: (dateWeatherWidth - 16) / 2, // Subtract padding and divide remaining space
                child: DateWidget(
                  textStyle: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              //const SizedBox(width: 16), // Fixed spacing between widgets
              SizedBox(
                width: (dateWeatherWidth - 16) / 2,
                child: MiniWeatherWidget(
                  textStyle: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (isLandscape) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(
                left: screenWidth * _getResponsivePadding(screenWidth),
                top: screenHeight * _getResponsivePadding(screenHeight, isWidth: false),
              ),
              child: contentStack,
            ),
          ),
          const Expanded(
            flex: 2,
            child: SizedBox(),
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
                left: screenWidth * _getResponsivePadding(screenWidth),
                top: screenHeight * _getResponsivePadding(screenHeight, isWidth: false),
              ),
              child: contentStack,
            ),
          ),
          const Expanded(
            flex: 2,
            child: SizedBox(),
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