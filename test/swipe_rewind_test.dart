import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:dating_app/models/swipe_models.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/services/swipe_service.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

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

/// A controller with no deck loading: [SwipeController.onInit] is never run
/// because the controller is constructed directly rather than through Get.
SwipeController _controller() {
  final controller = SwipeController(swipeService: SwipeService());
  // Stops submitSwipe's background top-up from reaching the network.
  controller.hasMoreProfiles.value = false;
  return controller;
}

void main() {
  group('rewindLastSwipe', () {
    test('puts the last passed person back on top of the deck', () {
      final controller = _controller();
      final passed = _person('ana');

      controller.profiles.assignAll([_person('bea')]);
      controller.dislikedProfiles.assignAll([passed]);
      controller.rewindHistory.add(
        RewindEntry(profile: passed, action: SwipeAction.dislike),
      );

      final result = controller.rewindLastSwipe();

      expect(result.success, isTrue);
      expect(result.profile?.id, 'ana');
      expect(controller.profiles.first.id, 'ana');
      // Must leave the dislike history, or the next page load would dedupe
      // this person straight back out of the deck.
      expect(controller.dislikedProfiles, isEmpty);
      expect(controller.canRewind, isFalse);
    });

    test('is unlimited: walks back through every swipe, newest first', () {
      final controller = _controller();
      final swiped = ['ana', 'bea', 'cal', 'dee', 'eve'];

      for (final id in swiped) {
        controller.rewindHistory.add(
          RewindEntry(profile: _person(id), action: SwipeAction.dislike),
        );
      }

      final restored = <String>[];
      while (controller.canRewind) {
        final result = controller.rewindLastSwipe();
        expect(result.success, isTrue);
        restored.add(result.profile!.id);
      }

      expect(restored, swiped.reversed.toList());
      expect(controller.profiles.map((p) => p.id).toList(), swiped);
    });

    test('restores a like as well as a pass', () {
      final controller = _controller();
      final liked = _person('ana');

      controller.likedProfiles.assignAll([liked]);
      controller.rewindHistory.add(
        RewindEntry(profile: liked, action: SwipeAction.like),
      );

      expect(controller.rewindLastSwipe().success, isTrue);
      expect(controller.profiles.single.id, 'ana');
      expect(controller.likedProfiles, isEmpty);
    });

    test('refuses a swipe that produced a match', () {
      final controller = _controller();

      controller.rewindHistory.add(
        RewindEntry(
          profile: _person('ana'),
          action: SwipeAction.like,
          matchId: 'match-1',
        ),
      );

      final result = controller.rewindLastSwipe();

      expect(result.success, isFalse);
      expect(result.message, contains('Unmatch'));
      // The entry stays put so the history keeps its order.
      expect(controller.canRewind, isTrue);
      expect(controller.profiles, isEmpty);
    });

    test('reports there is nothing to undo on an empty history', () {
      final controller = _controller();

      final result = controller.rewindLastSwipe();

      expect(result.success, isFalse);
      expect(result.profile, isNull);
      expect(controller.canRewind, isFalse);
    });

    test('never restores the same person twice', () {
      final controller = _controller();
      final ana = _person('ana');

      controller.profiles.assignAll([ana]);
      controller.rewindHistory.add(
        RewindEntry(profile: ana, action: SwipeAction.dislike),
      );

      expect(controller.rewindLastSwipe().success, isTrue);
      expect(controller.profiles.where((p) => p.id == 'ana').length, 1);
    });

    test('a blocked person drops out of the rewind history', () {
      final controller = _controller();

      controller.rewindHistory.addAll([
        RewindEntry(profile: _person('ana'), action: SwipeAction.dislike),
        RewindEntry(profile: _person('bea'), action: SwipeAction.dislike),
      ]);

      controller.removeProfile('bea');

      expect(controller.rewindHistory.single.profile.id, 'ana');
      expect(controller.rewindLastSwipe().profile?.id, 'ana');
    });

    test('signing out clears the history', () {
      final controller = _controller();

      controller.rewindHistory.add(
        RewindEntry(profile: _person('ana'), action: SwipeAction.dislike),
      );

      controller.resetSession();

      expect(controller.canRewind, isFalse);
    });
  });
}
