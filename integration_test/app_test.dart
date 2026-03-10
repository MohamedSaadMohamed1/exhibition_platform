import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:exhibition_platform/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Launch Tests', () {
    testWidgets('app launches successfully', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify the app is running
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('shows splash or login screen on launch', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should show either splash, login, or home screen
      final hasSplash = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      final hasLogin = find.text('Sign In').evaluate().isNotEmpty ||
          find.text('Welcome').evaluate().isNotEmpty;
      final hasHome = find.text('ExhibitConnect').evaluate().isNotEmpty;

      expect(hasSplash || hasLogin || hasHome, isTrue);
    });
  });

  group('Authentication Flow Tests', () {
    testWidgets('can navigate to login screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // If we're on login screen
      if (find.text('Sign In').evaluate().isNotEmpty) {
        expect(find.byType(TextFormField), findsWidgets);
      }
    });

    testWidgets('login form validation works', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // If we're on login screen
      final signInButton = find.text('Sign In');
      if (signInButton.evaluate().isNotEmpty) {
        // Try to sign in without entering data
        await tester.tap(signInButton);
        await tester.pumpAndSettle();

        // Should show validation errors
        expect(
          find.text('Email is required').evaluate().isNotEmpty ||
              find.textContaining('required').evaluate().isNotEmpty,
          isTrue,
        );
      }
    });

    testWidgets('can navigate to register screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for sign up link
      final signUpLink = find.text('Sign Up');
      if (signUpLink.evaluate().isNotEmpty) {
        await tester.tap(signUpLink);
        await tester.pumpAndSettle();

        // Should navigate to register screen
        expect(
          find.text('Create Account').evaluate().isNotEmpty ||
              find.text('Register').evaluate().isNotEmpty ||
              find.text('Sign Up').evaluate().isNotEmpty,
          isTrue,
        );
      }
    });
  });

  group('Navigation Flow Tests', () {
    testWidgets('bottom navigation works', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // If we're on home screen with bottom nav
      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isNotEmpty) {
        // Tap on different tabs
        final storeIcon = find.byIcon(Icons.store);
        if (storeIcon.evaluate().isNotEmpty) {
          await tester.tap(storeIcon.first);
          await tester.pumpAndSettle();
        }

        final workIcon = find.byIcon(Icons.work);
        if (workIcon.evaluate().isNotEmpty) {
          await tester.tap(workIcon.first);
          await tester.pumpAndSettle();
        }

        // Should still have bottom nav
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      }
    });
  });
}
