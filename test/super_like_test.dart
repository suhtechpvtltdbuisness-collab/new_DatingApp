import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/models/swipe_models.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/swipe/swipe_screen.dart';
import 'package:dating_app/services/super_like_ledger.dart';
import 'package:dating_app/services/swipe_service.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

UserModel _person(String id) => UserModel(
  id: id,
  email: '$id@example.com',
  firstName: id.toUpperCase(),
  lastName: 'Tester',
  dateOfBirth: DateTime(1998, 5, 20),
  gender: Gender.female,
  photoUrls: const [],
  interests: const [],
  latitude: 0,
  longitude: 0,
  relationshipStatus: RelationshipStatus.single,
  createdAt: DateTime(2024, 1, 1),
  lastActive: DateTime(2024, 1, 1),
);

class _FakeService implements SwipeService {
  final calls = <String>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<ApiResponse<SwipeActionResponse>> swipeRight(String id) async {
    calls.add('like:$id');
    return ApiResponse.success(
      message: 'ok',
      data: const SwipeActionResponse(isMatch: false),
    );
  }

  @override
  Future<ApiResponse<SwipeActionResponse>> superLikeProfile(
    String id, {
    String? targetEmail,
  }) async {
    calls.add('super:$id');
    return ApiResponse.success(
      message: 'ok',
      data: const SwipeActionResponse(isMatch: false),
    );
  }
}

class _TestController extends SwipeController {
  _TestController(_FakeService s) : super(swipeService: s);
  @override
  Future<bool> loadProfiles({bool refresh = false}) async => true;
  @override
  Future<bool> refreshSwipeHistory() async => true;
}

void main() {
  late _FakeService service;
  late SwipeController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    service = _FakeService();
    Get.put<SwipeService>(service, permanent: true);
    controller = Get.put<SwipeController>(_TestController(service));
    controller.hasMoreProfiles.value = false;
    controller.profiles.assignAll([_person('ana'), _person('bea')]);
  });

  tearDown(Get.reset);

  test('IncomingLike reads the super-like flag from every supported key', () {
    Map<String, dynamic> base() => {
      'id': 'u1',
      'email': 'a@b.c',
      'firstName': 'A',
      'lastName': 'B',
      'swipeId': 's1',
    };
    expect(IncomingLike.fromJson(base()).isSuperLike, isFalse);
    expect(
      IncomingLike.fromJson({...base(), 'isSuperLike': true}).isSuperLike,
      isTrue,
    );
    expect(
      IncomingLike.fromJson({...base(), 'superLike': true}).isSuperLike,
      isTrue,
    );
    expect(
      IncomingLike.fromJson({...base(), 'type': 'super_like'}).isSuperLike,
      isTrue,
    );
  });

  test(
    'submitSwipe(superLike) uses the super-like call and records a like',
    () async {
      final result = await controller.submitSwipe(
        profile: controller.profiles.first,
        action: SwipeAction.superLike,
      );
      expect(result.success, isTrue);
      expect(service.calls, ['super:ana']);
      expect(controller.likedProfiles.map((p) => p.id), ['ana']);
      expect(result.message, 'Super Like sent to ANA.');
    },
  );

  test('a normal like still uses the normal call', () async {
    await controller.submitSwipe(
      profile: controller.profiles.first,
      action: SwipeAction.like,
    );
    expect(service.calls, ['like:ana']);
  });

  testWidgets('tapping the star button super likes and shows feedback', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SwipeScreen())),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.star_rounded));
    await tester.pumpAndSettle();

    expect(service.calls, ['super:ana']);
    expect(find.textContaining('Super Like sent to ANA'), findsOneWidget);
  });

  test('ledger matches a Super Like by id or by email', () async {
    await SuperLikeLedger.record(
      senderKeys: ['sender-id', 'Sender@X.com'],
      targetKeys: ['me-id'],
    );
    expect(
      await SuperLikeLedger.has(
        senderKeys: ['nope', 'sender@x.com'],
        targetKeys: ['me-id'],
      ),
      isTrue,
    );
    expect(
      await SuperLikeLedger.has(
        senderKeys: ['sender-id'],
        targetKeys: ['someone-else'],
      ),
      isFalse,
    );
  });
}
