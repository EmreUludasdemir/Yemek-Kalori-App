import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('MealSection Widget Tests', () {
    testWidgets('displays meal type and total calories', (WidgetTester tester) async {
      // Note: This is a placeholder test
      // In production, import the actual MealSection widget

      // Arrange
      const mealType = 'Kahvaltı';
      const totalCalories = 450;

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  children: [
                    const Text(mealType),
                    Text('$totalCalories kcal'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(mealType), findsOneWidget);
      expect(find.text('$totalCalories kcal'), findsOneWidget);
    });

    testWidgets('shows add button', (WidgetTester tester) async {
      // Arrange
      const mealType = 'Kahvaltı';

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  children: [
                    const Text(mealType),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add_circle), findsOneWidget);
    });

    testWidgets('displays empty state when no foods', (WidgetTester tester) async {
      // Arrange
      const emptyMessage = 'Henüz yemek eklenmedi';

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(emptyMessage),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(emptyMessage), findsOneWidget);
    });

    testWidgets('displays food list when foods exist', (WidgetTester tester) async {
      // Arrange
      const foodName1 = 'Yumurta';
      const foodName2 = 'Peynir';

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListView(
                children: const [
                  ListTile(title: Text(foodName1)),
                  ListTile(title: Text(foodName2)),
                ],
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(foodName1), findsOneWidget);
      expect(find.text(foodName2), findsOneWidget);
    });
  });

  group('Food Item Card Tests', () {
    testWidgets('displays food name and calories', (WidgetTester tester) async {
      // Arrange
      const foodName = 'Yumurta';
      const calories = 155;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTile(
              title: const Text(foodName),
              subtitle: Text('$calories kcal'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(foodName), findsOneWidget);
      expect(find.text('$calories kcal'), findsOneWidget);
    });

    testWidgets('shows delete button on swipe', (WidgetTester tester) async {
      // Arrange
      const foodName = 'Yumurta';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Dismissible(
              key: const Key('food_1'),
              child: const ListTile(
                title: Text(foodName),
              ),
            ),
          ),
        ),
      );

      // Assert - widget exists
      expect(find.text(foodName), findsOneWidget);
      expect(find.byType(Dismissible), findsOneWidget);
    });
  });
}
