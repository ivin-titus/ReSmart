import 'package:flutter/material.dart';
import 'time_widget.dart';
import 'date_widget.dart';
import 'weather_widget.dart';

class AODScreen extends StatelessWidget {
  const AODScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            TimeWidget(),
            SizedBox(height: 10),
            DateWidget(),
            SizedBox(height: 20),
            WeatherWidget(),
          ],
        ),
      ),
    );
  }
}
