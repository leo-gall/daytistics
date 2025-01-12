import 'package:daytistics/config/settings.dart';
import 'package:flutter/material.dart';

ThemeData daytisticsTheme = ThemeData(
  // seed color theme
  colorScheme: ColorScheme.fromSeed(
    seedColor: ColorSettings.primary,
  ),

  // scaffold color
  scaffoldBackgroundColor: ColorSettings.background,

  // app bar theme colors
  appBarTheme: const AppBarTheme(
    backgroundColor: ColorSettings.primary,
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
  ),

  // text theme
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: ColorSettings.text,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
    bodyMedium: TextStyle(
      color: ColorSettings.text,
      fontSize: 16,
      letterSpacing: 1,
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(ColorSettings.primary),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ),
);
