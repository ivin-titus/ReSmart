import 'package:flutter/material.dart';

class AITab extends StatelessWidget {
  const AITab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI Assistant'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Implement AI Assistant Screen content here'),
        ),
      ),
    );
  }
}