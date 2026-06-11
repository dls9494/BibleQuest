import '../services/category_mapping.dart';

class Quiz {
  final String id;
  final String creatorId;
  final String titleKey;
  final String bibleVersion;
  final List<String> topics;
  final bool isPublic;
  final int questionCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String titleEn;
  final String titleTe;
  final String descriptionEn;
  final String descriptionTe;
  final int level; // 1-50
  final String difficulty; // 'easy', 'medium', 'hard'
  final String setId; // 'A', 'B', or 'C'

  String get category {
    if (topics.isEmpty) {
      if (level >= 1 && level <= 100) {
        return CategoryMapping.getCategoryFromLevel(level);
      }
      return 'Old Testament';
    }
    
    final firstTopic = topics.first;
    final cat = CategoryMapping.getCategoryFromTopic(firstTopic);
    if (cat != null) return cat;

    for (final topic in topics) {
      final c = CategoryMapping.getCategoryFromTopic(topic);
      if (c != null) return c;
    }

    if (level >= 1 && level <= 100) {
      return CategoryMapping.getCategoryFromLevel(level);
    }

    return 'Old Testament';
  }

  Quiz({
    required this.id,
    required this.creatorId,
    required this.titleKey,
    required this.bibleVersion,
    required this.topics,
    required this.isPublic,
    required this.questionCount,
    required this.createdAt,
    required this.updatedAt,
    required this.titleEn,
    required this.titleTe,
    required this.descriptionEn,
    required this.descriptionTe,
    required this.level,
    required this.difficulty,
    this.setId = 'A',
  });

  factory Quiz.fromFirestore(String docId, Map<String, dynamic> data) {
    return Quiz(
      id: docId,
      creatorId: data['creatorId'] ?? '',
      titleKey: data['titleKey'] ?? '',
      bibleVersion: data['bibleVersion'] ?? '',
      topics: List<String>.from(data['topics'] ?? []),
      isPublic: data['isPublic'] ?? true,
      questionCount: data['questionCount'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is DateTime
              ? data['createdAt'] as DateTime
              : DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is DateTime
              ? data['updatedAt'] as DateTime
              : DateTime.tryParse(data['updatedAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      titleEn: data['titleEn'] ?? '',
      titleTe: data['titleTe'] ?? '',
      descriptionEn: data['descriptionEn'] ?? '',
      descriptionTe: data['descriptionTe'] ?? '',
      level: data['level'] ?? 1,
      difficulty: data['difficulty'] ?? 'easy',
      setId: data['setId'] ?? 'A',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'titleKey': titleKey,
      'bibleVersion': bibleVersion,
      'topics': topics,
      'isPublic': isPublic,
      'questionCount': questionCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'titleEn': titleEn,
      'titleTe': titleTe,
      'descriptionEn': descriptionEn,
      'descriptionTe': descriptionTe,
      'level': level,
      'difficulty': difficulty,
      'setId': setId,
    };
  }
}

class Question {
  final String id;
  final int order;
  final String type;
  final int timeLimitSeconds;
  final int points;
  final String questionEn;
  final String questionTe;
  final List<Option> options;
  final String? correctAnswerEn;
  final String? correctAnswerTe;
  final String verseReferenceEn;
  final String verseReferenceTe;
  final String explanationEn;
  final String explanationTe;

  Question({
    required this.id,
    required this.order,
    required this.type,
    required this.timeLimitSeconds,
    required this.points,
    required this.questionEn,
    required this.questionTe,
    this.options = const [],
    this.correctAnswerEn,
    this.correctAnswerTe,
    this.verseReferenceEn = '',
    this.verseReferenceTe = '',
    this.explanationEn = '',
    this.explanationTe = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order': order,
      'type': type,
      'timeLimitSeconds': timeLimitSeconds,
      'points': points,
      'questionEn': questionEn,
      'questionTe': questionTe,
      'options': options.map((o) => o.toMap()).toList(),
      'correctAnswerEn': correctAnswerEn,
      'correctAnswerTe': correctAnswerTe,
      'verseReferenceEn': verseReferenceEn,
      'verseReferenceTe': verseReferenceTe,
      'explanationEn': explanationEn,
      'explanationTe': explanationTe,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    var optionsList = map['options'] as List?;
    List<Option> parsedOptions = [];
    if (optionsList != null) {
      parsedOptions = optionsList.map((o) => Option.fromMap(Map<String, dynamic>.from(o))).toList();
    }
    return Question(
      id: map['id'] ?? '',
      order: map['order'] ?? 0,
      type: map['type'] ?? 'multiple_choice',
      timeLimitSeconds: map['timeLimitSeconds'] ?? 30,
      points: map['points'] ?? 1000,
      questionEn: map['questionEn'] ?? '',
      questionTe: map['questionTe'] ?? '',
      options: parsedOptions,
      correctAnswerEn: map['correctAnswerEn'],
      correctAnswerTe: map['correctAnswerTe'],
      verseReferenceEn: map['verseReferenceEn'] ?? '',
      verseReferenceTe: map['verseReferenceTe'] ?? '',
      explanationEn: map['explanationEn'] ?? '',
      explanationTe: map['explanationTe'] ?? '',
    );
  }
}

class Option {
  final String id;
  final int order;
  final bool isCorrect;
  final String textEn;
  final String textTe;

  Option({
    required this.id,
    required this.order,
    required this.isCorrect,
    required this.textEn,
    required this.textTe,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order': order,
      'isCorrect': isCorrect,
      'textEn': textEn,
      'textTe': textTe,
    };
  }

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      id: map['id'] ?? '',
      order: map['order'] ?? 0,
      isCorrect: map['isCorrect'] ?? false,
      textEn: map['textEn'] ?? '',
      textTe: map['textTe'] ?? '',
    );
  }
}
