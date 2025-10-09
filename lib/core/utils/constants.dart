// lib/utils/constants.dart

import 'package:flutter/material.dart';

class AppStrings {
  static const String appName = 'Stoqle';
  static const String homeScreenTitle = 'Home Screen';
  static const String detailsScreenTitle = 'Details Screen';
  static const String welcomeMessage = 'Welcome to Details Screen!';
  static const String notFoundMessage = 'Page not found!';
}

class AppColors {
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.blueAccent;
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF000000);
}

class AppDimensions {
  static const double padding = 16.0;
  static const double margin = 16.0;
  static const double borderRadius = 8.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 24.0;
}

class AppAssets {
  static const String logo = 'assets/images/logo.png';
  static const String homeIcon = 'assets/icons/home.png';
  static const String profileIcon = 'assets/icons/profile.png';
}

class ApiConstants {
  static const String baseUrl = 'http://10.175.53.182:4000/api';
  static const String serverBaseUrl = 'http://10.175.53.182:4000';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String userProfileEndpoint = '/user/profile';
}

class Config {
  static const bool debug = true;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const int maxRetryAttempts = 3;
}
