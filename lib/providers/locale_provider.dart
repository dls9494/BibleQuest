import 'package:flutter/material.dart';

enum ContentLanguageMode { english, telugu, bilingual }

// Alias for backwards compatibility
typedef ContentMode = ContentLanguageMode;

class LocaleProvider with ChangeNotifier {
  final Locale locale = const Locale('en');

  ContentLanguageMode _contentMode = ContentLanguageMode.bilingual;
  ContentLanguageMode get contentMode => _contentMode;

  void setContentMode(ContentLanguageMode mode) {
    _contentMode = mode;
    notifyListeners();
  }

  String getContentText(String en, String te) {
    switch (_contentMode) {
      case ContentLanguageMode.english:
        return en;
      case ContentLanguageMode.telugu:
        return te;
      case ContentLanguageMode.bilingual:
        if (te.isNotEmpty) return '$en\n($te)';
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
