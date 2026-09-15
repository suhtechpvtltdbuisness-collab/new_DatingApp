import 'package:dating_app/models/discovery_filters.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';

UserModel _person(
  String id, {
  bool verified = false,
  List<String> interests = const [],
  List<String> languages = const [],
  double lat = 28.6,
  double lng = 77.2,
}) {
  return UserModel(
    id: id,
    email: '',
    firstName: id,
    lastName: '',
    dateOfBirth: DateTime(1998),
    gender: Gender.female,
    photoUrls: const [],
    interests: interests,
    languages: languages,
    latitude: lat,
    longitude: lng,
    relationshipStatus: RelationshipStatus.single,
    createdAt: DateTime(2026),
    lastActive: DateTime(2026),
    isVerified: verified,
  );
}

void main() {
  group('DiscoveryFilters.normalizeInterestedIn', () {
    test('maps signup and API values', () {
      expect(DiscoveryFilters.normalizeInterestedIn('Men'), 'men');
      expect(DiscoveryFilters.normalizeInterestedIn('female'), 'women');
      expect(DiscoveryFilters.normalizeInterestedIn('other'), 'other');
    });

    test('unknown values stay unset so server matching is untouched', () {
      expect(DiscoveryFilters.normalizeInterestedIn('gay'), '');
      expect(const DiscoveryFilters(interestedIn: '').toQuery().containsKey('gender'), isFalse);
    });
  });

  group('toQuery', () {
    test('sends saved age range and gender', () {
      final q = const DiscoveryFilters(interestedIn: 'men', minAge: 25, maxAge: 30).toQuery();
      expect(q, {'gender': 'male', 'minAge': 25, 'maxAge': 30});
    });

    test('relaxed widens age by 2 only when enabled, never below 18', () {
      const f = DiscoveryFilters(minAge: 19, maxAge: 30, expandAge: true);
      expect(f.toQuery(relaxed: true)['minAge'], 18);
      expect(f.toQuery(relaxed: true)['maxAge'], 32);
      expect(f.copyWith(expandAge: false).toQuery(relaxed: true)['maxAge'], 30);
    });
  });

  group('apply', () {
    final people = [
      _person('a', verified: true, interests: ['Music']),
      _person('b', interests: ['hiking'], languages: ['Hindi']),
      _person('c', verified: true, lat: 30.45, lng: 77.6), // ~200 km away
    ];

    test('no filters keeps everyone', () {
      expect(const DiscoveryFilters().apply(people).length, 3);
    });

    test('verified only', () {
      final ids = const DiscoveryFilters(verifiedOnly: true).apply(people).map((p) => p.id);
      expect(ids, ['a', 'c']);
    });

    test('interests match case-insensitively', () {
      final ids = const DiscoveryFilters(interests: ['music', 'Hiking']).apply(people).map((p) => p.id);
      expect(ids, ['a', 'b']);
    });

    test('languages only exclude people who list other languages', () {
      final ids = const DiscoveryFilters(languages: ['English']).apply(people).map((p) => p.id);
      expect(ids, ['a', 'c']);
    });

    test('distance applies only once enabled, and relaxes by 50%', () {
      const f = DiscoveryFilters(maxDistance: 150);
      expect(f.apply(people, originLat: 28.6, originLng: 77.2).length, 3);
      final enabled = f.copyWith(distanceEnabled: true, expandDistance: true);
      expect(enabled.apply(people, originLat: 28.6, originLng: 77.2).map((p) => p.id), ['a', 'b']);
      expect(enabled.apply(people, originLat: 28.6, originLng: 77.2, relaxed: true).length, 3);
    });

    test('never adds people', () {
      expect(const DiscoveryFilters().apply(const []), isEmpty);
    });
  });
}
