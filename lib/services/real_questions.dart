import 'dart:convert';
import 'package:flutter/services.dart';

class RealQuestionsService {
  static final Map<String, List<Map<String, dynamic>>> _cachedQuestions = {};

  /// Loads and caches all the questions from the assets/real_questions.json file
  static Future<void> initializeRealQuestions() async {
    try {
      final jsonString = await rootBundle.loadString('assets/real_questions.json');
      final Map<String, dynamic> rawMap = jsonDecode(jsonString);
      
      _cachedQuestions.clear();
      if (rawMap.containsKey('levels')) {
        final Map<String, dynamic> levelsMap = rawMap['levels'];
        levelsMap.forEach((levelKey, levelVal) {
          if (levelVal is Map<String, dynamic>) {
            levelVal.forEach((setKey, setVal) {
              if (setVal is List) {
                final key = "${levelKey}_$setKey";
                _cachedQuestions[key] = setVal.map((q) => Map<String, dynamic>.from(q)).toList();
              }
            });
          }
        });
      } else {
        rawMap.forEach((key, value) {
          if (value is List) {
            _cachedQuestions[key] = value.map((q) => Map<String, dynamic>.from(q)).toList();
          }
        });
      }
      // ignore: avoid_print
      print("RealQuestionsService initialized. Loaded ${_cachedQuestions.length} sets of questions.");
    } catch (e) {
      // ignore: avoid_print
      print("Error initializing RealQuestionsService: $e");
    }
  }

  /// Returns the 12 questions for a specific level and set ID ('A', 'B', or 'C')
  static List<Map<String, dynamic>> getQuestionsForLevel(int level, String setId) {
    final key = "${level}_$setId";
    return _cachedQuestions[key] ?? [];
  }
}
