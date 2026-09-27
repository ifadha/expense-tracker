import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Plus Jakarta Sans',
      scaffoldBackgroundColor: AppConstants.backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryPurple,
        brightness: Brightness.light,
        primary: AppConstants.primaryPurple,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: AppConstants.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppConstants.textDark,
        ),
        iconTheme: IconThemeData(color: AppConstants.textDark),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Plus Jakarta Sans',
      scaffoldBackgroundColor: AppConstants.backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryPurple,
        brightness: Brightness.dark,
        primary: AppConstants.primaryPurple,
        onPrimary: Colors.white,
        surface: AppConstants.surfaceDark,
        onSurface: AppConstants.textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppConstants.textLight,
        ),
        iconTheme: IconThemeData(color: AppConstants.textLight),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        color: AppConstants.cardDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          backgroundColor: AppConstants.primaryPurple,
          foregroundColor: Colors.white,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppConstants.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }
}
