import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/weather_widget_mini.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../widgets/time_widget.dart';
import '../widgets/date_widget.dart';
import '../widgets/shared_styles.dart';
import '../widgets/quotes_widget.dart';
import 'navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/services/settings_service.dart';

class AODScreen extends ConsumerStatefulWidget {
  const AODScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AODScreen> createState() => _AODScreenState();
}

class _AODScreenState extends ConsumerState<AODScreen> {
  bool _showCloseButton = false;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _checkAODStatus();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _checkAODStatus() {
    if (ref.read(aodEnabledProvider)) {
      WakelockPlus.enable();
    }
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit AOD Mode'),
        content: const Text('Do you want to exit AOD mode?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (shouldPop ?? false) {
      _exitAODScreen();
    }
    return false; // Always return false as we handle the navigation ourselves
  }

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 300) {
      setState(() => _showCloseButton = true);
      Future.delayed(const Duration(seconds: 3),
          () => mounted ? setState(() => _showCloseButton = false) : null);
    }
    _lastTapTime = now;
  }

  Widget _buildCloseButton() {
    return Visibility(
      visible: _showCloseButton,
      child: Positioned(
        top: 15,
        right: 15,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: _exitAODScreen,
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  void _exitAODScreen() {
    _disableAODFeatures();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const NavBar(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  Future<void> _disableAODFeatures() async {
    await WakelockPlus.disable();
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  double _getTimeTextSize(double smallerDimension) {
    if (smallerDimension < 300) return 48;
    if (smallerDimension < 600) return 90;
    if (smallerDimension < 1200) return 96;
    if (smallerDimension < 2000) return 120;
    return smallerDimension * 0.06;
  }

  double _getResponsivePadding(double dimension, {bool isWidth = true}) {
    if (dimension < 300) return isWidth ? 0.08 : 0.05;
    if (dimension < 600) return isWidth ? 0.12 : 0.07;
    if (dimension < 1200) return isWidth ? 0.15 : 0.09;
    if (dimension < 2000) return isWidth ? 0.18 : 0.11;
    return isWidth ? 0.20 : 0.13;
  }

  Widget _buildMainContent(BuildContext context, BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final isLandscape = screenWidth > screenHeight;
    final smallerDimension =
        screenWidth < screenHeight ? screenWidth : screenHeight;
    final timeTextSize = _getTimeTextSize(smallerDimension);
    final secondaryTextSize = timeTextSize * 0.23;
    final horizontalPadding =
        screenWidth * (isLandscape ? 0.08 : _getResponsivePadding(screenWidth));
    final verticalPadding =
        screenHeight * _getResponsivePadding(screenHeight, isWidth: false);
    final contentSpacing = smallerDimension * 0.05;

    final leftContent = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isLandscape ? verticalPadding : verticalPadding / 2,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TimeWidget(
            style: TextStyle(
              fontSize: timeTextSize,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: timeTextSize * 0.02,
            ),
            amPmStyle: TextStyle(
              fontSize: timeTextSize *
                  ((smallerDimension > 300 && isLandscape) ? 0.30 : 0.20),
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: contentSpacing * 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: SharedStyles.containerDecoration,
                child: DateWidget(
                  textStyle: TextStyle(
                    fontSize: secondaryTextSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ),
              MiniWeatherWidget(
                textStyle: TextStyle(
                  fontSize: secondaryTextSize,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ],
          ),
          SizedBox(height: contentSpacing * 0.5),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400,
              minWidth: 200,
            ),
            child: QuoteWidget(
                textStyle: Theme.of(context).textTheme.bodyLarge,
                ),
          ),
        ],
      ),
    );

    final rightContent = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isLandscape ? verticalPadding : verticalPadding / 2,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [],
      ),
    );

    // For landscape mode, use equal flex values
    return isLandscape
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: leftContent),
              SizedBox(width: contentSpacing),
              Expanded(flex: 1, child: rightContent),
            ],
          )
        : Column(
            children: [
              Expanded(flex: 1, child: leftContent),
              SizedBox(height: contentSpacing),
              Expanded(flex: 1, child: rightContent),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: RepaintBoundary(
        child: GestureDetector(
          onTapDown: (_) => _handleTap(),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) =>
                      SafeArea(child: _buildMainContent(context, constraints)),
                ),
                _buildCloseButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _disableAODFeatures();
    super.dispose();
  }
}
