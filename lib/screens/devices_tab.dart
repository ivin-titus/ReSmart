import 'package:flutter/material.dart';

class DevicesTab extends StatelessWidget {
  const DevicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Devices',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
          toolbarHeight: 100, // Increases AppBar height
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Text(''),
          ],
        ),
      ),
    );
  }
}
