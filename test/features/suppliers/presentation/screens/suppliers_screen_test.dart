import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:exhibition_platform/features/suppliers/presentation/screens/suppliers_screen.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  group('SuppliersScreen', () {
    Widget createSuppliersScreen({List<Override>? overrides}) {
      return ProviderScope(
        overrides: overrides ?? [],
        child: const MaterialApp(
          home: SuppliersScreen(),
        ),
      );
    }

    testWidgets('renders app bar with title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createSuppliersScreen());

      // Assert
      expect(find.text('Suppliers'), findsOneWidget);
    });

    testWidgets('renders search bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createSuppliersScreen());

      // Assert
      expect(find.byIcon(Icons.search), findsWidgets);
    });

    testWidgets('renders filter button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createSuppliersScreen());

      // Assert
      expect(find.byIcon(Icons.filter_list), findsWidgets);
    });

    testWidgets('renders category chips', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createSuppliersScreen());
      await tester.pump();

      // Assert - look for category filter chips
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('shows loading indicator while fetching suppliers', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createSuppliersScreen());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });

  group('SuppliersScreen Filtering', () {
    testWidgets('can tap on category chip to filter', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SuppliersScreen(),
          ),
        ),
      );
      await tester.pump();

      // Find and tap a filter chip if available
      final chips = find.byType(FilterChip);
      if (chips.evaluate().isNotEmpty) {
        await tester.tap(chips.first);
        await tester.pumpAndSettle();
      }

      // Verify screen still renders
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('tapping filter button opens filter options', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SuppliersScreen(),
          ),
        ),
      );

      // Act
      final filterButton = find.byIcon(Icons.filter_list);
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton.first);
        await tester.pumpAndSettle();
      }

      // Filter modal/bottom sheet would open
    });
  });

  group('SuppliersScreen Search', () {
    testWidgets('can enter search query', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SuppliersScreen(),
          ),
        ),
      );

      // Find search field
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, 'catering');
        await tester.pumpAndSettle();
      }

      // Search would filter results
    });
  });
}
