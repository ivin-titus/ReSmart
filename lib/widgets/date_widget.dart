import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWidget extends StatelessWidget {
  const DateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String date = DateFormat.yMMMMd().format(DateTime.now());
    return Text(
      date,
      style: const TextStyle(fontSize: 24),
    );
  }
}
