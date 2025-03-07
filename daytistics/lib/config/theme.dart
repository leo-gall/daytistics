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

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: ColorSettings.background,
    selectedItemColor: ColorSettings.primary,
    enableFeedback: false,
  ),

  // text theme
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: ColorSettings.textDark,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
    bodyMedium: TextStyle(
      color: ColorSettings.textDark,
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

  cardTheme: CardTheme(
    color: Colors.grey[200],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.grey[200],
    contentPadding: const EdgeInsets.only(
      left: 10,
      right: 60,
      top: 10,
      bottom: 10,
    ),
    hintStyle: const TextStyle(
      color: Colors.grey,
      fontSize: 16,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Colors.grey[300]!,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Colors.grey[300]!,
      ),
    ),
  ),
);
