import 'package:flutter_test/flutter_test.dart';
import 'package:faults/main.dart'; // Ensure this matches your actual package name

void main() {
  testWidgets('Landing page displays app name and navigates after 5 seconds', (WidgetTester tester) async {
    // Build the app with the dark mode set to false (you can change this to true if needed)
    await tester.pumpWidget(const FaultDetectionApp(false)); // Providing 'false' for dark mode

    // Verify that the landing page contains the app name
    expect(find.text('Fault Detection System'), findsOneWidget);

    // Wait for 5 seconds (simulate the timer)
    await tester.pump(const Duration(seconds: 5));

    // Verify that the Code Entry Page appears (replace this with your actual page name)
    expect(find.text('Enter Code'), findsOneWidget);
  });
}
