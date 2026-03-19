class BanAppeal {
  final String? id;
  final String userId;
  final String userName;
  final String userEmail;
  final String appealText;
  final String status; // 'pending', 'approved', 'rejected'
  final String? reviewedBy;
  final String? reviewNote;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  BanAppeal({
    this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.appealText,
    this.status = 'pending',
    this.reviewedBy,
    this.reviewNote,
    required this.createdAt,
    this.reviewedAt,
  });

  factory BanAppeal.fromMap(Map<String, dynamic> map, String docId) {
    return BanAppeal(
      id: docId,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userEmail: map['userEmail'] as String,
      appealText: map['appealText'] as String,
      status: map['status'] as String? ?? 'pending',
      reviewedBy: map['reviewedBy'] as String?,
      reviewNote: map['reviewNote'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.parse(map['reviewedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'appealText': appealText,
      'status': status,
      'reviewedBy': reviewedBy,
      'reviewNote': reviewNote,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  BanAppeal copyWith({
    String? appealText,
    String? status,
    String? reviewedBy,
    String? reviewNote,
    DateTime? reviewedAt,
  }) {
    return BanAppeal(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      appealText: appealText ?? this.appealText,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewNote: reviewNote ?? this.reviewNote,
      createdAt: createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
