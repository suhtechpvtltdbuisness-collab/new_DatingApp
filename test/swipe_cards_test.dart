import 'dart:async';

import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:dating_app/models/swipe_models.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/swipe/swipe_screen.dart';
import 'package:dating_app/services/swipe_service.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:dating_app/widgets/swipe/glass.dart';
import 'package:dating_app/widgets/swipe/profile_card.dart';
import 'package:dating_app/widgets/swipe/swipe_stamp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

UserModel _person(
  String id, {
  List<String> photos = const [],
  List<String> interests = const [],
  String? work,
  String? city,
  String? height,
  bool online = false,
  bool verified = false,
  double lat = 0,
  double lng = 0,
}) => UserModel(
  id: id,
  email: '$id@example.com',
  firstName: id.toUpperCase(),
  lastName: 'Tester',
  dateOfBirth: DateTime(1998, 5, 20),
  gender: Gender.female,
  photoUrls: photos,
  interests: interests,
  latitude: lat,
  longitude: lng,
  work: work,
  city: city,
  height: height,
  isOnline: online,
  isVerified: verified,
  relationshipStatus: RelationshipStatus.single,
  createdAt: DateTime(2024, 1, 1),
  lastActive: DateTime(2024, 1, 1),
);

/// No network. [submitSwipe] removes the card like the real one does and
/// records what was sent; [gate] can hold the "request" open.
class _Ctl extends SwipeController {
  _Ctl() : super(swipeService: SwipeService());

  final sent = <(String, SwipeAction)>[];
  Completer<void>? gate;

  @override
  Future<bool> loadProfiles({bool refresh = false}) async => true;

  @override
  Future<bool> refreshSwipeHistory() async => true;

  @override
  Future<void> hydratePhotos(UserModel person) async {}

  @override
  Future<SwipeSubmissionResult> submitSwipe({
    required UserModel profile,
    required SwipeAction action,
  }) async {
    sent.add((profile.id, action));
    profiles.removeWhere((p) => p.id == profile.id);
    if (gate != null) await gate!.future;
    // Super like opens the real match screen (network + timers); report a
    // failure for it so tests stay on this screen. The action is recorded.
    return SwipeSubmissionResult(
      success: action != SwipeAction.superLike,
      message: 'stub',
    );
  }
}

_Ctl _seed(List<UserModel> deck) {
  final c = Get.put<SwipeController>(_Ctl()) as _Ctl;
  c.hasMoreProfiles.value = false;
  c.profiles.assignAll(deck);
  return c;
}

Future<void> _pump(WidgetTester t) async {
  t.view.physicalSize = const Size(390, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(const MaterialApp(home: Scaffold(body: SwipeScreen())));
  await t.pump();
}

/// Widths of the story segments' fills, e.g. [1, 0, 0] = first photo.
List<double> _segments(WidgetTester t) => t
    .widgetList<AnimatedFractionallySizedBox>(
      find.descendant(
        of: find.byKey(
          ValueKey('card-${Get.find<SwipeController>().profiles.first.id}'),
        ),
        matching: find.byType(AnimatedFractionallySizedBox),
      ),
    )
    .map((w) => w.widthFactor ?? 0)
    .toList();

double _stamp(WidgetTester t, String label) {
  final f = find.byWidgetPredicate((w) => w is SwipeStamp && w.label == label);
  return f.evaluate().isEmpty ? 0 : t.widget<SwipeStamp>(f).opacity;
}

const _photos = ['http://localhost/1.jpg', 'http://localhost/2.jpg', 'http://localhost/3.jpg'];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    Get.put<SwipeService>(SwipeService(), permanent: true);
  });
  tearDown(Get.reset);

  group('card content', () {
    testWidgets('shows only the fields that exist (never "null")', (t) async {
      _seed([_person('aarav', work: 'Architect', city: 'Delhi', height: "6'0\"")]);
      await _pump(t);
      expect(find.text('AARAV, 28'), findsOneWidget);
      expect(find.text("Architect · Delhi · 6'0\""), findsOneWidget);
      expect(find.textContaining('null'), findsNothing);
    });

    testWidgets('missing subtitle fields are skipped', (t) async {
      _seed([_person('bea', city: 'Mumbai')]);
      await _pump(t);
      expect(find.text('Mumbai'), findsOneWidget);
      expect(find.textContaining('null'), findsNothing);
      expect(find.textContaining(' · '), findsNothing);
    });

    testWidgets('chips are capped at 3; active pill only when online', (t) async {
      _seed([_person('cy', interests: ['Travel', 'Music', 'Foodie', 'Yoga', 'Art'], online: true)]);
      await _pump(t);
      expect(find.byType(GlassChip), findsNWidgets(3));
      expect(find.text('Yoga'), findsNothing);
      expect(find.text('Active now'), findsOneWidget);
    });

    testWidgets('offline user: no Active pill; no coords: no distance', (t) async {
      _seed([_person('dee')]);
      await _pump(t);
      expect(find.text('Active now'), findsNothing);
      expect(find.textContaining(' km'), findsNothing);
    });

    testWidgets('all four labelled buttons are visible', (t) async {
      _seed([_person('eve')]);
      await _pump(t);
      for (final l in ['Pass', 'Rewind', 'Super like', 'Like']) {
        expect(find.text(l), findsOneWidget);
      }
    });
  });

  group('story-style photos', () {
    testWidgets('right half = next, left half = previous', (t) async {
      _seed([_person('fay', photos: _photos)]);
      await _pump(t);
      expect(_segments(t), [1, 0, 0]);

      final card = find.byType(SwipeScreen);
      final c = t.getCenter(card);
      final r = Offset(c.dx + 120, c.dy - 80);
      final l = Offset(c.dx - 120, c.dy - 80);

      await t.tapAt(r);
      await t.pump(const Duration(milliseconds: 300));
      expect(_segments(t), [1, 1, 0]);

      await t.tapAt(r);
      await t.pump(const Duration(milliseconds: 300));
      expect(_segments(t), [1, 1, 1]);

      // last photo: right tap does nothing
      await t.tapAt(r);
      await t.pump(const Duration(milliseconds: 400));
      expect(_segments(t), [1, 1, 1]);

      await t.tapAt(l);
      await t.pump(const Duration(milliseconds: 300));
      expect(_segments(t), [1, 1, 0]);
    });

    testWidgets('left tap on the first photo stays on it', (t) async {
      _seed([_person('gus', photos: _photos)]);
      await _pump(t);
      final c = t.getCenter(find.byType(SwipeScreen));
      await t.tapAt(Offset(c.dx - 120, c.dy - 80));
      await t.pump(const Duration(milliseconds: 400));
      expect(_segments(t), [1, 0, 0]);
    });

    testWidgets('single photo: one full segment, taps do nothing', (t) async {
      _seed([_person('hal', photos: ['http://localhost/1.jpg'])]);
      await _pump(t);
      expect(_segments(t), [1]);
      final c = t.getCenter(find.byType(SwipeScreen));
      await t.tapAt(Offset(c.dx + 120, c.dy - 80));
      await t.pump(const Duration(milliseconds: 300));
      expect(_segments(t), [1]);
    });

    testWidgets('tapping a chip does NOT change the photo', (t) async {
      _seed([_person('ivy', photos: _photos, interests: ['Travel', 'Music'])]);
      await _pump(t);
      await t.tap(find.text('Music'));
      await t.pump(const Duration(milliseconds: 300));
      expect(_segments(t), [1, 0, 0]);
    });

    testWidgets('the expand arrow fires onExpand, not photo navigation', (t) async {
      var opened = 0;
      final p = _person('jo', photos: _photos);
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 358,
              height: 560,
              child: ProfileCard(
                key: ValueKey('card-${p.id}'),
                profile: p,
                onExpand: () => opened++,
              ),
            ),
          ),
        ),
      );
      await t.tap(find.byIcon(Icons.north_east_rounded));
      await t.pump(const Duration(milliseconds: 300));
      expect(opened, 1);
      expect(
        t.widgetList<AnimatedFractionallySizedBox>(find.byType(AnimatedFractionallySizedBox)).map((w) => w.widthFactor).toList(),
        [1, 0, 0],
      );
    });

    testWidgets('long press hides the overlay, release shows it', (t) async {
      _seed([_person('kit', photos: _photos)]);
      await _pump(t);
      final c = t.getCenter(find.byType(SwipeScreen));
      final g = await t.startGesture(Offset(c.dx, c.dy - 60));
      await t.pump(const Duration(milliseconds: 700));
      final hidden = t.widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity)).any((o) => o.opacity == 0);
      expect(hidden, isTrue);
      await g.up();
      await t.pump(const Duration(milliseconds: 300));
      final shown = t.widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity)).every((o) => o.opacity != 0);
      expect(shown, isTrue);
      expect(_segments(t), [1, 0, 0]); // peeking never navigates
    });
  });

  group('swipe gestures', () {
    testWidgets('drag right past threshold -> like, next card shown', (t) async {
      final c = _seed([_person('a1'), _person('b2'), _person('c3')]);
      await _pump(t);
      await t.drag(find.text('A1, 28'), const Offset(300, 0));
      await t.pumpAndSettle();
      expect(c.sent, [('a1', SwipeAction.like)]);
      expect(find.text('B2, 28'), findsOneWidget);
      expect(find.text('A1, 28'), findsNothing);
    });

    testWidgets('drag left -> pass', (t) async {
      final c = _seed([_person('a1'), _person('b2')]);
      await _pump(t);
      await t.drag(find.text('A1, 28'), const Offset(-300, 0));
      await t.pumpAndSettle();
      expect(c.sent, [('a1', SwipeAction.dislike)]);
    });

    testWidgets('drag up -> super like', (t) async {
      final c = _seed([_person('a1'), _person('b2')]);
      await _pump(t);
      await t.drag(find.text('A1, 28'), const Offset(0, -320));
      await t.pumpAndSettle();
      expect(c.sent, [('a1', SwipeAction.superLike)]);
    });

    testWidgets('short drag springs back and sends nothing', (t) async {
      final c = _seed([_person('a1'), _person('b2')]);
      await _pump(t);
      final before = t.getCenter(find.text('A1, 28'));
      await t.drag(find.text('A1, 28'), const Offset(60, 10));
      await t.pumpAndSettle();
      expect(c.sent, isEmpty);
      expect(t.getCenter(find.text('A1, 28')).dx, closeTo(before.dx, 1.5));
    });

    testWidgets('stamps fade in with the drag direction', (t) async {
      _seed([_person('a1'), _person('b2')]);
      await _pump(t);
      final g = await t.startGesture(t.getCenter(find.text('A1, 28')));
      await g.moveBy(const Offset(40, 0));
      await g.moveBy(const Offset(60, 0));
      await t.pump();
      expect(_stamp(t, 'LIKE'), greaterThan(0));
      expect(_stamp(t, 'NOPE'), 0);
      await g.moveBy(const Offset(-260, 0));
      await t.pump();
      expect(_stamp(t, 'NOPE'), greaterThan(0));
      expect(_stamp(t, 'LIKE'), 0);
      await g.moveBy(const Offset(160, -240));
      await t.pump();
      expect(_stamp(t, 'SUPER LIKE'), greaterThan(0));
      await g.up();
      await t.pumpAndSettle();
    });

    testWidgets('a quick tap is a tap, never a swipe', (t) async {
      final c = _seed([_person('a1', photos: _photos), _person('b2')]);
      await _pump(t);
      final ctr = t.getCenter(find.byType(SwipeScreen));
      await t.tapAt(Offset(ctr.dx + 100, ctr.dy - 80));
      await t.pump(const Duration(milliseconds: 400));
      expect(c.sent, isEmpty);
      expect(_segments(t), [1, 1, 0]);
    });

    testWidgets('the next card is usable while the last swipe is still sending', (t) async {
      final c = _seed([_person('a1'), _person('b2'), _person('c3')]);
      c.gate = Completer<void>();
      await _pump(t);
      await t.drag(find.text('A1, 28'), const Offset(300, 0));
      await t.pumpAndSettle();
      // request for a1 still open: b2 must already be centred and swipeable
      expect(find.text('B2, 28'), findsOneWidget);
      final mid = t.getCenter(find.byType(SwipeScreen)).dx;
      expect(t.getCenter(find.text('B2, 28')).dx, closeTo(mid - 0, 140));
      await t.drag(find.text('B2, 28'), const Offset(-300, 0));
      await t.pumpAndSettle();
      expect(c.sent.map((e) => e.$1), ['a1', 'b2']);
      c.gate!.complete();
      await t.pumpAndSettle();
    });
  });

  group('buttons', () {
    for (final e in {
      'Pass': SwipeAction.dislike,
      'Super like': SwipeAction.superLike,
      'Like': SwipeAction.like,
    }.entries) {
      final icon = {
        'Pass': Icons.close_rounded,
        'Super like': Icons.star_outline_rounded,
        'Like': Icons.favorite_border_rounded,
      }[e.key]!;
      testWidgets('${e.key} button flies the card off and sends ${e.value.name}', (t) async {
        final c = _seed([_person('a1'), _person('b2')]);
        await _pump(t);
        await t.tap(find.byIcon(icon));
        await t.pumpAndSettle();
        expect(c.sent, [('a1', e.value)]);
        expect(find.text('B2, 28'), findsOneWidget);
      });
    }

    testWidgets('Rewind brings the card back after a swipe', (t) async {
      final c = _seed([_person('a1'), _person('b2')]);
      await _pump(t);
      await t.tap(find.byIcon(Icons.favorite_border_rounded));
      await t.pumpAndSettle();
      // the real submitSwipe records history; our stub does too:
      c.rewindHistory.add(RewindEntry(profile: _person('a1'), action: SwipeAction.like));
      await t.pump();
      await t.tap(find.byIcon(Icons.replay_rounded));
      await t.pumpAndSettle();
      expect(c.profiles.first.id, 'a1');
      expect(find.text('A1, 28'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('empty deck message + Refresh', (t) async {
      _seed(const []);
      await _pump(t);
      expect(find.text("You're all caught up"), findsOneWidget);
      expect(find.text('Check back soon for more people'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
    });

    testWidgets('empty deck: "See passed again" brings passed people back', (t) async {
      final c = _seed(const []);
      c.dislikedProfiles.assignAll([_person('p1'), _person('p2')]);
      c.likedProfiles.assignAll([_person('l1')]);
      await _pump(t);
      expect(find.text('See 2 passed again'), findsOneWidget);
      await t.tap(find.text('See 2 passed again'));
      await t.pumpAndSettle();
      expect(c.profiles.map((p) => p.id), ['p1', 'p2']);
      expect(find.text('P1, 28'), findsOneWidget); // card shown, liked stay out
      expect(c.dislikedProfiles, isEmpty);
      expect(c.likedProfiles.length, 1);
    });

    testWidgets('no passed people: no such button', (t) async {
      _seed(const []);
      await _pump(t);
      expect(find.textContaining('passed again'), findsNothing);
    });

    testWidgets('loading shows a skeleton, not the empty state', (t) async {
      final c = _seed(const []);
      c.isLoading.value = true;
      await _pump(t);
      expect(find.text("You're all caught up"), findsNothing);
    });

    testWidgets('last card swiped -> caught-up state, no crash', (t) async {
      final c = _seed([_person('a1')]);
      await _pump(t);
      await t.tap(find.byIcon(Icons.favorite_border_rounded));
      await t.pumpAndSettle();
      await t.pump(const Duration(milliseconds: 100));
      expect(c.sent.length, 1);
      expect(find.text("You're all caught up"), findsOneWidget);
    });
  });
}
