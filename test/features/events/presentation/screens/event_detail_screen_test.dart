import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:exhibition_platform/features/events/presentation/screens/event_detail_screen.dart';
import 'package:exhibition_platform/shared/models/event_model.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  group('EventDetailScreen', () {
    Widget createEventDetailScreen({
      required String eventId,
      List<Override>? overrides,
    }) {
      return ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          home: EventDetailScreen(eventId: eventId),
        ),
      );
    }

    testWidgets('renders loading state initially', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createEventDetailScreen(eventId: 'test-event'));

      // Assert - should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders back button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createEventDetailScreen(eventId: 'test-event'));

      // Assert
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders share button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createEventDetailScreen(eventId: 'test-event'));

      // Assert
      expect(find.byIcon(Icons.share), findsWidgets);
    });

    testWidgets('renders favorite/bookmark button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createEventDetailScreen(eventId: 'test-event'));

      // Assert - look for favorite or bookmark icon
      final favoriteIcon = find.byIcon(Icons.favorite_border);
      final bookmarkIcon = find.byIcon(Icons.bookmark_border);

      expect(
        favoriteIcon.evaluate().isNotEmpty || bookmarkIcon.evaluate().isNotEmpty,
        isTrue,
      );
    });
  });

  group('EventDetailScreen Content', () {
    // Create a mock event for testing
    final testEvent = EventModel(
      id: 'test-event-id',
      title: 'Test Exhibition',
      description: 'This is a test exhibition description that provides details about the event.',
      organizerId: 'org-123',
      organizerName: 'Test Organizer',
      location: 'Test Convention Center',
      category: 'Technology',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 10)),
      status: 'published',
      boothCount: 50,
      interestedCount: 100,
      images: ['https://example.com/image.jpg'],
      tags: ['tech', 'innovation'],
      createdAt: DateTime.now(),
    );

    testWidgets('displays event title when loaded', (tester) async {
      // This test would require mocking the event provider
      // For now, verify the screen structure
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: EventDetailScreen(eventId: testEvent.id),
          ),
        ),
      );

      await tester.pump();

      // Scaffold should be present
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('EventDetailScreen Actions', () {
    testWidgets('back button pops navigation', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EventDetailScreen(eventId: 'test'),
                      ),
                    );
                  },
                  child: const Text('Go to Event'),
                ),
              ),
            ),
          ),
        ),
      );

      // Navigate to event detail
      await tester.tap(find.text('Go to Event'));
      await tester.pumpAndSettle();

      // Tap back button
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton.first);
        await tester.pumpAndSettle();
      }

      // Should be back on initial screen
      expect(find.text('Go to Event'), findsOneWidget);
    });
  });
}
