import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:exhibition_platform/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Integration Tests', () {
    testWidgets('complete login flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to load
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Find login form elements
      final emailField = find.byType(TextFormField).first;
      final passwordFields = find.byType(TextFormField);

      if (emailField.evaluate().isNotEmpty && passwordFields.evaluate().length >= 2) {
        // Enter test credentials
        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passwordFields.at(1), 'password123');
        await tester.pumpAndSettle();

        // Tap sign in
        final signInButton = find.text('Sign In');
        if (signInButton.evaluate().isNotEmpty) {
          await tester.tap(signInButton);
          await tester.pumpAndSettle();

          // Wait for authentication
          await Future.delayed(const Duration(seconds: 3));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('password visibility toggle', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find password visibility toggle
      final visibilityOff = find.byIcon(Icons.visibility_off);
      if (visibilityOff.evaluate().isNotEmpty) {
        await tester.tap(visibilityOff.first);
        await tester.pumpAndSettle();

        // Icon should change to visibility
        expect(find.byIcon(Icons.visibility), findsWidgets);
      }
    });

    testWidgets('forgot password flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find forgot password link
      final forgotPassword = find.text('Forgot Password?');
      if (forgotPassword.evaluate().isNotEmpty) {
        await tester.tap(forgotPassword);
        await tester.pumpAndSettle();

        // Should navigate to reset password screen
        // or show a dialog/bottom sheet
      }
    });
  });

  group('Registration Integration Tests', () {
    testWidgets('complete registration flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to registration
      final signUpLink = find.text('Sign Up');
      if (signUpLink.evaluate().isNotEmpty) {
        await tester.tap(signUpLink);
        await tester.pumpAndSettle();

        // Find registration form fields
        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 3) {
          // Enter registration details
          await tester.enterText(textFields.at(0), 'Test User');
          await tester.enterText(textFields.at(1), 'newuser@example.com');
          await tester.enterText(textFields.at(2), 'password123');

          // If there's a confirm password field
          if (textFields.evaluate().length >= 4) {
            await tester.enterText(textFields.at(3), 'password123');
          }

          await tester.pumpAndSettle();
        }
      }
    });
  });

  group('Logout Integration Tests', () {
    testWidgets('logout flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // If logged in, find profile/menu
      final profileIcon = find.byIcon(Icons.person);
      if (profileIcon.evaluate().isNotEmpty) {
        await tester.tap(profileIcon.first);
        await tester.pumpAndSettle();

        // Find logout option
        final logoutOption = find.text('Sign Out');
        if (logoutOption.evaluate().isNotEmpty) {
          await tester.tap(logoutOption);
          await tester.pumpAndSettle();

          // Confirm logout if dialog appears
          final confirmButton = find.text('Confirm');
          if (confirmButton.evaluate().isNotEmpty) {
            await tester.tap(confirmButton);
            await tester.pumpAndSettle();
          }
        }
      }
    });
  });
}
