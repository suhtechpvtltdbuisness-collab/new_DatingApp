import 'package:dating_app/screens/like/liked_you_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Liked You screen builds without throwing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LikedYouScreen())),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.text('Liked You'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
