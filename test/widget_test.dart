// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coded_gp/main.dart';

void main() {
  testWidgets('Initial app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Add your test assertions here
    // For example, you might want to verify that the OnBoardingScreen is present
    // or test specific elements of your app's initial state
  });
}
