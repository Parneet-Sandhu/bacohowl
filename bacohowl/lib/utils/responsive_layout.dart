import 'package:flutter/material.dart';

class ResponsiveLayout {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isWidget(BuildContext context) =>
      MediaQuery.of(context).size.width < 400;

  static double getPlayerWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (isWidget(context)) return width - 30; // Decreased width
    if (isMobile(context)) return width - 60; // Decreased width
    return 350; // Decreased max width from 400 to 350
  }

  static EdgeInsets getPlayerPadding(BuildContext context) {
    if (isWidget(context)) {
      return const EdgeInsets.all(12);
    }
    return const EdgeInsets.all(24);
  }

  static double getPlayerRadius(BuildContext context) {
    if (isWidget(context)) return 20;
    return 30;
  }

  static double getFontSize(BuildContext context, double defaultSize) {
    if (isWidget(context)) return defaultSize * 0.8;
    return defaultSize;
  }
}
