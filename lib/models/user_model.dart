class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? photoUrl;
  final String? bio;
  final String role;
  final DateTime createdAt;
  final DateTime? birthDate;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? activityLevel;
  final String? cookingSkillLevel;
  final int followingCount;
  final int followersCount;
  final String? username;
  final bool isBanned;
  final String? banReason;
  final DateTime? bannedAt;
  final String? bannedBy;
  final List<String> dietaryPreferences;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.photoUrl,
    this.bio,
    this.role = 'user',
    required this.createdAt,
    this.birthDate,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.cookingSkillLevel,
    this.followingCount = 0,
    this.followersCount = 0,
    this.username,
    this.isBanned = false,
    this.banReason,
    this.bannedAt,
    this.bannedBy,
    this.dietaryPreferences = const [],
  });

  String get fullName => '$firstName $lastName'.trim();

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final firstName = map['firstName'] as String? ??
        (map['fullName'] as String? ?? '').split(' ').first;
    final lastName = map['lastName'] as String? ??
        () {
          final parts = (map['fullName'] as String? ?? '').split(' ');
          return parts.length > 1 ? parts.sublist(1).join(' ') : '';
        }();

    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: map['phoneNumber'] as String?,
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String?,
      role: map['role'] as String? ?? 'user',
      createdAt: DateTime.parse(map['createdAt'] as String),
      birthDate: map['birthDate'] != null
          ? DateTime.parse(map['birthDate'] as String)
          : null,
      gender: map['gender'] as String?,
      heightCm: (map['heightCm'] as num?)?.toDouble(),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      activityLevel: map['activityLevel'] as String?,
      cookingSkillLevel: map['cookingSkillLevel'] as String?,
      followingCount: map['followingCount'] as int? ?? 0,
      followersCount: map['followersCount'] as int? ?? 0,
      username: map['username'] as String?,
      isBanned: map['isBanned'] as bool? ?? false,
      banReason: map['banReason'] as String?,
      bannedAt: map['bannedAt'] != null
          ? DateTime.parse(map['bannedAt'] as String)
          : null,
      bannedBy: map['bannedBy'] as String?,
      dietaryPreferences: (map['dietaryPreferences'] as List<dynamic>?)
              ?.cast<String>() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'bio': bio,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel,
      'cookingSkillLevel': cookingSkillLevel,
      'followingCount': followingCount,
      'followersCount': followersCount,
      'username': username,
      'isBanned': isBanned,
      'banReason': banReason,
      'bannedAt': bannedAt?.toIso8601String(),
      'bannedBy': bannedBy,
      'dietaryPreferences': dietaryPreferences,
    };
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? photoUrl,
    String? bio,
    String? role,
    DateTime? birthDate,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    String? cookingSkillLevel,
    int? followingCount,
    int? followersCount,
    String? username,
    bool? isBanned,
    String? banReason,
    DateTime? bannedAt,
    String? bannedBy,
    List<String>? dietaryPreferences,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      createdAt: createdAt,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      cookingSkillLevel: cookingSkillLevel ?? this.cookingSkillLevel,
      followingCount: followingCount ?? this.followingCount,
      followersCount: followersCount ?? this.followersCount,
      username: username ?? this.username,
      isBanned: isBanned ?? this.isBanned,
      banReason: banReason ?? this.banReason,
      bannedAt: bannedAt ?? this.bannedAt,
      bannedBy: bannedBy ?? this.bannedBy,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
    );
  }
}
