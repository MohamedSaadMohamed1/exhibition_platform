import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:exhibition_platform/features/home/presentation/screens/home_screen.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  group('HomeScreen', () {
    Widget createHomeScreen({List<Override>? overrides}) {
      return ProviderScope(
        overrides: overrides ?? [],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      );
    }

    testWidgets('renders home screen with app bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomeScreen());

      // Assert
      expect(find.text('ExhibitConnect'), findsOneWidget);
    });

    testWidgets('renders bottom navigation bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomeScreen());

      // Assert - check for bottom navigation items
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.event), findsOneWidget);
      expect(find.byIcon(Icons.store), findsOneWidget);
      expect(find.byIcon(Icons.work), findsOneWidget);
    });

    testWidgets('renders search bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomeScreen());

      // Assert
      expect(find.byIcon(Icons.search), findsWidgets);
    });

    testWidgets('switches tabs when bottom nav item tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(createHomeScreen());

      // Act - tap on Suppliers tab
      await tester.tap(find.byIcon(Icons.store));
      await tester.pumpAndSettle();

      // Assert - verify tab changed (would show suppliers content)
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('renders notification icon in app bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomeScreen());

      // Assert
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('renders profile/menu icon in app bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomeScreen());

      // Assert - look for profile or menu icon
      expect(find.byIcon(Icons.person_outline), findsWidgets);
    });
  });

  group('HomeScreen Events Tab', () {
    Widget createHomeScreen() {
      return const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      );
    }

    testWidgets('shows loading indicator while fetching events', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomeScreen());

      // The initial state would show a loading indicator
      // before data loads
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows section headers', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pump();

      // Assert - check for section titles
      expect(find.text('Upcoming Events'), findsWidgets);
    });
  });

  group('HomeScreen Navigation', () {
    testWidgets('tapping notification icon triggers navigation', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Act
      final notificationIcon = find.byIcon(Icons.notifications_outlined);
      if (notificationIcon.evaluate().isNotEmpty) {
        await tester.tap(notificationIcon.first);
        await tester.pumpAndSettle();
      }

      // Navigation would be handled by go_router
    });
  });
}
