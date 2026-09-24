import 'package:dating_app/utils/constants.dart';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final DateTime dateOfBirth;
  final Gender gender;
  final List<String> photoUrls;
  final String? bio;
  final List<String> interests;
  final double latitude;
  final double longitude;
  final String? city;
  final String? country;
  final String? hometown;
  final String? work;
  final String? education;
  final String? educationLevel;
  final String? height;
  final String? exercise;
  final String? starSign;
  final String? drinking;
  final String? smoking;
  final String? lookingFor;
  final String? kids;
  final String? haveKids;
  final String? religion;
  final String? politics;
  final String? pronouns;
  final String? interestedIn;
  final List<String> languages;
  final List<String> courses;
  final List<String> qualities;
  final List<String> openingMoves;
  final RelationshipStatus relationshipStatus;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isVerified;
  final bool isOnline;
  final bool active;
  final bool isHidden;
  final List<String>? blockedUsers;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.photoUrls,
    this.bio,
    required this.interests,
    required this.latitude,
    required this.longitude,
    this.city,
    this.country,
    this.hometown,
    this.work,
    this.education,
    this.educationLevel,
    this.height,
    this.exercise,
    this.starSign,
    this.drinking,
    this.smoking,
    this.lookingFor,
    this.kids,
    this.haveKids,
    this.religion,
    this.politics,
    this.pronouns,
    this.interestedIn,
    this.languages = const [],
    this.courses = const [],
    this.qualities = const [],
    this.openingMoves = const [],
    required this.relationshipStatus,
    required this.createdAt,
    required this.lastActive,
    this.isVerified = false,
    this.isOnline = false,
    this.active = true,
    this.isHidden = false,
    this.blockedUsers,
  });

  String get fullName => '$firstName $lastName'.trim();

  int get age {
    final now = DateTime.now();
    var years = now.year - dateOfBirth.year;
    final hadBirthday = now.month > dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day >= dateOfBirth.day);
    if (!hadBirthday) years -= 1;
    return years < 0 ? 0 : years;
  }

  String get profileImage => photoUrls.isNotEmpty ? photoUrls.first : '';

  String get locationLabel =>
      [city, country].whereType<String>().where((v) => v.isNotEmpty).join(', ');

  bool isBlocked(String userId) => blockedUsers?.contains(userId) ?? false;

  /// 0–100 profile completeness used for vibe score / strength.
  int get profileCompleteness {
    final checks = <bool>[
      firstName.trim().isNotEmpty,
      photoUrls.isNotEmpty,
      photoUrls.length >= 3,
      (bio?.trim().isNotEmpty ?? false),
      interests.isNotEmpty,
      (city?.trim().isNotEmpty ?? false),
      (work?.trim().isNotEmpty ?? false),
      (education?.trim().isNotEmpty ?? false),
      (lookingFor?.trim().isNotEmpty ?? false),
      languages.isNotEmpty,
      qualities.isNotEmpty,
      (height?.trim().isNotEmpty ?? false),
    ];
    final filled = checks.where((c) => c).length;
    return ((filled / checks.length) * 100).round();
  }

  int get vibeScore => profileCompleteness;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final resolvedId =
        (json['id'] ?? json['_id'] ?? json['userId'] ?? '').toString();
    final fullName = (json['name'] ?? '').toString().trim();
    final nameParts =
        fullName.isEmpty ? const <String>[] : fullName.split(RegExp(r'\s+'));
    final rawPhotos =
        json['photoUrls'] ?? json['photos'] ?? json['images'] ?? const [];
    final location = json['location'];
    final coordinates = location is Map<String, dynamic>
        ? (location['coordinates'] as List?)
        : null;
    final dateOfBirthRaw = json['dateOfBirth'] ?? json['dob'];

    return UserModel(
      id: resolvedId,
      email: json['email'] ?? '',
      firstName: (json['firstName'] ??
              (nameParts.isNotEmpty ? nameParts.first : ''))
          .toString(),
      lastName: (json['lastName'] ??
              (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : ''))
          .toString(),
      phoneNumber: json['phoneNumber'],
      dateOfBirth: dateOfBirthRaw != null
          ? DateTime.tryParse(dateOfBirthRaw.toString()) ?? DateTime.now()
          : DateTime.now(),
      gender: _parseGender(json['gender']),
      photoUrls: _parsePhotoUrls(rawPhotos),
      bio: json['bio']?.toString(),
      interests: _parseStringList(json['interests']),
      latitude: _toDouble(
        json['latitude'] ??
            (coordinates != null && coordinates.length > 1
                ? coordinates[1]
                : 0.0),
      ),
      longitude: _toDouble(
        json['longitude'] ??
            (coordinates != null && coordinates.isNotEmpty
                ? coordinates[0]
                : 0.0),
      ),
      city: _nullableString(json['city']),
      country: _nullableString(json['country']),
      hometown: _nullableString(json['hometown']),
      work: _nullableString(json['work']),
      education: _nullableString(json['education']),
      educationLevel: _nullableString(json['educationLevel']),
      height: _nullableString(json['height']),
      exercise: _nullableString(json['exercise']),
      starSign: _nullableString(json['starSign']),
      drinking: _nullableString(json['drinking']),
      smoking: _nullableString(json['smoking']),
      lookingFor: _nullableString(json['lookingFor']),
      kids: _nullableString(json['kids']),
      haveKids: _nullableString(json['haveKids']),
      religion: _nullableString(json['religion']),
      politics: _nullableString(json['politics']),
      pronouns: _nullableString(json['pronouns']),
      interestedIn: _nullableString(json['interestedIn']),
      languages: _parseStringList(json['languages']),
      courses: _parseStringList(json['courses']),
      qualities: _parseStringList(json['qualities']),
      openingMoves: _parseStringList(json['openingMoves']),
      relationshipStatus: _parseRelationshipStatus(json['relationshipStatus']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastActive: json['lastActive'] != null
          ? DateTime.tryParse(json['lastActive'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      active: json['active'] != false,
      isHidden: json['isHidden'] == true,
      blockedUsers: json['blockedUsers'] != null
          ? List<String>.from(json['blockedUsers'])
          : null,
    );
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static List<String> _parsePhotoUrls(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static Gender _parseGender(dynamic value) {
    final normalized = value?.toString().toLowerCase();
    return Gender.values.firstWhere(
      (gender) => gender.name == normalized,
      orElse: () => Gender.other,
    );
  }

  static RelationshipStatus _parseRelationshipStatus(dynamic value) {
    final normalized = value?.toString().toLowerCase();
    return RelationshipStatus.values.firstWhere(
      (status) => status.name == normalized,
      orElse: () => RelationshipStatus.single,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender.name,
      'photoUrls': photoUrls,
      'bio': bio,
      'interests': interests,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'hometown': hometown,
      'work': work,
      'education': education,
      'educationLevel': educationLevel,
      'height': height,
      'exercise': exercise,
      'starSign': starSign,
      'drinking': drinking,
      'smoking': smoking,
      'lookingFor': lookingFor,
      'kids': kids,
      'haveKids': haveKids,
      'religion': religion,
      'politics': politics,
      'pronouns': pronouns,
      'interestedIn': interestedIn,
      'languages': languages,
      'courses': courses,
      'qualities': qualities,
      'openingMoves': openingMoves,
      'relationshipStatus': relationshipStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'isVerified': isVerified,
      'isOnline': isOnline,
      'active': active,
      'blockedUsers': blockedUsers,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    Gender? gender,
    List<String>? photoUrls,
    String? bio,
    List<String>? interests,
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    String? hometown,
    String? work,
    String? education,
    String? educationLevel,
    String? height,
    String? exercise,
    String? starSign,
    String? drinking,
    String? smoking,
    String? lookingFor,
    String? kids,
    String? haveKids,
    String? religion,
    String? politics,
    String? pronouns,
    String? interestedIn,
    List<String>? languages,
    List<String>? courses,
    List<String>? qualities,
    List<String>? openingMoves,
    RelationshipStatus? relationshipStatus,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isVerified,
    bool? isOnline,
    bool? active,
    bool? isHidden,
    List<String>? blockedUsers,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      photoUrls: photoUrls ?? this.photoUrls,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
      hometown: hometown ?? this.hometown,
      work: work ?? this.work,
      education: education ?? this.education,
      educationLevel: educationLevel ?? this.educationLevel,
      height: height ?? this.height,
      exercise: exercise ?? this.exercise,
      starSign: starSign ?? this.starSign,
      drinking: drinking ?? this.drinking,
      smoking: smoking ?? this.smoking,
      lookingFor: lookingFor ?? this.lookingFor,
      kids: kids ?? this.kids,
      haveKids: haveKids ?? this.haveKids,
      religion: religion ?? this.religion,
      politics: politics ?? this.politics,
      pronouns: pronouns ?? this.pronouns,
      interestedIn: interestedIn ?? this.interestedIn,
      languages: languages ?? this.languages,
      courses: courses ?? this.courses,
      qualities: qualities ?? this.qualities,
      openingMoves: openingMoves ?? this.openingMoves,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      active: active ?? this.active,
      isHidden: isHidden ?? this.isHidden,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }
}
