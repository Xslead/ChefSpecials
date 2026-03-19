enum ActivityType { follow, comment, rating, newRecipe }

class Activity {
  final String? id;
  final String userId;
  final String actorId;
  final String actorName;
  final String? actorAvatar;
  final ActivityType type;
  final String? targetId;
  final String? targetName;
  final String? targetImageUrl;
  final String? message;
  final bool isRead;
  final DateTime createdAt;

  Activity({
    this.id,
    required this.userId,
    required this.actorId,
    required this.actorName,
    this.actorAvatar,
    required this.type,
    this.targetId,
    this.targetName,
    this.targetImageUrl,
    this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory Activity.fromMap(Map<String, dynamic> map, String docId) {
    return Activity(
      id: docId,
      userId: map['userId'] as String,
      actorId: map['actorId'] as String,
      actorName: map['actorName'] as String,
      actorAvatar: map['actorAvatar'] as String?,
      type: ActivityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ActivityType.follow,
      ),
      targetId: map['targetId'] as String?,
      targetName: map['targetName'] as String?,
      targetImageUrl: map['targetImageUrl'] as String?,
      message: map['message'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'actorId': actorId,
      'actorName': actorName,
      'actorAvatar': actorAvatar,
      'type': type.name,
      'targetId': targetId,
      'targetName': targetName,
      'targetImageUrl': targetImageUrl,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
