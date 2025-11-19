import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

final ThemeData marineTheme = ThemeData(
  primaryColor: AppColors.deepBlue,
  colorScheme: ColorScheme.light(
    primary: AppColors.deepBlue,
    secondary: AppColors.seaGreen,
    surface: AppColors.foam,
    background: AppColors.foam,
  ),
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Inter',
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      color: AppColors.deepBlue,
      letterSpacing: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.deepBlue,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.darkText,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.greyText,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    color: Colors.white.withOpacity(0.9),
  ),
);