import 'dart:math' as math;

import 'package:dating_app/models/user_model.dart';

/// People-tab filters.
///
/// Persistence follows what the backend actually stores:
/// - `interestedIn` → PUT /profile (the field discovery matches on)
/// - `minAge`, `maxAge`, `maxDistance`, `interests` → PUT /users/preferences
/// - everything else has no backend column and is kept per user on device
///   (see [localToJson]).
class DiscoveryFilters {
  const DiscoveryFilters({
    this.interestedIn = '',
    this.minAge = 18,
    this.maxAge = 70,
    this.expandAge = false,
    this.maxDistance = 50,
    this.expandDistance = false,
    this.distanceEnabled = false,
    this.verifiedOnly = false,
    this.interests = const [],
    this.languages = const [],
  });

  static const int ageFloor = 18;
  static const int ageCeiling = 70;

  /// 'men' | 'women' | 'other', or '' when the stored value isn't one the
  /// filter understands — then the server's own matching is left untouched.
  final String interestedIn;
  final int minAge;
  final int maxAge;

  /// "See people 2 years either side if I run out".
  final bool expandAge;
  final int maxDistance;

  /// "See people slightly further away if I run out".
  final bool expandDistance;

  /// The backend saves maxDistance but does not enforce it, so it is applied
  /// on device — only once the user has saved filters, so an untouched
  /// server default never silently hides people.
  final bool distanceEnabled;
  final bool verifiedOnly;
  final List<String> interests;
  final List<String> languages;

  static String normalizeInterestedIn(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'men':
      case 'man':
      case 'male':
        return 'men';
      case 'women':
      case 'woman':
      case 'female':
        return 'women';
      case 'other':
      case 'nonbinary':
        return 'other';
      default:
        return '';
    }
  }

  /// Gender value `/profiles?gender=` understands.
  String? get genderQuery {
    switch (interestedIn) {
      case 'men':
        return 'male';
      case 'women':
        return 'female';
      case 'other':
        return 'other';
      default:
        return null;
    }
  }

  /// Server-side query for GET /profiles. Age is sent explicitly so the
  /// "2 years either side" relaxation can widen it.
  Map<String, dynamic> toQuery({bool relaxed = false}) {
    final widen = relaxed && expandAge ? 2 : 0;
    return {
      if (genderQuery != null) 'gender': genderQuery,
      'minAge': math.max(ageFloor, minAge - widen),
      'maxAge': maxAge + widen,
    };
  }

  /// Narrows a server result on device. Only ever removes people — it can
  /// never surface someone the backend did not already return.
  List<UserModel> apply(
    List<UserModel> people, {
    double? originLat,
    double? originLng,
    bool relaxed = false,
  }) {
    final wantedInterests = interests.map((e) => e.toLowerCase()).toSet();
    final wantedLanguages = languages.map((e) => e.toLowerCase()).toSet();
    final hasOrigin =
        originLat != null &&
        originLng != null &&
        !(originLat == 0 && originLng == 0);
    final distanceLimit =
        relaxed && expandDistance ? maxDistance * 1.5 : maxDistance.toDouble();

    return people.where((person) {
      if (verifiedOnly && !person.isVerified) return false;

      if (wantedInterests.isNotEmpty &&
          !person.interests.any(
            (i) => wantedInterests.contains(i.toLowerCase()),
          )) {
        return false;
      }

      // Languages are not stored by the backend for most profiles; only
      // exclude people who list languages and share none.
      if (wantedLanguages.isNotEmpty &&
          person.languages.isNotEmpty &&
          !person.languages.any(
            (l) => wantedLanguages.contains(l.toLowerCase()),
          )) {
        return false;
      }

      if (distanceEnabled &&
          hasOrigin &&
          !(person.latitude == 0 && person.longitude == 0)) {
        final km = distanceKm(
          originLat,
          originLng,
          person.latitude,
          person.longitude,
        );
        if (km > distanceLimit) return false;
      }

      return true;
    }).toList();
  }

  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371.0;
    double rad(double deg) => deg * math.pi / 180;
    final dLat = rad(lat2 - lat1);
    final dLng = rad(lng2 - lng1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rad(lat1)) *
            math.cos(rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  Map<String, dynamic> localToJson() => {
    'expandAge': expandAge,
    'expandDistance': expandDistance,
    'distanceEnabled': distanceEnabled,
    'verifiedOnly': verifiedOnly,
    'languages': languages,
  };

  DiscoveryFilters withLocal(Map<String, dynamic> json) {
    return copyWith(
      expandAge: json['expandAge'] == true,
      expandDistance: json['expandDistance'] == true,
      distanceEnabled: json['distanceEnabled'] == true,
      verifiedOnly: json['verifiedOnly'] == true,
      languages:
          (json['languages'] as List? ?? const [])
              .map((e) => e.toString())
              .toList(),
    );
  }

  DiscoveryFilters copyWith({
    String? interestedIn,
    int? minAge,
    int? maxAge,
    bool? expandAge,
    int? maxDistance,
    bool? expandDistance,
    bool? distanceEnabled,
    bool? verifiedOnly,
    List<String>? interests,
    List<String>? languages,
  }) {
    return DiscoveryFilters(
      interestedIn: interestedIn ?? this.interestedIn,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      expandAge: expandAge ?? this.expandAge,
      maxDistance: maxDistance ?? this.maxDistance,
      expandDistance: expandDistance ?? this.expandDistance,
      distanceEnabled: distanceEnabled ?? this.distanceEnabled,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      interests: interests ?? this.interests,
      languages: languages ?? this.languages,
    );
  }
}
