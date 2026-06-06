class Referral {
  final String userId;
  final String referralCode;
  final List<String> referredUsers; // userIds of people who used this code
  final int totalReferrals;
  final int xpEarned;

  Referral({
    required this.userId,
    required this.referralCode,
    this.referredUsers = const [],
    this.totalReferrals = 0,
    this.xpEarned = 0,
  });

  factory Referral.fromMap(Map<String, dynamic> map, String userId) {
    return Referral(
      userId: userId,
      referralCode: map['referralCode'] ?? '',
      referredUsers: List<String>.from(map['referredUsers'] ?? []),
      totalReferrals: map['totalReferrals'] ?? 0,
      xpEarned: map['xpEarned'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'referralCode': referralCode,
      'referredUsers': referredUsers,
      'totalReferrals': totalReferrals,
      'xpEarned': xpEarned,
    };
  }
}
