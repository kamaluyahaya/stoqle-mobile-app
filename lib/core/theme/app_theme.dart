import 'package:flutter/material.dart';

import '../../component/colors/color.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    scaffoldBackgroundColor: AppColors.kDarkMode,

    appBarTheme: AppBarTheme(
      color: AppColors.background2,
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: const TextTheme(
      // Display (very large)
      displayLarge: TextStyle(
        fontSize: 57,
        fontFamily: "Regular",
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontFamily: "Regular",
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontFamily: "Regular",
        color: Colors.white,
      ),

      // Headlines
      headlineLarge: TextStyle(
        fontSize: 32,
        fontFamily: "Regular",
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontFamily: "Regular",
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontFamily: "Regular",
        color: Colors.white,
      ),

      // Titles (app bars, card titles)
      titleLarge: TextStyle(
        fontSize: 20,
        fontFamily: "Regular",
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontFamily: "Regular",
        color: Colors.white,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontFamily: "Regular",
        color: Colors.white,
      ),

      // Body (your original values preserved for bodyLarge)
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontFamily: "Regular",
      ),
      // bumped these a bit to be more readable, but change if you prefer the tiny sizes
      bodyMedium: TextStyle(
        fontSize: 12,
        color: Colors.white70,
        fontFamily: "Regular",
      ),
      bodySmall: TextStyle(
        fontSize: 10,
        color: Colors.white70,
        fontFamily: "Regular",
      ),

      // Labels (buttons, captions)
      labelLarge: TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontFamily: "Regular",
      ),
      labelMedium: TextStyle(
        color: Colors.white70,
        fontSize: 12,
        fontFamily: "Regular",
      ),
      labelSmall: TextStyle(
        color: Colors.white70,
        fontSize: 10,
        fontFamily: "Regular",
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData.light().copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    iconTheme: const IconThemeData(color: Colors.black),
    appBarTheme: AppBarTheme(
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        color: AppColors.background2,
        fontSize: 20,
        fontFamily: 'Regular',
      ),
      backgroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      // Display (very large)
      displayLarge: TextStyle(
        fontSize: 57,
        fontFamily: "Regular",
        color: Colors.black,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontFamily: "Regular",
        color: Colors.black,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontFamily: "Regular",
        color: Colors.black,
      ),

      // Headlines
      headlineLarge: TextStyle(
        fontSize: 32,
        fontFamily: "Regular",
        color: Colors.black,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontFamily: "Regular",
        color: Colors.black,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontFamily: "Regular",
        color: Colors.black,
      ),

      // Titles (app bars, card titles)
      titleLarge: TextStyle(
        fontSize: 20,
        fontFamily: "Regular",
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontFamily: "Regular",
        color: Colors.black,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontFamily: "Regular",
        color: Colors.black,
      ),

      // Body (kept your bodyLarge = 16)
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontFamily: "Regular",
      ),
      bodyMedium: TextStyle(
        fontSize: 12,
        color: Colors.black87,
        fontFamily: "Regular",
      ),
      bodySmall: TextStyle(
        fontSize: 10,
        color: Colors.black54,
        fontFamily: "Regular",
      ),

      // Labels (buttons, captions)
      labelLarge: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontFamily: "Regular",
      ),
      labelMedium: TextStyle(
        color: Colors.black87,
        fontSize: 12,
        fontFamily: "Regular",
      ),
      labelSmall: TextStyle(
        color: Colors.black87,
        fontSize: 10,
        fontFamily: "Regular",
      ),
    ),
  );
}
