import 'package:flutter/material.dart';
import 'time_widget.dart';
import 'date_widget.dart';
import 'weather_widget.dart';
import 'weather_widget_mini.dart';

// Convert to StatefulWidget
class AODScreen extends StatefulWidget {
  const AODScreen({Key? key}) : super(key: key);

  @override
  State<AODScreen> createState() => _AODScreenState();
}

// Separate state class with AutomaticKeepAliveClientMixin
class _AODScreenState extends State<AODScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false; // Don't keep in memory when not visible

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    // Get screen size once instead of multiple calculations
    final Size screenSize = MediaQuery.of(context).size;

    return RepaintBoundary(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            height: screenSize.height,
            width: screenSize.width,
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RepaintBoundary(
                        child: SizedBox(
                          width: constraints.maxWidth * 0.8,
                          child: const TimeWidget(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      RepaintBoundary(
                        child: SizedBox(
                          width: constraints.maxWidth * 0.8,
                          child: const DateWidget(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      RepaintBoundary(
                        child: SizedBox(
                          width: constraints.maxWidth * 0.8,
                          child: const MiniWeatherWidget(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}
