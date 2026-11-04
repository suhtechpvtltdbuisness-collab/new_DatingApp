import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/swipe/swipe_screen.dart';
import 'package:dating_app/services/swipe_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _json(Map<String, dynamic> photos) => {
  'id': 'u1',
  'firstName': 'Ana',
  'dateOfBirth': '1998-05-20',
  'gender': 'female',
  'createdAt': '2024-01-01T00:00:00Z',
  'lastActive': '2024-01-01T00:00:00Z',
  ...photos,
};

class _Svc implements SwipeService {
  int detailCalls = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<ApiResponse<UserModel>> getProfileDetail(String userId) async {
    detailCalls++;
    return ApiResponse.success(
      message: 'ok',
      data: UserModel.fromJson(
        _json({
          'photoUrls': [
            'http://localhost/a.jpg',
            'http://localhost/b.jpg',
            'http://localhost/c.jpg',
          ],
        }),
      ),
    );
  }
}

class _Ctl extends SwipeController {
  _Ctl(SwipeService s) : super(swipeService: s);
  @override
  Future<bool> loadProfiles({bool refresh = false}) async => true;
  @override
  Future<bool> refreshSwipeHistory() async => true;
}

void main() {
  group('photo parsing', () {
    test('empty photoUrls falls through to photos', () {
      final u = UserModel.fromJson(
        _json({
          'photoUrls': [],
          'photos': ['http://x/1.jpg', 'http://x/2.jpg'],
        }),
      );
      expect(u.photoUrls, ['http://x/1.jpg', 'http://x/2.jpg']);
    });

    test('photo objects with a url are accepted', () {
      final u = UserModel.fromJson(
        _json({
          'photos': [
            {'url': 'http://x/1.jpg'},
            {'secure_url': 'http://x/2.jpg'},
            'http://x/3.jpg',
          ],
        }),
      );
      expect(u.photoUrls.length, 3);
      expect(u.photoUrls.every((e) => e.startsWith('http://x/')), isTrue);
    });

    test('plain strings still work', () {
      final u = UserModel.fromJson(
        _json({
          'photoUrls': ['http://x/1.jpg', 'http://x/2.jpg', 'http://x/3.jpg'],
        }),
      );
      expect(u.photoUrls.length, 3);
    });
  });

  group('photo hydration', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      Get.testMode = true;
    });
    tearDown(Get.reset);

    testWidgets('a card with one photo gets all of them from the detail call', (
      t,
    ) async {
      final svc = _Svc();
      Get.put<SwipeService>(svc, permanent: true);
      final c = Get.put<SwipeController>(_Ctl(svc));
      c.hasMoreProfiles.value = false;
      c.profiles.assignAll([
        UserModel.fromJson(_json({'photoUrls': ['http://localhost/a.jpg']})),
      ]);

      t.view.physicalSize = const Size(390, 844);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: Scaffold(body: SwipeScreen())));
      await t.pumpAndSettle();

      expect(svc.detailCalls, 1);
      expect(c.profiles.first.photoUrls.length, 3);
      final segs =
          t.widgetList<AnimatedFractionallySizedBox>(find.byType(AnimatedFractionallySizedBox)).length;
      expect(segs, 3); // story bar now has 3 segments

      // asking again does not refetch
      await c.hydratePhotos(c.profiles.first);
      expect(svc.detailCalls, 1);
    });

    testWidgets('a card that already has several photos makes no extra call', (
      t,
    ) async {
      final svc = _Svc();
      Get.put<SwipeService>(svc, permanent: true);
      final c = Get.put<SwipeController>(_Ctl(svc));
      c.hasMoreProfiles.value = false;
      c.profiles.assignAll([
        UserModel.fromJson(
          _json({'photoUrls': ['http://localhost/a.jpg', 'http://localhost/b.jpg']}),
        ),
      ]);
      t.view.physicalSize = const Size(390, 844);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: Scaffold(body: SwipeScreen())));
      await t.pumpAndSettle();
      expect(svc.detailCalls, 0);
    });
  });
}
