import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yemek_kalori_app/presentation/widgets/common/empty_state.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('displays icon and message', (WidgetTester tester) async {
      // Arrange
      const testMessage = 'No data found';
      const testIcon = Icons.search;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: testIcon,
              message: testMessage,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(testIcon), findsOneWidget);
      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('shows action button when provided', (WidgetTester tester) async {
      // Arrange
      const testMessage = 'No data found';
      const testIcon = Icons.search;
      const buttonText = 'Add Item';
      var buttonPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: testIcon,
              message: testMessage,
              actionLabel: buttonText,
              onAction: () => buttonPressed = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(buttonText), findsOneWidget);

      // Tap button
      await tester.tap(find.text(buttonText));
      await tester.pump();

      expect(buttonPressed, true);
    });

    testWidgets('hides action button when not provided', (WidgetTester tester) async {
      // Arrange
      const testMessage = 'No data found';
      const testIcon = Icons.search;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: testIcon,
              message: testMessage,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('displays subtitle when provided', (WidgetTester tester) async {
      // Arrange
      const testMessage = 'No data found';
      const testSubtitle = 'Try adding some items';
      const testIcon = Icons.search;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: testIcon,
              message: testMessage,
              subtitle: testSubtitle,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testMessage), findsOneWidget);
      expect(find.text(testSubtitle), findsOneWidget);
    });
  });
}
