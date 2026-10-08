import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:dating_app/models/swipe_models.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/swipe/swipe_screen.dart';
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
      photoUrls: const [], // keeps the card on a bundled asset, off the network
      interests: const [],
      latitude: 0,
      longitude: 0,
      relationshipStatus: RelationshipStatus.single,
      createdAt: DateTime(2024, 1, 1),
      lastActive: DateTime(2024, 1, 1),
    );

/// Keeps the controller off the network. Both onInit and the load that
/// [SwipeScreen] kicks off on an empty deck go through these two methods, so
/// stubbing them stops request timers outliving the test.
class _TestSwipeController extends SwipeController {
  _TestSwipeController() : super(swipeService: SwipeService());

  @override
  Future<bool> loadProfiles({bool refresh = false}) async => true;

  @override
  Future<bool> refreshSwipeHistory() async => true;
}

SwipeController _seed(List<UserModel> deck) {
  final controller = Get.put<SwipeController>(_TestSwipeController());
  controller.hasMoreProfiles.value = false;
  controller.profiles.assignAll(deck);
  return controller;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    Get.put<SwipeService>(SwipeService(), permanent: true);
  });

  tearDown(Get.reset);

  testWidgets('the rewind button brings the last passed person back',
      (tester) async {
    final controller = _seed([_person('bea')]);
    controller.dislikedProfiles.assignAll([_person('ana')]);
    controller.rewindHistory.add(
      RewindEntry(profile: _person('ana'), action: SwipeAction.dislike),
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SwipeScreen())),
    );
    await tester.pump();

    expect(find.text('BEA Tester, ${_person('bea').age}'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.replay_rounded));
    await tester.pumpAndSettle();

    expect(controller.profiles.first.id, 'ana');
    expect(controller.canRewind, isFalse);
  });

  testWidgets('an empty deck still offers to bring the last person back',
      (tester) async {
    // Passing the very last card lands here, which is exactly when a rewind
    // matters most — there is no deck left to show the button row.
    final controller = _seed(const []);
    controller.rewindHistory.add(
      RewindEntry(profile: _person('ana'), action: SwipeAction.dislike),
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SwipeScreen())),
    );
    await tester.pump();

    expect(find.text('Bring back ANA Tester'), findsOneWidget);

    await tester.tap(find.text('Bring back ANA Tester'));
    await tester.pumpAndSettle();

    expect(controller.profiles.single.id, 'ana');
    expect(find.text('ANA Tester, ${_person('ana').age}'), findsOneWidget);
  });

  testWidgets('an empty deck with no history offers no rewind', (tester) async {
    _seed(const []);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SwipeScreen())),
    );
    await tester.pump();

    expect(find.byIcon(Icons.replay_rounded), findsNothing);
  });

  testWidgets('the rewind button is disabled with no history', (tester) async {
    _seed([_person('bea')]);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SwipeScreen())),
    );
    await tester.pump();

    final button = find.ancestor(
      of: find.byIcon(Icons.replay_rounded),
      matching: find.byType(GestureDetector),
    );
    expect(tester.widget<GestureDetector>(button.first).onTap, isNull);
  });
}
