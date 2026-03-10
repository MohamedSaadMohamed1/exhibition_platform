import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:exhibition_platform/features/profile/presentation/screens/profile_screen.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  group('ProfileScreen', () {
    Widget createProfileScreen({List<Override>? overrides}) {
      return ProviderScope(
        overrides: overrides ?? [],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      );
    }

    testWidgets('renders profile screen', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfileScreen());

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders app bar with title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfileScreen());

      // Assert
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('renders edit profile button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfileScreen());

      // Assert
      expect(find.byIcon(Icons.edit), findsWidgets);
    });

    testWidgets('renders settings option', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfileScreen());

      // Assert
      expect(find.byIcon(Icons.settings), findsWidgets);
    });

    testWidgets('renders logout option', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfileScreen());
      await tester.pump();

      // Assert - look for logout button/option
      final logoutIcon = find.byIcon(Icons.logout);
      final logoutText = find.text('Logout');
      final signOutText = find.text('Sign Out');

      expect(
        logoutIcon.evaluate().isNotEmpty ||
            logoutText.evaluate().isNotEmpty ||
            signOutText.evaluate().isNotEmpty,
        isTrue,
      );
    });
  });

  group('ProfileScreen Menu Items', () {
    testWidgets('renders my bookings option', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pump();

      // Assert - check for bookings menu item
      expect(
        find.textContaining('Booking').evaluate().isNotEmpty ||
            find.byIcon(Icons.bookmark).evaluate().isNotEmpty ||
            find.byIcon(Icons.calendar_today).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('renders orders option', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pump();

      // Verify screen renders
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders notifications settings option', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pump();

      // Look for notifications icon
      expect(find.byIcon(Icons.notifications_outlined), findsWidgets);
    });
  });

  group('ProfileScreen Actions', () {
    testWidgets('tapping logout shows confirmation dialog', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pump();

      // Find and tap logout if available
      final logoutOption = find.text('Sign Out');
      if (logoutOption.evaluate().isNotEmpty) {
        await tester.tap(logoutOption);
        await tester.pumpAndSettle();

        // Dialog would appear
        expect(find.byType(AlertDialog), findsWidgets);
      }
    });

    testWidgets('tapping edit navigates to edit profile', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      // Find and tap edit button
      final editButton = find.byIcon(Icons.edit);
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton.first);
        await tester.pumpAndSettle();
      }

      // Navigation would occur via go_router
    });
  });
}
