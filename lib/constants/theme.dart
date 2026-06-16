import 'package:flutter/material.dart';

/// Centralized theme constants for Bible Quest Premium UX
class AppTheme {
  // Gold color - premium accent
  static const Color gold = Color(0xFFFFD700);

  // Animation constants
  static const Duration kAnimFast = Duration(milliseconds: 160);
  static const Duration kAnimMid = Duration(milliseconds: 200);
  static const Curve kAnimCurve = Curves.easeOutCubic;

  // Reader bottom toolbar constants
  static const double toolbarHeight = 80.0;
  static const double toolbarCornerRadius = 22.0;
  static const double toolbarBlurSigmaX = 10.0;
  static const double toolbarBlurSigmaY = 10.0;
  static const double toolbarBackgroundOpacity = 0.55;
  static const double toolbarBorderWidth = 0.5;
  static const double toolbarBorderOpacity = 0.12;
  static const double toolbarVerticalPadding = 10.0;
  static const double toolbarRowGap = 6.0;

  // Chapter/verse picker constants
  static const int pickerGridColumns = 6;
  static const double pickerUnselectedFontSize = 16.0;
  static const double pickerSelectedPillHorizontalPadding = 14.0;
  static const double pickerSelectedPillVerticalPadding = 8.0;
  static const double pickerSelectedGlowBlurRadius = 8.0;
  static const double pickerSelectedGlowOpacity = 0.4;
  static const Duration pickerAnimationDuration = Duration(milliseconds: 160);
  static const Curve pickerAnimationCurve = Curves.easeOutCubic;
  static const double pickerTransitionOffsetBegin = 0.08;
  static const double pickerTransitionOffsetEnd = 0.0;

  // Continue Reading card constants
  static const double continueReadingCardBorderRadius = 18.0;
  static const double continueReadingCardBorderWidth = 0.5;
  static const double continueReadingCardBorderOpacity = 0.10;
  static const double continueReadingCardHorizontalPadding = 20.0;
  static const double continueReadingCardVerticalPadding = 18.0;
  static const double continueReadingLabelFontSize = 12.0;
  static const double continueReadingLabelLetterSpacing = 0.4;
  static const double continueReadingVerseFontSize = 22.0;
  static const FontWeight continueReadingVerseFontWeight = FontWeight.w500;
  static const double continueReadingTimestampFontSize = 13.0;
  static const double continueReadingResumeFontSize = 14.0;
  static const Duration continueReadingTapAnimationDuration = Duration(milliseconds: 160);
  static const double continueReadingTapScale = 0.98;

  // Verse highlight constants
  static const double verseHighlightGoldOverlayOpacity = 0.13;

  // OT/NT tabs constants
  static const double otntTabActiveBgOpacity = 0.12; // 12% opacity
  static const double otntTabInactiveTextOpacity = 0.5;
  static const double otntTabBorderRadius = 99.0; // full pill
  static const Duration otntTabAnimationDuration = Duration(milliseconds: 180);
  static const Curve otntTabAnimationCurve = Curves.easeOutCubic;
}