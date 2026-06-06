import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isInitialized = false;
  static bool _speaking = false;

  static Future<void> init() async {
    if (!_isInitialized) {
      await _tts.setLanguage('te-IN'); // Telugu default
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isInitialized = true;
    }
  }

  static Future<void> speak(String text, {String language = 'te-IN'}) async {
    _speaking = true;
    await _tts.setLanguage(language);
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
    _speaking = false;
  }

  static Future<bool> isSpeaking() async {
    return _speaking;
  }

  static void setHandlers({
    required VoidCallback onStart,
    required VoidCallback onComplete,
    required VoidCallback onError,
  }) {
    _tts.setStartHandler(() {
      _speaking = true;
      onStart();
    });
    _tts.setCompletionHandler(() {
      _speaking = false;
      onComplete();
    });
    _tts.setCancelHandler(() {
      _speaking = false;
      onComplete();
    });
    _tts.setErrorHandler((_) {
      _speaking = false;
      onError();
    });
  }
}
