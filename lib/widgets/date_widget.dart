import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'shared_styles.dart';

class DateWidget extends StatefulWidget {
  final String? dateFormat;
  final TextStyle? textStyle;
 
  const DateWidget({
    Key? key,
    this.dateFormat,
    this.textStyle,
  }) : super(key: key);

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> with AutomaticKeepAliveClientMixin {
  late String _date;
  Timer? _timer;
  late DateFormat _dateFormat;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _dateFormat = DateFormat(widget.dateFormat ?? 'E, d MMM');
    _updateDate();
    _startDailyTimer();
  }

  void _updateDate() {
    if (mounted) {
      setState(() {
        _date = _dateFormat.format(DateTime.now());
      });
    }
  }

  void _startDailyTimer() {
    _timer?.cancel();
   
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = nextMidnight.difference(now);
    
    _timer = Timer(timeUntilMidnight, () {
      _updateDate();
      _startDailyTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
   
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: SharedStyles.containerDecoration,
            padding: EdgeInsets.all(SharedStyles.containerPadding),
            child: Text(
              _date,
              style: widget.textStyle?.copyWith(
                fontSize: SharedStyles.getResponsiveSize(constraints).clamp(20.0, 28.0),
                color: SharedStyles.textColor,
              ) ?? SharedStyles.getBaseTextStyle(constraints),
              textScaler: const TextScaler.linear(1.0),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        },
      ),
    );
  }
}