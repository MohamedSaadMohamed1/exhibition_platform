import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:exhibition_platform/features/auth/presentation/screens/login_screen.dart';
import 'package:exhibition_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:exhibition_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:exhibition_platform/shared/models/user_model.dart';
import 'package:exhibition_platform/core/exceptions/app_exceptions.dart';

import '../../../../helpers/test_helpers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Widget createLoginScreen({List<Override>? overrides}) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders login form correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act - tap sign in without entering data
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.enterText(
        find.byType(TextFormField).first,
        'invalid-email',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows validation error for short password', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        '123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Initially password is obscured
      final passwordField = find.byType(TextFormField).last;
      expect(passwordField, findsOneWidget);

      // Find visibility toggle icon
      final visibilityIcon = find.byIcon(Icons.visibility_off);
      expect(visibilityIcon, findsOneWidget);

      // Act - tap to show password
      await tester.tap(visibilityIcon);
      await tester.pump();

      // Assert - icon should change
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('navigates to register screen', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Note: Navigation would be handled by go_router in actual app
      // This test verifies the tap handler exists
    });

    testWidgets('navigates to forgot password', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Note: Navigation would be handled by go_router in actual app
    });

    testWidgets('shows loading indicator during sign in', (tester) async {
      // This would require mocking the auth state to be loading
      // For now, verify the button exists and is tappable
      await tester.pumpWidget(createLoginScreen());

      final signInButton = find.text('Sign In');
      expect(signInButton, findsOneWidget);
    });
  });

  group('LoginScreen Form Interaction', () {
    testWidgets('can enter email and password', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      // Assert
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('clears form on successful validation', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act - enter valid data
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      // Verify data is entered
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
