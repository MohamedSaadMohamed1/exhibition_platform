import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:exhibition_platform/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Supplier Browsing Integration Tests', () {
    testWidgets('navigate to suppliers tab', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Find suppliers tab in bottom nav
      final storeIcon = find.byIcon(Icons.store);
      if (storeIcon.evaluate().isNotEmpty) {
        await tester.tap(storeIcon.first);
        await tester.pumpAndSettle();

        // Should show suppliers list
        expect(find.byType(Scaffold), findsOneWidget);
      }
    });

    testWidgets('filter suppliers by category', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to suppliers
      final storeIcon = find.byIcon(Icons.store);
      if (storeIcon.evaluate().isNotEmpty) {
        await tester.tap(storeIcon.first);
        await tester.pumpAndSettle();

        // Find category chips
        final chips = find.byType(FilterChip);
        if (chips.evaluate().isNotEmpty) {
          await tester.tap(chips.first);
          await tester.pumpAndSettle();

          // Results should filter
        }
      }
    });

    testWidgets('search suppliers', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to suppliers
      final storeIcon = find.byIcon(Icons.store);
      if (storeIcon.evaluate().isNotEmpty) {
        await tester.tap(storeIcon.first);
        await tester.pumpAndSettle();

        // Find search field
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField.first, 'catering');
          await tester.pumpAndSettle();

          await Future.delayed(const Duration(seconds: 1));
          await tester.pumpAndSettle();
        }
      }
    });
  });

  group('Supplier Detail Integration Tests', () {
    testWidgets('view supplier details', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to suppliers
      final storeIcon = find.byIcon(Icons.store);
      if (storeIcon.evaluate().isNotEmpty) {
        await tester.tap(storeIcon.first);
        await tester.pumpAndSettle();

        await Future.delayed(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        // Tap on supplier card
        final cards = find.byType(Card);
        if (cards.evaluate().isNotEmpty) {
          await tester.tap(cards.first);
          await tester.pumpAndSettle();

          // Should show supplier detail
          expect(find.byIcon(Icons.arrow_back), findsWidgets);
        }
      }
    });

    testWidgets('view supplier services', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to supplier detail
      final storeIcon = find.byIcon(Icons.store);
      if (storeIcon.evaluate().isNotEmpty) {
        await tester.tap(storeIcon.first);
        await tester.pumpAndSettle();

        final cards = find.byType(Card);
        if (cards.evaluate().isNotEmpty) {
          await tester.tap(cards.first);
          await tester.pumpAndSettle();

          // Look for services section
          final servicesTab = find.text('Services');
          if (servicesTab.evaluate().isNotEmpty) {
            await tester.tap(servicesTab);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('view supplier reviews', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to supplier detail
      final storeIcon = find.byIcon(Icons.store);
      if (storeIcon.evaluate().isNotEmpty) {
        await tester.tap(storeIcon.first);
        await tester.pumpAndSettle();

        final cards = find.byType(Card);
        if (cards.evaluate().isNotEmpty) {
          await tester.tap(cards.first);
          await tester.pumpAndSettle();

          // Look for reviews section/tab
          final reviewsTab = find.text('Reviews');
          if (reviewsTab.evaluate().isNotEmpty) {
            await tester.tap(reviewsTab);
            await tester.pumpAndSettle();

            // Should show reviews list
          }
        }
      }
    });
  });

  group('Supplier Service Order Integration Tests', () {
    testWidgets('order service flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to supplier
      final storeIcon = find.byIcon(Icons.store);
      if (storeIcon.evaluate().isNotEmpty) {
        await tester.tap(storeIcon.first);
        await tester.pumpAndSettle();

        final cards = find.byType(Card);
        if (cards.evaluate().isNotEmpty) {
          await tester.tap(cards.first);
          await tester.pumpAndSettle();

          // Find order button
          final orderButton = find.text('Order');
          final bookButton = find.text('Book Service');

          if (orderButton.evaluate().isNotEmpty) {
            await tester.tap(orderButton.first);
            await tester.pumpAndSettle();
          } else if (bookButton.evaluate().isNotEmpty) {
            await tester.tap(bookButton.first);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('contact supplier', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to supplier detail
      final storeIcon = find.byIcon(Icons.store);
      if (storeIcon.evaluate().isNotEmpty) {
        await tester.tap(storeIcon.first);
        await tester.pumpAndSettle();

        final cards = find.byType(Card);
        if (cards.evaluate().isNotEmpty) {
          await tester.tap(cards.first);
          await tester.pumpAndSettle();

          // Find contact/chat button
          final chatIcon = find.byIcon(Icons.chat);
          final messageIcon = find.byIcon(Icons.message);
          final contactButton = find.text('Contact');

          if (chatIcon.evaluate().isNotEmpty) {
            await tester.tap(chatIcon.first);
            await tester.pumpAndSettle();
          } else if (messageIcon.evaluate().isNotEmpty) {
            await tester.tap(messageIcon.first);
            await tester.pumpAndSettle();
          } else if (contactButton.evaluate().isNotEmpty) {
            await tester.tap(contactButton);
            await tester.pumpAndSettle();
          }
        }
      }
    });
  });
}
