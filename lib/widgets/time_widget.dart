import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './services/settings_service.dart';

class TimeWidget extends ConsumerWidget {
  final TextStyle? style;
  final TextStyle? amPmStyle;

  const TimeWidget({
    Key? key,
    this.style,
    this.amPmStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFormat = ref.watch(timeFormatProvider);

    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final hour = now.hour;
        final minute = now.minute;

        if (timeFormat == '24') {
          return Text(
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
            style: style,
          );
        }

        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final amPm = hour >= 12 ? 'PM' : 'AM';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
              style: style,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: (style?.fontSize ?? 24) * 0.1,
                top: (style?.fontSize ?? 24) * 0.1,
              ),
              child: Text(
                amPm,
                style: amPmStyle ?? style?.copyWith(
                  fontSize: (style?.fontSize ?? 24) * 0.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}