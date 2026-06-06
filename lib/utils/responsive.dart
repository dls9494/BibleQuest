import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static int gridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }

  static double fontSize(BuildContext context, double base) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return base * 0.8;
    if (width < 600) return base * 0.9;
    return base;
  }

  static EdgeInsets screenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return const EdgeInsets.all(16);
    if (width < 1200) return const EdgeInsets.all(24);
    return const EdgeInsets.all(32);
  }

  static double buttonHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 56;
    if (width < 600) return 64;
    return 72;
  }
}
