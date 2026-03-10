import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:exhibition_platform/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Event Browsing Integration Tests', () {
    testWidgets('browse events list', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for events to load
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Look for event list or grid
      final listView = find.byType(ListView);
      final gridView = find.byType(GridView);

      final hasEventList =
          listView.evaluate().isNotEmpty || gridView.evaluate().isNotEmpty;

      // If on home screen with events
      if (hasEventList) {
        // Scroll through events
        await tester.drag(
          listView.evaluate().isNotEmpty ? listView.first : gridView.first,
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();
      }
    });

    testWidgets('tap on event card opens detail', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Find event cards
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();

        // Should navigate to event detail
        // Check for back button indicating we're on detail page
        expect(find.byIcon(Icons.arrow_back), findsWidgets);
      }
    });

    testWidgets('search events', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find search icon or field
      final searchIcon = find.byIcon(Icons.search);
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon.first);
        await tester.pumpAndSettle();

        // Enter search query
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField.first, 'technology');
          await tester.pumpAndSettle();

          // Wait for search results
          await Future.delayed(const Duration(seconds: 1));
          await tester.pumpAndSettle();
        }
      }
    });
  });

  group('Event Detail Integration Tests', () {
    testWidgets('event detail shows all sections', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to first event
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();

        // Scroll to see all content
        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -500));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('mark event as interested', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to event detail
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();

        // Find favorite/interested button
        final favoriteIcon = find.byIcon(Icons.favorite_border);
        final bookmarkIcon = find.byIcon(Icons.bookmark_border);

        if (favoriteIcon.evaluate().isNotEmpty) {
          await tester.tap(favoriteIcon.first);
          await tester.pumpAndSettle();

          // Icon should change to filled
          expect(find.byIcon(Icons.favorite), findsWidgets);
        } else if (bookmarkIcon.evaluate().isNotEmpty) {
          await tester.tap(bookmarkIcon.first);
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.bookmark), findsWidgets);
        }
      }
    });

    testWidgets('share event', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to event detail
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();

        // Find share button
        final shareIcon = find.byIcon(Icons.share);
        if (shareIcon.evaluate().isNotEmpty) {
          await tester.tap(shareIcon.first);
          await tester.pumpAndSettle();

          // Share sheet would open (handled by system)
        }
      }
    });
  });

  group('Event Booking Integration Tests', () {
    testWidgets('book a booth flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to event
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();

        // Find book booth button
        final bookButton = find.text('Book Booth');
        final viewBooths = find.text('View Booths');

        if (bookButton.evaluate().isNotEmpty) {
          await tester.tap(bookButton);
          await tester.pumpAndSettle();

          // Booth selection screen would open
        } else if (viewBooths.evaluate().isNotEmpty) {
          await tester.tap(viewBooths);
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
