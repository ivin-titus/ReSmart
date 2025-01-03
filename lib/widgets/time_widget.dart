import 'package:flutter/material.dart';
import 'dart:async';

class TimeWidget extends StatefulWidget {
  const TimeWidget({Key? key}) : super(key: key);

  @override
  _TimeWidgetState createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> with AutomaticKeepAliveClientMixin {
  String _time = '';
  Timer? _timer;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _updateTimeNow(); // Update immediately
    _startTimer(); // Start periodic updates
  }

  // Separate method for immediate time update
  void _updateTimeNow() {
    if (mounted) {
      setState(() {
        _time = _formatTime(TimeOfDay.now());
      });
    }
  }

  // Start timer with error handling
  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        _updateTimeNow();
      },
    );
  }

  // Format time without context dependency
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Adjust font size based on available width
          final fontSize = constraints.maxWidth * 0.25;
          
          return Text(
            _time,
            style: TextStyle(
              fontSize: fontSize.clamp(20.0, 60.0),
              fontWeight: FontWeight.bold,
              // Use system default font for better performance
              fontFamily: null,
            ),
            // Add text scaling factor limit for consistency
            textScaler: const TextScaler.linear(1.0),
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTimeNow(); // Update time when dependencies change
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}