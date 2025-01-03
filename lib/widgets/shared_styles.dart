// shared_styles.dart
import 'package:flutter/material.dart';

class SharedStyles {
  static const double containerPadding = 8.0;  // Reduced from 12
  static const double borderRadius = 15.0;
  static const Color backgroundColor = Colors.black87;
  static const Color textColor = Colors.white;
  
  static double getResponsiveSize(BoxConstraints constraints) {
    return constraints.maxWidth * 0.14;  // Increased from 0.12 for better visibility
  }
}