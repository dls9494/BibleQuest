import 'package:cloud_firestore/cloud_firestore.dart';

class ReadingPlan {
  final String planType; // '30_day', '90_day', '365_day'
  final DateTime startDate;
  final int currentDay;
  final List<int> completedDays;
  final List<int> quizDaysCompleted;
  final int streak;
  final DateTime? lastReadDate;

  ReadingPlan({
    required this.planType,
    required this.startDate,
    required this.currentDay,
    required this.completedDays,
    required this.quizDaysCompleted,
    required this.streak,
    this.lastReadDate,
  });

  factory ReadingPlan.fromMap(Map<String, dynamic> map) {
    DateTime parsedStartDate;
    if (map['startDate'] is Timestamp) {
      parsedStartDate = (map['startDate'] as Timestamp).toDate();
    } else if (map['startDate'] is String) {
      parsedStartDate = DateTime.tryParse(map['startDate']) ?? DateTime.now();
    } else {
      parsedStartDate = DateTime.now();
    }

    DateTime? parsedLastReadDate;
    if (map['lastReadDate'] is Timestamp) {
      parsedLastReadDate = (map['lastReadDate'] as Timestamp).toDate();
    } else if (map['lastReadDate'] is String) {
      parsedLastReadDate = DateTime.tryParse(map['lastReadDate']);
    }

    return ReadingPlan(
      planType: map['planType'] ?? '30_day',
      startDate: parsedStartDate,
      currentDay: map['currentDay'] ?? 1,
      completedDays: List<int>.from(map['completedDays'] ?? []),
      quizDaysCompleted: List<int>.from(map['quizDaysCompleted'] ?? []),
      streak: map['streak'] ?? 0,
      lastReadDate: parsedLastReadDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'planType': planType,
      'startDate': startDate,
      'currentDay': currentDay,
      'completedDays': completedDays,
      'quizDaysCompleted': quizDaysCompleted,
      'streak': streak,
      'lastReadDate': lastReadDate,
    };
  }

  ReadingPlan copyWith({
    String? planType,
    DateTime? startDate,
    int? currentDay,
    List<int>? completedDays,
    List<int>? quizDaysCompleted,
    int? streak,
    DateTime? lastReadDate,
  }) {
    return ReadingPlan(
      planType: planType ?? this.planType,
      startDate: startDate ?? this.startDate,
      currentDay: currentDay ?? this.currentDay,
      completedDays: completedDays ?? this.completedDays,
      quizDaysCompleted: quizDaysCompleted ?? this.quizDaysCompleted,
      streak: streak ?? this.streak,
      lastReadDate: lastReadDate ?? this.lastReadDate,
    );
  }
}
