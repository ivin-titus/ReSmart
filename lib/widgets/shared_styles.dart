import 'package:flutter/material.dart';

class SharedStyles {
  // Colors
  static const Color backgroundColor = Colors.black87;
  static const Color textColor = Colors.white;
  static const Color errorColor = Colors.redAccent;

  // Dimensions
  static const double borderRadius = 15.0;
  static const double containerPadding = 12.0;
  static const double iconSpacing = 12.0;

  // Responsive sizing
  static double getResponsiveSize(BoxConstraints constraints) {
    return constraints.maxWidth * 0.12; // Unified size ratio for both widgets
  }

  // Text Styles
  static TextStyle getBaseTextStyle(BoxConstraints constraints) {
    return TextStyle(
      fontSize: getResponsiveSize(constraints).clamp(20.0, 28.0),
      color: textColor,
      fontWeight: FontWeight.bold,
    );
  }

  // Container Decoration
  static BoxDecoration get containerDecoration => BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      );

  // Loading Indicator Style
  static CircularProgressIndicator get loadingIndicator => const CircularProgressIndicator(
        color: textColor,
        strokeWidth: 3.0,
      );
}

