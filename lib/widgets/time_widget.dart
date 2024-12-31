import 'package:flutter/material.dart';
import 'dart:async';

class TimeWidget extends StatefulWidget {
  const TimeWidget({Key? key}) : super(key: key);

  @override
  _TimeWidgetState createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  String _time = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _time = TimeOfDay.now().format(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _time,
      style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
    );
  }
}
