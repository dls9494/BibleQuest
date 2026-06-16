import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  // Font settings
  double _fontSizeMultiplier = 1.0; // 1.0 = 100%, range 0.7 to 1.5
  bool _useSerifFonts = false;

  ThemeProvider() {
    _loadTheme();
    _loadFontSettings();
  }

  ThemeMode get themeMode => _themeMode;

  // Font settings getters
  double get fontSizeMultiplier => _fontSizeMultiplier;
  bool get useSerifFonts => _useSerifFonts;

  // Getters for actual font sizes with scaling applied
  double scaledFontSize(double baseSize) => baseSize * _fontSizeMultiplier;

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLight = prefs.getBool('theme_is_light') ?? false;
      _themeMode = isLight ? ThemeMode.light : ThemeMode.dark;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _loadFontSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _fontSizeMultiplier = (prefs.getDouble('font_size_multiplier') ?? 1.0).clamp(0.7, 1.5);
      _useSerifFonts = prefs.getBool('use_serif_fonts') ?? false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('theme_is_light', _themeMode == ThemeMode.light);
    } catch (_) {}
  }

  Future<void> setFontSizeMultiplier(double multiplier) async {
    _fontSizeMultiplier = multiplier.clamp(0.7, 1.5);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('font_size_multiplier', _fontSizeMultiplier);
    } catch (_) {}
  }

  Future<void> toggleSerifFonts() async {
    _useSerifFonts = !_useSerifFonts;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('use_serif_fonts', _useSerifFonts);
    } catch (_) {}
  }
}
