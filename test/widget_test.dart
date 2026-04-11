// Basic app widget test

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dating_app/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
