import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'shared_styles.dart';
import 'services/settings_service.dart';


// Convert settings format to DateFormat pattern
String getDateFormatPattern(String settingsFormat) {
  switch (settingsFormat) {
    case 'mon, 1 jan':
      return 'E, d MMM';
    case '1/1/2025':
      return 'd/M/y';
    case 'jan 1, 2025':
      return 'MMM d, y';
    case '1 jan 2025':
      return 'd MMM y';
    default:
      return 'E, d MMM';
  }
}

class DateWidget extends ConsumerStatefulWidget {
  final TextStyle? textStyle;
 
  const DateWidget({
    Key? key,
    this.textStyle,
  }) : super(key: key);

  @override
  ConsumerState<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends ConsumerState<DateWidget> with AutomaticKeepAliveClientMixin {
  String _date = '';  // Initialize empty
  Timer? _timer;
  bool _isProcessingTap = false;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _startDailyTimer();
        // Initial update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDate(ref.read(dateFormatProvider));
    });
  }

  void _updateDate(String format) {
    if (mounted) {
      final dateFormat = DateFormat(getDateFormatPattern(format));
      setState(() {
        _date = dateFormat.format(DateTime.now());
      });
    }
  }

  void _startDailyTimer() {
    _timer?.cancel();
   
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = nextMidnight.difference(now);
    
    _timer = Timer(timeUntilMidnight, () {
      final currentFormat = ref.read(dateFormatProvider);
      _updateDate(currentFormat);
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
        // Listen to date format changes and update immediately
    final settingsFormat = ref.watch(dateFormatProvider);
    
    // Update date whenever format changes
    if (_date.isEmpty || ref.read(dateFormatProvider) != settingsFormat) {
      _updateDate(settingsFormat);
    }
    
    // Update date whenever format changes
    if (_date.isEmpty || ref.read(dateFormatProvider) != settingsFormat) {
      _updateDate(settingsFormat);
    }

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