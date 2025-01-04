// time_widget.txt

import 'package:flutter/material.dart';

class TimeWidget extends StatelessWidget {
  final TextStyle? style;
  final TextStyle? amPmStyle;

  const TimeWidget({
    Key? key,
    this.style,
    this.amPmStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final hour = now.hour;
        final minute = now.minute;
        
        // Format hour for 12-hour clock
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final amPm = hour >= 12 ? 'PM' : 'AM';
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hours and minutes
            Text(
              '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
              style: style,
            ),
            // AM/PM indicator
            Padding(
              padding: EdgeInsets.only(
                left: (style?.fontSize ?? 24) * 0.1,
                top: (style?.fontSize ?? 24) * 0.1,
              ),
              child: Text(
                amPm,
                style: amPmStyle,
              ),
            ),
          ],
        );
      },
    );
  }
}