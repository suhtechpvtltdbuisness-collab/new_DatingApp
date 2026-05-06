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
  final RelationshipStatus relationshipStatus;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isVerified;
  final bool isOnline;
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
    required this.relationshipStatus,
    required this.createdAt,
    required this.lastActive,
    this.isVerified = false,
    this.isOnline = false,
    this.blockedUsers,
  });

  String get fullName => '$firstName $lastName';

  int get age => DateTime.now().year - dateOfBirth.year;

  String get profileImage => photoUrls.isNotEmpty ? photoUrls.first : '';

  bool isBlocked(String userId) => blockedUsers?.contains(userId) ?? false;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final resolvedId = (json['id'] ?? json['_id'] ?? json['userId'] ?? '').toString();
    final fullName = (json['name'] ?? '').toString().trim();
    final nameParts = fullName.isEmpty
        ? const <String>[]
        : fullName.split(RegExp(r'\s+'));
    final rawPhotos = json['photoUrls'] ?? json['photos'] ?? json['images'] ?? const [];
    final location = json['location'];
    final coordinates = location is Map<String, dynamic>
        ? (location['coordinates'] as List?)
        : null;
    final dateOfBirthRaw = json['dateOfBirth'] ?? json['dob'];

    return UserModel(
      id: resolvedId,
      email: json['email'] ?? '',
      firstName: (json['firstName'] ?? (nameParts.isNotEmpty ? nameParts.first : '')).toString(),
      lastName: (json['lastName'] ??
              (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : ''))
          .toString(),
      phoneNumber: json['phoneNumber'],
      dateOfBirth: dateOfBirthRaw != null
          ? DateTime.tryParse(dateOfBirthRaw.toString()) ?? DateTime.now()
          : DateTime.now(),
      gender: _parseGender(json['gender']),
      photoUrls: _parsePhotoUrls(rawPhotos),
      bio: json['bio'],
      interests: List<String>.from(json['interests'] ?? []),
      latitude: _toDouble(json['latitude'] ?? (coordinates != null && coordinates.length > 1 ? coordinates[1] : 0.0)),
      longitude: _toDouble(json['longitude'] ?? (coordinates != null && coordinates.isNotEmpty ? coordinates[0] : 0.0)),
      city: json['city'],
      country: json['country'],
      relationshipStatus: _parseRelationshipStatus(json['relationshipStatus']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastActive: json['lastActive'] != null
          ? DateTime.tryParse(json['lastActive'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      blockedUsers: json['blockedUsers'] != null
          ? List<String>.from(json['blockedUsers'])
          : null,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static List<String> _parsePhotoUrls(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).where((item) => item.isNotEmpty).toList();
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
      'relationshipStatus': relationshipStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'isVerified': isVerified,
      'isOnline': isOnline,
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
    RelationshipStatus? relationshipStatus,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isVerified,
    bool? isOnline,
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
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }
}
