class PrayerRequest {
  final String id;
  final String userId;
  final String userName;
  final String request;
  final DateTime createdAt;
  final int prayerCount; // Number of people who prayed
  final List<String> prayedByUserIds; // Users who clicked "I Prayed"
  final String userTitle; // Active profile title of the sender
  final Map<String, int> reactions; // Reaction counts
  final Map<String, String> userReactions; // userId -> reactionType
  final bool isAnswered;
  final String? testimony;
  final DateTime? answeredAt;

  PrayerRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.request,
    required this.createdAt,
    this.prayerCount = 0,
    this.prayedByUserIds = const [],
    this.userTitle = '',
    this.reactions = const {
      'praying': 0,
      'amen': 0,
      'encouraged': 0,
    },
    this.userReactions = const {},
    this.isAnswered = false,
    this.testimony,
    this.answeredAt,
  });

  factory PrayerRequest.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime parsedDate;
    try {
      parsedDate = (data['createdAt'] as dynamic).toDate();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final reactionsData = data['reactions'] as Map<dynamic, dynamic>?;
    final Map<String, int> parsedReactions = {
      'praying': (reactionsData?['praying'] ?? 0) as int,
      'amen': (reactionsData?['amen'] ?? 0) as int,
      'encouraged': (reactionsData?['encouraged'] ?? 0) as int,
    };

    final userReactionsData = data['userReactions'] as Map<dynamic, dynamic>?;
    final Map<String, String> parsedUserReactions = {};
    if (userReactionsData != null) {
      userReactionsData.forEach((key, value) {
        parsedUserReactions[key.toString()] = value.toString();
      });
    }

    DateTime? parsedAnsweredAt;
    if (data['answeredAt'] != null) {
      try {
        parsedAnsweredAt = (data['answeredAt'] as dynamic).toDate();
      } catch (_) {}
    }

    return PrayerRequest(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      request: data['request'] ?? '',
      createdAt: parsedDate,
      prayerCount: data['prayerCount'] ?? 0,
      prayedByUserIds: List<String>.from(data['prayedByUserIds'] ?? []),
      userTitle: data['userTitle'] ?? '',
      reactions: parsedReactions,
      userReactions: parsedUserReactions,
      isAnswered: data['isAnswered'] ?? false,
      testimony: data['testimony'],
      answeredAt: parsedAnsweredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'request': request,
      'createdAt': createdAt,
      'prayerCount': prayerCount,
      'prayedByUserIds': prayedByUserIds,
      'userTitle': userTitle,
      'reactions': reactions,
      'userReactions': userReactions,
      'isAnswered': isAnswered,
      'testimony': testimony,
      'answeredAt': answeredAt,
    };
  }
}
