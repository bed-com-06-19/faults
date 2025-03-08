// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:faults/main.dart'; // Ensure this matches your actual package name

void main() {
  testWidgets('Landing page displays app name and navigates after 5 seconds', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const FaultDetectionApp());

    // Verify that the landing page contains the app name
    expect(find.text('Fault Detection System'), findsOneWidget);

    // Wait for 5 seconds (simulate the timer)
    await tester.pump(const Duration(seconds: 5));

    // Verify that the Code Entry Page appears
    expect(find.text('Enter Code'), findsOneWidget);
  });
}
