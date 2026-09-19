import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color brand = Color(0xFF2D2650);
  static const Color brandSoft = Color(0xFFF1EFF8);
  static const Color line = Color(0xFFDAD7E6);
  static const Color danger = Color(0xFFB3261E);
  static const Color success = Color(0xFF1B7F4C);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: brand)
        .copyWith(primary: brand, onPrimary: Colors.white);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Tajawal',
      scaffoldBackgroundColor: Colors.white,
    );
  }

  static InputDecoration input(
    String label, {
    IconData? icon,
    Widget? suffix,
    String? hint,
    String? errorText,
    bool filled = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      prefixIcon: icon == null ? null : Icon(icon),
      suffixIcon: suffix,
      filled: filled,
      fillColor: filled ? brandSoft : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    );
  }
}
