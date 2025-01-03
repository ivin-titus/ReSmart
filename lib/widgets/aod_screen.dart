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

  double _getTimeTextSize(double screenWidth, double screenHeight) {
    final smallerDimension = screenWidth < screenHeight ? screenWidth : screenHeight;
    
    // More granular time text sizing
    if (smallerDimension < 300) {
      return 48;  // For very small devices
    } else if (smallerDimension < 600) {
      return 72;
    } else if (smallerDimension < 1200) {
      return 96;
    } else if (smallerDimension < 2000) {
      return 120;
    } else {
      return smallerDimension * 0.06;  // Dynamic scaling for 4K
    }
  }

  double _getResponsivePadding(double dimension, {bool isWidth = true}) {
    if (dimension < 300) {
      return isWidth ? 0.08 : 0.05;
    } else if (dimension < 600) {
      return isWidth ? 0.12 : 0.07;
    } else if (dimension < 1200) {
      return isWidth ? 0.15 : 0.09;
    } else if (dimension < 2000) {
      return isWidth ? 0.18 : 0.11;
    } else {
      return isWidth ? 0.20 : 0.13;
    }
  }

  double _getResponsiveWidth(double screenWidth, bool isLandscape) {
    if (screenWidth < 300) {
      return isLandscape ? 0.50 : 0.90;
    } else if (screenWidth < 600) {
      return isLandscape ? 0.45 : 0.85;
    } else if (screenWidth < 1200) {
      return isLandscape ? 0.42 : 0.80;
    } else if (screenWidth < 2000) {
      return isLandscape ? 0.40 : 0.75;
    } else {
      return isLandscape ? 0.35 : 0.65;
    }
  }

  double _getSecondaryTextSize(double screenWidth, double screenHeight) {
    final smallerDimension = screenWidth < screenHeight ? screenWidth : screenHeight;
    
    if (smallerDimension < 300) {
      return 14;
    } else if (smallerDimension < 600) {
      return 18;
    } else if (smallerDimension < 1200) {
      return 22;
    } else if (smallerDimension < 2000) {
      return 26;
    } else {
      return smallerDimension * 0.015;
    }
  }

  Widget _buildMainContent(BuildContext context, BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final isLandscape = screenWidth > screenHeight;
    final smallerDimension = screenWidth < screenHeight ? screenWidth : screenHeight;

    final timeWidth = screenWidth * _getResponsiveWidth(screenWidth, isLandscape);
    final dateWeatherWidth = screenWidth * (_getResponsiveWidth(screenWidth, isLandscape) * 0.9);
    final timeTextSize = _getTimeTextSize(screenWidth, screenHeight);
    final secondaryTextSize = _getSecondaryTextSize(screenWidth, screenHeight);
    
    final verticalSpacing = smallerDimension * (isLandscape ? 0.02 : 0.015);
    final horizontalSpacing = smallerDimension * 0.02;

    Widget contentStack = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: verticalSpacing),
        SizedBox(
          width: timeWidth,
          child: TimeWidget(
            style: TextStyle(
              fontSize: timeTextSize,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: timeTextSize * 0.02, // Dynamic letter spacing
            ),
            amPmStyle: TextStyle(
              fontSize: timeTextSize * 0.3, // AM/PM text proportional to time
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: verticalSpacing * 0.5),
        SizedBox(
          width: dateWeatherWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: DateWidget(
                    textStyle: TextStyle(
                      fontSize: secondaryTextSize,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: horizontalSpacing),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: MiniWeatherWidget(
                    textStyle: TextStyle(
                      fontSize: secondaryTextSize,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    Widget layoutWrapper = isLandscape
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: contentStack,
              ),
              const Expanded(
                flex: 2,
                child: SizedBox(),
              ),
            ],
          )
        : Column(
            children: [
              Expanded(
                flex: 3,
                child: contentStack,
              ),
              const Expanded(
                flex: 2,
                child: SizedBox(),
              ),
            ],
          );

    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * _getResponsivePadding(screenWidth),
        top: screenHeight * _getResponsivePadding(screenHeight, isWidth: false),
      ),
      child: layoutWrapper,
    );
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