import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class DateWidget extends StatefulWidget {
  const DateWidget({Key? key}) : super(key: key);

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> with AutomaticKeepAliveClientMixin {
  late String _date;
  Timer? _timer;
  final DateFormat _dateFormat = DateFormat.yMMMMd();

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _updateDate(); // Initial update
    _startDailyTimer(); // Start timer for daily updates
  }

  void _updateDate() {
    if (mounted) {
      setState(() {
        _date = _dateFormat.format(DateTime.now());
      });
    }
  }

  void _startDailyTimer() {
    // Cancel any existing timer
    _timer?.cancel();
    
    // Calculate time until next midnight
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = nextMidnight.difference(now);

    // Set timer to update at midnight
    _timer = Timer(timeUntilMidnight, () {
      _updateDate();
      // Restart timer for next day
      _startDailyTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive font size calculation
          final fontSize = constraints.maxWidth * 0.06;
          
          return Text(
            _date,
            style: TextStyle(
              fontSize: fontSize.clamp(16.0, 24.0),
              // Use system default font
              fontFamily: null,
            ),
            textScaler: const TextScaler.linear(1.0),
            // Add text overflow handling
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}