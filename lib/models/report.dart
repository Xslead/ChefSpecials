class Report {
  final String? id;
  final String reporterId;
  final String targetType; // 'recipe' | 'comment' | 'user'
  final String targetId;
  final String? targetAuthorId;
  final String? targetName; // recipe title or username for display
  final String? reporterName; // display name of the reporter
  final String reason;
  final String? description; // optional extra context from reporter
  final String status; // 'pending' | 'reviewed' | 'dismissed'
  final DateTime createdAt;
  final String? reviewedBy;
  final String? reviewNote;
  final DateTime? reviewedAt;

  const Report({
    this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    this.targetAuthorId,
    this.targetName,
    this.reporterName,
    required this.reason,
    this.description,
    this.status = 'pending',
    required this.createdAt,
    this.reviewedBy,
    this.reviewNote,
    this.reviewedAt,
  });

  factory Report.fromMap(Map<String, dynamic> map, String docId) {
    return Report(
      id: docId,
      reporterId: map['reporterId'] as String,
      targetType: map['targetType'] as String,
      targetId: map['targetId'] as String,
      targetAuthorId: map['targetAuthorId'] as String?,
      targetName: map['targetName'] as String?,
      reporterName: map['reporterName'] as String?,
      reason: map['reason'] as String,
      description: map['description'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(map['createdAt'] as String),
      reviewedBy: map['reviewedBy'] as String?,
      reviewNote: map['reviewNote'] as String?,
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.parse(map['reviewedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'targetType': targetType,
      'targetId': targetId,
      'targetAuthorId': targetAuthorId,
      'targetName': targetName,
      'reporterName': reporterName,
      'reason': reason,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'reviewedBy': reviewedBy,
      'reviewNote': reviewNote,
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }
}
