import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:daytistics/shared/utils/alert.dart';

void main() {
  testWidgets('showErrorAlert displays the correct message', (tester) async {
    const String testMessage = 'This is a test error message';

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showErrorAlert(context, testMessage);
              },
              child: const Text('Show Alert'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show Alert'));
    await tester.pumpAndSettle();

    expect(find.text('An error occurred '), findsOneWidget);
    expect(find.text(testMessage), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('showErrorAlert dismisses when OK is pressed', (tester) async {
    const String testMessage = 'This is a test error message';

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showErrorAlert(context, testMessage);
              },
              child: const Text('Show Alert'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show Alert'));
    await tester.pumpAndSettle();

    expect(find.text('An error occurred '), findsOneWidget);
    expect(find.text(testMessage), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('An error occurred '), findsNothing);
    expect(find.text(testMessage), findsNothing);
    expect(find.text('OK'), findsNothing);
  });
}
