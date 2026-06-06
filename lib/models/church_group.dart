import 'package:cloud_firestore/cloud_firestore.dart';

class ChurchGroup {
  final String id;
  final String name;
  final String description;
  final String pastorId;
  final String pastorName;
  final String joinCode;
  final List<String> memberIds;
  final List<String> memberNames;
  final DateTime createdAt;
  final int totalMembers;

  ChurchGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.pastorId,
    required this.pastorName,
    required this.joinCode,
    required this.memberIds,
    required this.memberNames,
    required this.createdAt,
    required this.totalMembers,
  });

  factory ChurchGroup.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime parsedDate;
    try {
      final created = data['createdAt'];
      if (created is Timestamp) {
        parsedDate = created.toDate();
      } else if (created is String) {
        parsedDate = DateTime.parse(created);
      } else {
        parsedDate = DateTime.now();
      }
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return ChurchGroup(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      pastorId: data['pastorId'] ?? '',
      pastorName: data['pastorName'] ?? '',
      joinCode: data['joinCode'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      memberNames: List<String>.from(data['memberNames'] ?? []),
      createdAt: parsedDate,
      totalMembers: data['totalMembers'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'pastorId': pastorId,
      'pastorName': pastorName,
      'joinCode': joinCode,
      'memberIds': memberIds,
      'memberNames': memberNames,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalMembers': totalMembers,
    };
  }
}

class GroupChallenge {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final int quizLevel;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, int> participantScores; // userId -> score

  GroupChallenge({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.quizLevel,
    required this.startDate,
    required this.endDate,
    required this.participantScores,
  });

  factory GroupChallenge.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime parsedStart;
    try {
      final start = data['startDate'];
      if (start is Timestamp) {
        parsedStart = start.toDate();
      } else if (start is String) {
        parsedStart = DateTime.parse(start);
      } else {
        parsedStart = DateTime.now();
      }
    } catch (_) {
      parsedStart = DateTime.now();
    }

    DateTime parsedEnd;
    try {
      final end = data['endDate'];
      if (end is Timestamp) {
        parsedEnd = end.toDate();
      } else if (end is String) {
        parsedEnd = DateTime.parse(end);
      } else {
        parsedEnd = DateTime.now();
      }
    } catch (_) {
      parsedEnd = DateTime.now();
    }

    final scoresData = data['participantScores'] as Map<dynamic, dynamic>?;
    final Map<String, int> parsedScores = {};
    if (scoresData != null) {
      scoresData.forEach((key, value) {
        if (value is num) {
          parsedScores[key.toString()] = value.toInt();
        }
      });
    }

    return GroupChallenge(
      id: id,
      groupId: data['groupId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      quizLevel: data['quizLevel'] ?? 1,
      startDate: parsedStart,
      endDate: parsedEnd,
      participantScores: parsedScores,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'title': title,
      'description': description,
      'quizLevel': quizLevel,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'participantScores': participantScores,
    };
  }
}
