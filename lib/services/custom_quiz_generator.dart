import 'dart:math';
import '../models/quiz.dart';
import '../services/bible_service.dart';

class CustomQuizGenerator {
  // ─── Legacy single-book API (kept for backward compatibility) ──────────────
  /// Generates a list of Question objects dynamically from a range of Bible chapters.
  static Future<List<Question>> generateQuiz({
    required String bookId,
    required int fromChapter,
    required int toChapter,
    required int questionCount,
    required String version, // 'te' | 'kjv' | 'nhv'
    String difficulty = 'medium', // 'easy' | 'medium' | 'hard'
  }) async {
    return generateMultiBookQuiz(
      bookRanges: [{'bookId': bookId, 'from': fromChapter, 'to': toChapter}],
      questionCount: questionCount,
      version: version,
      difficulty: difficulty,
    );
  }

  // ─── New multi-book API ────────────────────────────────────────────────────
  /// Generates questions from one or more book/chapter ranges.
  /// [bookRanges] is a list of maps with keys: 'bookId', 'from', 'to'
  /// [difficulty] affects question types and time limits:
  ///   - easy:   mostly reference-ID questions, 25s per question
  ///   - medium: mix of fill-in-blank + complete-ending, 20s per question
  ///   - hard:   complete-ending + cross-book refs, 15s per question
  static Future<List<Question>> generateMultiBookQuiz({
    required List<Map<String, dynamic>> bookRanges,
    required int questionCount,
    required String version, // 'te' | 'kjv' | 'nhv'
    String difficulty = 'medium',
  }) async {
    final random = Random();

    // ── Load all verses from all ranges ──────────────────────────────────────
    final allVerses = <Map<String, String>>[];
    for (final range in bookRanges) {
      final bookId = range['bookId'] as String;
      final fromCh = range['from'] as int;
      final toCh = range['to'] as int;
      final rangeVerses = await BibleService.getVersesForRange(bookId, fromCh, toCh, version);
      allVerses.addAll(rangeVerses);
    }

    if (allVerses.isEmpty) return [];

    // ── Determine type distribution based on difficulty ───────────────────────
    // type 0: Guess Reference (easy)
    // type 1: Fill in the Blank (medium)
    // type 2: Complete the Ending (hard/medium)
    List<int> typeWeights;
    int timeLimitSeconds;
    int basePoints;
    switch (difficulty) {
      case 'easy':
        typeWeights = [0, 0, 1, 1, 2]; // 40% fill, 40% ref, 20% complete
        timeLimitSeconds = 25;
        basePoints = 800;
        break;
      case 'hard':
        typeWeights = [2, 2, 2, 1, 0]; // 60% complete, 30% fill, 10% ref
        timeLimitSeconds = 15;
        basePoints = 1200;
        break;
      default: // medium
        typeWeights = [0, 1, 1, 2, 2]; // even mix
        timeLimitSeconds = 20;
        basePoints = 1000;
    }

    final questions = <Question>[];
    final shuffledVerses = List<Map<String, String>>.from(allVerses)..shuffle(random);
    final targetCount = min(questionCount, shuffledVerses.length);

    int i = 0;
    int attempts = 0;
    final maxAttempts = targetCount * 5;

    while (questions.length < targetCount && attempts < maxAttempts) {
      attempts++;
      final idx = questions.length % shuffledVerses.length;
      final targetVerse = shuffledVerses[idx];
      final ref = targetVerse['ref'] ?? '';
      final text = (targetVerse['text'] ?? '').trim();
      if (text.isEmpty) continue;

      final words = text.split(RegExp(r'\s+'));

      // Pick question type based on difficulty weights
      int type = typeWeights[random.nextInt(typeWeights.length)];

      // Hard requires at least 8 words; fallback to fill-in-blank
      if (type == 2 && words.length < 8) type = 1;
      // Fill-in-blank requires at least 6 words; fallback to reference
      if (type == 1 && words.length < 6) type = 0;

      if (type == 0) {
        // ── 1. Guess Reference ───────────────────────────────────────────────
        final q = _buildGuessReferenceQuestion(
          i: i,
          ref: ref,
          text: text,
          allVerses: allVerses,
          version: version,
          random: random,
          timeLimitSeconds: timeLimitSeconds,
          points: basePoints,
        );
        if (q != null) {
          questions.add(q);
          i++;
        }
      } else if (type == 1) {
        // ── 2. Fill in the Blank ──────────────────────────────────────────────
        final q = _buildFillBlankQuestion(
          i: i,
          ref: ref,
          text: text,
          words: List.from(words),
          allVerses: allVerses,
          version: version,
          random: random,
          timeLimitSeconds: timeLimitSeconds,
          points: basePoints,
        );
        if (q != null) {
          questions.add(q);
          i++;
        }
      } else {
        // ── 3. Complete the Ending ────────────────────────────────────────────
        final q = _buildCompleteEndingQuestion(
          i: i,
          ref: ref,
          words: words,
          allVerses: allVerses,
          version: version,
          random: random,
          timeLimitSeconds: timeLimitSeconds,
          points: basePoints,
          difficulty: difficulty,
        );
        if (q != null) {
          questions.add(q);
          i++;
        }
      }
    }

    return questions;
  }

  // ─── Question builders ────────────────────────────────────────────────────

  static Question? _buildGuessReferenceQuestion({
    required int i,
    required String ref,
    required String text,
    required List<Map<String, String>> allVerses,
    required String version,
    required Random random,
    required int timeLimitSeconds,
    required int points,
  }) {
    final correctAnswer = ref;

    final incorrectRefs = allVerses
        .where((v) => v['ref'] != ref)
        .map((v) => v['ref'] ?? '')
        .where((r) => r.isNotEmpty)
        .toList()
      ..shuffle(random);

    final optionsText = <String>[correctAnswer];
    for (final r in incorrectRefs) {
      if (optionsText.length < 4 && !optionsText.contains(r)) {
        optionsText.add(r);
      }
    }

    // Pad with synthetic refs if needed
    while (optionsText.length < 4) {
      final dummy = 'Verse ${random.nextInt(100) + 1}:${random.nextInt(30) + 1}';
      if (!optionsText.contains(dummy)) optionsText.add(dummy);
    }
    optionsText.shuffle(random);

    final questionText = version == 'te'
        ? 'ఈ వచనం ఏది?\n\n"$text"'
        : 'Which verse is this?\n\n"$text"';

    return Question(
      id: 'custom_q_$i',
      order: i + 1,
      type: 'multiple_choice',
      timeLimitSeconds: timeLimitSeconds,
      points: points,
      questionEn: questionText,
      questionTe: questionText,
      options: _buildOptions(i, optionsText, correctAnswer),
    );
  }

  static Question? _buildFillBlankQuestion({
    required int i,
    required String ref,
    required String text,
    required List<String> words,
    required List<Map<String, String>> allVerses,
    required String version,
    required Random random,
    required int timeLimitSeconds,
    required int points,
  }) {
    // Find candidate words to blank out (length > 3, not common words)
    const commonWords = {
      'that', 'this', 'with', 'from', 'they', 'them', 'their', 'have',
      'will', 'shall', 'were', 'been', 'being', 'also', 'unto', 'into',
      'upon', 'when', 'then', 'thou', 'thee', 'thine',
    };

    final candidateIndices = <int>[];
    for (int w = 0; w < words.length; w++) {
      final word = words[w].replaceAll(RegExp(r'[^\w\s\u0C00-\u0C7F]'), '');
      if (word.length > 3 && !commonWords.contains(word.toLowerCase())) {
        candidateIndices.add(w);
      }
    }

    if (candidateIndices.isEmpty) return null;

    final blankWordIdx = candidateIndices[random.nextInt(candidateIndices.length)];
    final originalWord = words[blankWordIdx];
    final cleanCorrectWord = originalWord.replaceAll(RegExp(r'[.,;?!"()\-\–\—]'), '').trim();

    if (cleanCorrectWord.isEmpty) return null;

    words[blankWordIdx] = '________';
    final blankedText = words.join(' ');

    // Incorrect options from other verses
    final otherCleanWords = allVerses
        .expand((v) => (v['text'] ?? '').split(RegExp(r'\s+')))
        .map((w) => w.replaceAll(RegExp(r'[.,;?!"()\-\–\—]'), '').trim())
        .where((w) =>
            w.length > 3 &&
            w.toLowerCase() != cleanCorrectWord.toLowerCase() &&
            !commonWords.contains(w.toLowerCase()))
        .toList()
      ..shuffle(random);

    final optionsText = <String>[cleanCorrectWord];
    for (final w in otherCleanWords) {
      if (optionsText.length < 4 && w.isNotEmpty && !optionsText.contains(w)) {
        optionsText.add(w);
      }
    }
    while (optionsText.length < 4) {
      final fallback = version == 'te' ? 'దేవుడు${optionsText.length}' : 'Lord${optionsText.length}';
      optionsText.add(fallback);
    }
    optionsText.shuffle(random);

    final questionText = version == 'te'
        ? 'ఖాళీని పూరించండి ($ref):\n\n"$blankedText"'
        : 'Fill in the blank ($ref):\n\n"$blankedText"';

    return Question(
      id: 'custom_q_$i',
      order: i + 1,
      type: 'multiple_choice',
      timeLimitSeconds: timeLimitSeconds,
      points: points,
      questionEn: questionText,
      questionTe: questionText,
      options: _buildOptions(i, optionsText, cleanCorrectWord),
    );
  }

  static Question? _buildCompleteEndingQuestion({
    required int i,
    required String ref,
    required List<String> words,
    required List<Map<String, String>> allVerses,
    required String version,
    required Random random,
    required int timeLimitSeconds,
    required int points,
    required String difficulty,
  }) {
    // For hard difficulty, split at 60%; otherwise at 50%
    final splitFraction = difficulty == 'hard' ? 0.6 : 0.5;
    final splitPoint = (words.length * splitFraction).round();
    if (splitPoint >= words.length) return null;

    final firstHalf = words.sublist(0, splitPoint).join(' ');
    final secondHalf = words.sublist(splitPoint).join(' ').trim();

    if (secondHalf.isEmpty) return null;

    final otherEndings = allVerses
        .where((v) => (v['text'] ?? '').split(RegExp(r'\s+')).length >= 8)
        .map((v) {
          final w = (v['text'] ?? '').split(RegExp(r'\s+'));
          final sp = (w.length * splitFraction).round();
          if (sp >= w.length) return '';
          return w.sublist(sp).join(' ').trim();
        })
        .where((ending) =>
            ending.isNotEmpty && ending.toLowerCase() != secondHalf.toLowerCase())
        .toList()
      ..shuffle(random);

    final optionsText = <String>[secondHalf];
    for (final end in otherEndings) {
      if (optionsText.length < 4 && end.isNotEmpty && !optionsText.contains(end)) {
        optionsText.add(end);
      }
    }
    while (optionsText.length < 4) {
      final fallback = version == 'te' ? 'ఆమెన్. (${optionsText.length})' : 'Amen. (${optionsText.length})';
      optionsText.add(fallback);
    }
    optionsText.shuffle(random);

    final questionText = version == 'te'
        ? 'ఈ వచనాన్ని పూర్తి చేయండి ($ref):\n\n"$firstHalf..."'
        : 'Complete this verse ($ref):\n\n"$firstHalf..."';

    return Question(
      id: 'custom_q_$i',
      order: i + 1,
      type: 'multiple_choice',
      timeLimitSeconds: timeLimitSeconds,
      points: points,
      questionEn: questionText,
      questionTe: questionText,
      options: _buildOptions(i, optionsText, secondHalf),
    );
  }

  // ─── Helper ───────────────────────────────────────────────────────────────

  static List<Option> _buildOptions(int i, List<String> texts, String correctText) {
    return texts.asMap().entries.map((entry) {
      return Option(
        id: 'custom_opt_${i}_${entry.key}',
        order: entry.key,
        isCorrect: entry.value == correctText,
        textEn: entry.value,
        textTe: entry.value,
      );
    }).toList();
  }
}
