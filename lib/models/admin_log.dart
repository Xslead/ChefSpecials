class AdminLog {
  final String? id;
  final String adminId;
  final String adminName;
  final String action;
  final String? targetId;
  final String? targetName;
  final String? details;
  final DateTime createdAt;

  AdminLog({
    this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    this.targetId,
    this.targetName,
    this.details,
    required this.createdAt,
  });

  factory AdminLog.fromMap(Map<String, dynamic> map, String docId) {
    return AdminLog(
      id: docId,
      adminId: map['adminId'] as String,
      adminName: map['adminName'] as String,
      action: map['action'] as String,
      targetId: map['targetId'] as String?,
      targetName: map['targetName'] as String?,
      details: map['details'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'adminName': adminName,
      'action': action,
      'targetId': targetId,
      'targetName': targetName,
      'details': details,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
