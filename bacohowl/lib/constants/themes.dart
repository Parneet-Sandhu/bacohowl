import 'package:flutter/material.dart';
import 'theme.dart';

class AppBackgroundTheme {
  final String name;
  final String backgroundImage;
  final List<Color> gradientColors;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final double gradientOpacity;

  const AppBackgroundTheme({
    required this.name,
    required this.backgroundImage,
    required this.gradientColors,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    this.gradientOpacity = 0.3,
  });
}

class AppThemes {
  static const defaultTheme = AppBackgroundTheme(
    name: 'Default',
    backgroundImage: 'assets/images/background.png',
    gradientColors: [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
    ],
    primaryColor: AppTheme.primaryColor,
    secondaryColor: AppTheme.secondaryColor,
    accentColor: AppTheme.accentColor,
  );

  static const List<AppBackgroundTheme> themes = [defaultTheme];

  static AppBackgroundTheme getThemeByName(String name) {
    return themes.firstWhere(
      (theme) => theme.name == name,
      orElse: () => defaultTheme,
    );
  }
}
