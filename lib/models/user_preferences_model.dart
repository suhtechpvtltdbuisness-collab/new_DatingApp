import 'package:dating_app/utils/constants.dart';

class UserPreferencesModel {
  final String id;
  final String userId;
  final int minAge;
  final int maxAge;
  final int maxDistance; // in kilometers
  final List<UserLookingFor> lookingFor;
  final List<String> interests;
  final List<Gender> preferredGenders;
  final bool locationEnabled;
  final bool showOnline;
  final bool notificationsEnabled;
  final DateTime lastUpdated;

  UserPreferencesModel({
    required this.id,
    required this.userId,
    this.minAge = 18,
    this.maxAge = 70,
    this.maxDistance = 50,
    this.lookingFor = const [UserLookingFor.dating],
    this.interests = const [],
    this.preferredGenders = const [Gender.female],
    this.locationEnabled = true,
    this.showOnline = true,
    this.notificationsEnabled = true,
    required this.lastUpdated,
  });

  factory UserPreferencesModel.defaultPreferences(String userId) {
    return UserPreferencesModel(
      id: '',
      userId: userId,
      lastUpdated: DateTime.now(),
    );
  }

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      minAge: json['minAge'] ?? 18,
      maxAge: json['maxAge'] ?? 70,
      maxDistance: json['maxDistance'] ?? 50,
      lookingFor: json['lookingFor'] != null
          ? List<UserLookingFor>.from((json['lookingFor'] as List)
              .map((e) => UserLookingFor.values.byName(e)))
          : [UserLookingFor.dating],
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : [],
      preferredGenders: json['preferredGenders'] != null
          ? List<Gender>.from((json['preferredGenders'] as List)
              .map((e) => Gender.values.byName(e)))
          : [Gender.female],
      locationEnabled: json['locationEnabled'] ?? true,
      showOnline: json['showOnline'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'minAge': minAge,
      'maxAge': maxAge,
      'maxDistance': maxDistance,
      'lookingFor': lookingFor.map((e) => e.name).toList(),
      'interests': interests,
      'preferredGenders': preferredGenders.map((e) => e.name).toList(),
      'locationEnabled': locationEnabled,
      'showOnline': showOnline,
      'notificationsEnabled': notificationsEnabled,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  UserPreferencesModel copyWith({
    String? id,
    String? userId,
    int? minAge,
    int? maxAge,
    int? maxDistance,
    List<UserLookingFor>? lookingFor,
    List<String>? interests,
    List<Gender>? preferredGenders,
    bool? locationEnabled,
    bool? showOnline,
    bool? notificationsEnabled,
    DateTime? lastUpdated,
  }) {
    return UserPreferencesModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      maxDistance: maxDistance ?? this.maxDistance,
      lookingFor: lookingFor ?? this.lookingFor,
      interests: interests ?? this.interests,
      preferredGenders: preferredGenders ?? this.preferredGenders,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      showOnline: showOnline ?? this.showOnline,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
