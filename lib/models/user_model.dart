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
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : DateTime.now(),
      gender: Gender.values.byName(json['gender'] ?? 'other'),
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
      bio: json['bio'],
      interests: List<String>.from(json['interests'] ?? []),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      city: json['city'],
      country: json['country'],
      relationshipStatus: RelationshipStatus.values
          .byName(json['relationshipStatus'] ?? 'single'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : DateTime.now(),
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      blockedUsers: json['blockedUsers'] != null
          ? List<String>.from(json['blockedUsers'])
          : null,
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
