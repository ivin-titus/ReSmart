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
  bool _isProcessingTap = false;

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

  Future<void> _showDateDialog() async {
    if (_isProcessingTap) return;
    
    setState(() {
      _isProcessingTap = true;
    });

    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Date Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Date: ${DateFormat('EEEE, MMMM d, y').format(DateTime.now())}'),
                const SizedBox(height: 8),
                Text('Day of Year: ${DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays + 1}'),
                const SizedBox(height: 8),
                Text('Week of Year: ${(DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays / 7).ceil()}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingTap = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(
      color: Colors.transparent,
      child: AbsorbPointer(
        absorbing: _isProcessingTap,
        child: InkWell(
          onTap: _showDateDialog,
          borderRadius: BorderRadius.circular(100),
          splashColor: const Color.fromARGB(255, 210, 210, 210),
          highlightColor: const Color.fromARGB(255, 219, 219, 219),
          child: RepaintBoundary(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textStyle = widget.textStyle?.copyWith(
                  fontSize: SharedStyles.getResponsiveSize(constraints).clamp(20.0, 28.0),
                  color: SharedStyles.textColor,
                ) ?? SharedStyles.getBaseTextStyle(constraints);
                
                return Container(
                  decoration: SharedStyles.containerDecoration,
                  padding: EdgeInsets.all(SharedStyles.containerPadding),
                  child: Text(
                    _date,
                    style: textStyle,
                    textScaler: const TextScaler.linear(1.0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}