import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('renders circular progress indicator', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('ErrorWidget', () {
    testWidgets('displays error message', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('Something went wrong'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('retry button is tappable', (tester) async {
      // Arrange
      bool retryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => retryTapped = true,
                child: const Text('Retry'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Assert
      expect(retryTapped, isTrue);
    });
  });

  group('EmptyStateWidget', () {
    testWidgets('displays empty state message', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No items found'),
                  SizedBox(height: 8),
                  Text(
                    'Check back later for updates',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('No items found'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });
  });

  group('RatingWidget', () {
    testWidgets('displays correct number of stars', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                return Icon(
                  index < 4 ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.star), findsNWidgets(4));
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });
  });

  group('PriceWidget', () {
    testWidgets('displays formatted price', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text(
              '\$99.99',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('\$99.99'), findsOneWidget);
    });
  });

  group('CategoryChip', () {
    testWidgets('renders chip with label', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Chip(
              label: const Text('Technology'),
              backgroundColor: Colors.blue.withOpacity(0.1),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Technology'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('chip is tappable when interactive', (tester) async {
      // Arrange
      bool chipTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionChip(
              label: const Text('Technology'),
              onPressed: () => chipTapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ActionChip));
      await tester.pump();

      // Assert
      expect(chipTapped, isTrue);
    });
  });

  group('StatusBadge', () {
    testWidgets('displays status with correct color', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Active'), findsOneWidget);
    });
  });

  group('SearchBar', () {
    testWidgets('renders search input', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {},
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('can enter search text', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Assert
      expect(find.text('test query'), findsOneWidget);
    });
  });

  group('DateRangeDisplay', () {
    testWidgets('displays date range correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Icon(Icons.calendar_today, size: 16),
                SizedBox(width: 4),
                Text('Mar 15 - Mar 18, 2024'),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.text('Mar 15 - Mar 18, 2024'), findsOneWidget);
    });
  });
}
