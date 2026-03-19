class Announcement {
  final String? id;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final DateTime createdAt;

  Announcement({
    this.id,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
  });

  factory Announcement.fromMap(Map<String, dynamic> map, String docId) {
    return Announcement(
      id: docId,
      title: map['title'] as String,
      body: map['body'] as String,
      authorId: map['authorId'] as String,
      authorName: map['authorName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
