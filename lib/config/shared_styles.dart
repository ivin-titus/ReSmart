// sharedstyles.dart
import 'package:flutter/material.dart';

class SharedStyles {
  // Existing styles
  static const Color backgroundColor = Color.fromARGB(0, 0, 0, 0);
  static const Color textColor = Colors.white;
  static const Color errorColor = Colors.redAccent;
  static const double borderRadius = 15.0;
  static const double containerPadding = 12.0;
  static const double iconSpacing = 12.0;
  static const double contentSpacingRatio = 0.05;
  static const double minContentSpacing = 8.0;
  static const double maxContentSpacing = 32.0;
  static const double minWidgetSpacing = 8.0;
  static const double widgetPadding = 12.0;
  static const double minTextSize = 14.0;
  static const double maxTextSize = 28.0;

  static double getResponsiveSize(BoxConstraints constraints) {
    return constraints.maxWidth * 0.12;
  }

  static double getContentSpacing(double dimension) {
    return (dimension * contentSpacingRatio)
        .clamp(minContentSpacing, maxContentSpacing);
  }

  static double getResponsiveWidgetSpacing(double dimension) {
    return (dimension * 0.015).clamp(minWidgetSpacing, iconSpacing);
  }

  static TextStyle getBaseTextStyle(BoxConstraints constraints) {
    return TextStyle(
      fontSize: getResponsiveSize(constraints).clamp(20.0, 28.0),
      color: textColor,
      fontWeight: FontWeight.bold,
    );
  }

  static BoxDecoration get containerDecoration => BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      );

  static CircularProgressIndicator get loadingIndicator =>
      const CircularProgressIndicator(
        color: textColor,
        strokeWidth: 3.0,
      );
}
