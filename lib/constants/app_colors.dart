import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF667eea);
  static const Color secondary = Color(0xFF764ba2);

  static const Color darkBackground = Color(0xFF0F0F23);
  static const Color darkSecondary = Color(0xFF1a1a2e);

  static Color textPrimary = Colors.black;
  static Color textSecondary = Colors.black.withValues(alpha: 0.6);
  static Color textLight = Colors.white;
  static Color textLightSecondary = Colors.white.withValues(alpha: 0.7);

  static Color inputBackground = Colors.grey.withValues(alpha: 0.1);
  static Color inputBorder = Colors.grey.withValues(alpha: 0.3);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static LinearGradient get darkGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      darkBackground,
      darkSecondary,
      const Color(0xFF16213e),
      darkBackground,
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
  );
}
