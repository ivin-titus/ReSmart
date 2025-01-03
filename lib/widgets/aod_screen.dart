import 'package:flutter/material.dart';
import 'time_widget.dart';
import 'date_widget.dart';
import 'weather_widget_mini.dart';

class AODScreen extends StatefulWidget {
  const AODScreen({Key? key}) : super(key: key);

  @override
  State<AODScreen> createState() => _AODScreenState();
}

class _AODScreenState extends State<AODScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                  final containerWidth = constraints.maxWidth * 0.8;
                  
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RepaintBoundary(
                        child: SizedBox(
                          width: containerWidth,
                          child: const TimeWidget(),
                        ),
                      ),
                      //const SizedBox(height: 8),
                      RepaintBoundary(
                        child: SizedBox(
                          width: containerWidth,
                          child: Row(
                            children: [
                              Expanded(child: DateWidget()),
                              //const SizedBox(width: 2),
                              Expanded(child: MiniWeatherWidget()),
                            ],
                          ),
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
    super.dispose();
  }
}