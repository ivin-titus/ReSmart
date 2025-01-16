import 'package:flutter/material.dart';

class AITab extends StatelessWidget {
  const AITab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'AI Assistant',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
          toolbarHeight: 100, // Increases AppBar height
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: Text('AI Assistant Screen '),
        ),
      ),
    );
  }
}