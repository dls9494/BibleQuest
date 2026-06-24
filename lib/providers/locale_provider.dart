import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/analytics_service.dart';
import '../services/bible_service.dart';

enum ContentLanguageMode { english, telugu, bilingual }

// Alias for backwards compatibility
typedef ContentMode = ContentLanguageMode;

class LocaleProvider with ChangeNotifier {
  final Locale locale = const Locale('en');

  ContentLanguageMode _contentMode = ContentLanguageMode.bilingual;
  ContentLanguageMode get contentMode => _contentMode;

  String _activeTeluguVersion = 'telugu_ov';
  String get activeTeluguVersion => _activeTeluguVersion;

  String _activeEnglishVersion = 'kjv';
  String get activeEnglishVersion => _activeEnglishVersion;

  LocaleProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final langModeStr = prefs.getString('bible_language') ?? 'bilingual';
      if (langModeStr == 'telugu') {
        _contentMode = ContentLanguageMode.bilingual;
        await prefs.setString('bible_language', 'bilingual');
      } else if (langModeStr == 'english') {
        _contentMode = ContentLanguageMode.english;
      } else {
        _contentMode = ContentLanguageMode.bilingual;
      }

      _activeTeluguVersion = BibleService.mapLegacyVersion(
        prefs.getString('bible_telugu_version') ?? 'telugu_ov',
      );
      _activeEnglishVersion = BibleService.mapLegacyVersion(
        prefs.getString('bible_english_version') ?? 'kjv',
      );

      notifyListeners();
    } catch (e) {
      // SharedPreferences might fail in test contexts; ignore gracefully
    }
  }

  Future<void> setContentMode(ContentLanguageMode mode) async {
    _contentMode = mode;
    notifyListeners();
    
    AnalyticsService.setUserProperties(
      preferredLanguage: mode.name,
      selectedTranslation: activeVersion,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final langStr = mode == ContentLanguageMode.telugu
          ? 'telugu'
          : (mode == ContentLanguageMode.english ? 'english' : 'bilingual');
      await prefs.setString('bible_language', langStr);
    } catch (_) {}
  }

  Future<void> setTeluguVersion(String version) async {
    _activeTeluguVersion = BibleService.mapLegacyVersion(version);
    notifyListeners();

    AnalyticsService.setUserProperties(
      selectedTranslation: _activeTeluguVersion,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bible_telugu_version', _activeTeluguVersion);
    } catch (_) {}
  }

  Future<void> setEnglishVersion(String version) async {
    _activeEnglishVersion = BibleService.mapLegacyVersion(version);
    notifyListeners();

    AnalyticsService.setUserProperties(
      selectedTranslation: _activeEnglishVersion,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bible_english_version', _activeEnglishVersion);
    } catch (_) {}
  }

  /// Sets the active version and automatically matches the appropriate language mode
  Future<void> setActiveVersion(String version) async {
    final mapped = BibleService.mapLegacyVersion(version);
    if (mapped.startsWith('telugu')) {
      _activeTeluguVersion = mapped;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('bible_telugu_version', mapped);
        if (_contentMode == ContentLanguageMode.english) {
          _contentMode = ContentLanguageMode.bilingual;
          await prefs.setString('bible_language', 'bilingual');
        }
      } catch (_) {}
    } else {
      _activeEnglishVersion = mapped;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('bible_english_version', mapped);
        if (_contentMode == ContentLanguageMode.telugu) {
          _contentMode = ContentLanguageMode.english;
          await prefs.setString('bible_language', 'english');
        }
      } catch (_) {}
    }
    notifyListeners();

    AnalyticsService.setUserProperties(
      preferredLanguage: _contentMode.name,
      selectedTranslation: mapped,
    );
  }

  /// Single source of truth for the active version.
  /// Defaults to Telugu version in bilingual mode.
  String get activeVersion {
    if (_contentMode == ContentLanguageMode.english) {
      return _activeEnglishVersion;
    } else {
      return _activeTeluguVersion;
    }
  }

  String getContentText(String en, String te) {
    switch (_contentMode) {
      case ContentLanguageMode.english:
        return en;
      case ContentLanguageMode.telugu:
        return te;
      case ContentLanguageMode.bilingual:
        if (te.isNotEmpty) return '$te\n($en)';
        return en;
    }
  }

  String get fontFamily {
    return _contentMode == ContentLanguageMode.telugu || _contentMode == ContentLanguageMode.bilingual
        ? 'NotoSansTelugu'
        : 'Roboto';
  }

  // Backwards compatibility getters for bilingual text widget
  String get englishFontFamily => 'Outfit';
  String get teluguFontFamily => 'NotoSansTelugu';
  double get englishLineHeight => 1.2;
  double get teluguLineHeight => 1.6;
}
