import 'package:cloud_firestore/cloud_firestore.dart';

class UserAchievement {
  final String? id;
  final String achievementId;
  final String userId;
  final DateTime unlockedAt;

  UserAchievement({
    this.id,
    required this.achievementId,
    required this.userId,
    required this.unlockedAt,
  });

  factory UserAchievement.fromMap(Map<String, dynamic> map, String docId) {
    final raw = map['unlockedAt'];
    DateTime unlockedAt;
    if (raw is Timestamp) {
      unlockedAt = raw.toDate();
    } else if (raw is String) {
      unlockedAt = DateTime.parse(raw);
    } else {
      unlockedAt = DateTime.now();
    }
    return UserAchievement(
      id: docId,
      achievementId: map['achievementId'] as String,
      userId: map['userId'] as String,
      unlockedAt: unlockedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'achievementId': achievementId,
      'userId': userId,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
    };
  }

  UserAchievement copyWith({
    String? id,
    String? achievementId,
    String? userId,
    DateTime? unlockedAt,
  }) {
    return UserAchievement(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      userId: userId ?? this.userId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
