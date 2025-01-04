import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../widgets/weather_widget_mini.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../widgets/time_widget.dart';
import '../widgets/date_widget.dart';
import '../widgets/shared_styles.dart';
import 'navbar.dart';

class AODScreen extends StatefulWidget {
  const AODScreen({Key? key}) : super(key: key);

  @override
  State<AODScreen> createState() => _AODScreenState();
}

class _AODScreenState extends State<AODScreen> with SingleTickerProviderStateMixin {
  bool _showCloseButton = false;
  bool _isHovered = false;
  DateTime? _lastTapTime;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 300) {
      setState(() {
        _showCloseButton = true;
      });
      _animationController.forward(from: 0.0);
      
      // Auto-hide close button after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showCloseButton = false;
          });
        }
      });
    }
    _lastTapTime = now;
  }

  Widget _buildCloseButton() {
    return AnimatedOpacity(
      opacity: _showCloseButton ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _showCloseButton
          ? Positioned(
              top: 20,
              right: 20,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isHovered = true),
                    onTapUp: (_) => setState(() => _isHovered = false),
                    onTapCancel: () => setState(() => _isHovered = false),
                    onTap: () {
                      _animationController.reverse().then((_) {
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const NavBar(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 200),
                          ),
                        );
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()..scale(_isHovered ? 1.1 : 1.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(200),
                          border: Border.all(
                            color: Colors.white.withOpacity(_isHovered ? 0.3 : 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 27, 27, 27).withOpacity(_isHovered ? 0.4 : 0.3),
                              blurRadius: _isHovered ? 16 : 12,
                              spreadRadius: _isHovered ? 3 : 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white.withOpacity(_isHovered ? 0.9 : 0.8),
                              size: _isHovered ? 30 : 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // Your existing helper methods remain unchanged
  double _getTimeTextSize(double screenWidth, double screenHeight) {
    final smallerDimension = screenWidth < screenHeight ? screenWidth : screenHeight;
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

  double _getResponsiveWidth(double screenWidth, bool isLandscape) {
    if (screenWidth < 300) return isLandscape ? 0.50 : 0.90;
    if (screenWidth < 600) return isLandscape ? 0.45 : 0.85;
    if (screenWidth < 1200) return isLandscape ? 0.42 : 0.80;
    if (screenWidth < 2000) return isLandscape ? 0.40 : 0.75;
    return isLandscape ? 0.35 : 0.65;
  }

  double _getSecondaryTextSize(double screenWidth, double screenHeight) {
    final smallerDimension = screenWidth < screenHeight ? screenWidth : screenHeight;
    if (smallerDimension < 300) return 14;
    if (smallerDimension < 600) return 18;
    if (smallerDimension < 1200) return 22;
    if (smallerDimension < 2000) return 26;
    return smallerDimension * 0.015;
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
              letterSpacing: timeTextSize * 0.02,
            ),
            amPmStyle: TextStyle(
              fontSize: timeTextSize * ((smallerDimension > 300 && isLandscape) ? 0.30 : 0.20),
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          width: dateWeatherWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: SharedStyles.containerDecoration,
                child: DateWidget(
                  textStyle: TextStyle(
                    fontSize: secondaryTextSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 0.1,
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
        )
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
      child: GestureDetector(
        onTapDown: (_) => _handleTap(),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) => SafeArea(
                  child: _buildMainContent(context, constraints),
                ),
              ),
              _buildCloseButton(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }
}