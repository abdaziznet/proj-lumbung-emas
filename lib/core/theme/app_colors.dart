import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (Gold/Emas)
  static const Color primary = Color(0xFFD4AF37); // Metallic Gold
  static const Color primaryLight = Color(0xFFFFD700); // Gold
  static const Color primaryDark = Color(0xFFB8860B); // Dark Goldenrod
  
  // Secondary Colors (Deep Professional Blue)
  static const Color secondary = Color(0xFF1A237E); // Indigo 900
  static const Color secondaryLight = Color(0xFF534BAE);
  static const Color secondaryDark = Color(0xFF000051);

  // Status Colors
  static const Color success = Color(0xFF2E7D32); // Green 800
  static const Color error = Color(0xFFC62828); // Red 800
  static const Color warning = Color(0xFFF9A825); // Yellow 800
  static const Color info = Color(0xFF1565C0); // Blue 800

  // Neutral Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textBody = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFEEEEEE);

  // Gradient
  static const LinearGradient goldGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
