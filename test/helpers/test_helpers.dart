import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// ==================== Mock Classes ====================

/// Mock Firebase Auth
class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

/// Mock Firebase User
class MockFirebaseUser extends Mock implements firebase_auth.User {}

/// Mock User Credential
class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

/// Mock Firestore
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

/// Mock Collection Reference
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

/// Mock Document Reference
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

/// Mock Document Snapshot
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

/// Mock Query Snapshot
class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

/// Mock Query Document Snapshot
class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

/// Mock Query
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

/// Mock Firebase Storage
class MockFirebaseStorage extends Mock implements FirebaseStorage {}

/// Mock Storage Reference
class MockStorageReference extends Mock implements Reference {}

// ==================== Fake Classes ====================

/// Fake Firebase Auth Credential
class FakeAuthCredential extends Fake implements firebase_auth.AuthCredential {}

/// Fake Phone Auth Credential
class FakePhoneAuthCredential extends Fake
    implements firebase_auth.PhoneAuthCredential {}

// ==================== Test Widget Wrapper ====================

/// Wraps a widget with necessary providers for testing
Widget createTestWidget({
  required Widget child,
  List<Override>? overrides,
}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Creates a MaterialApp wrapper for widget testing
Widget createMaterialAppWrapper({
  required Widget child,
  ThemeData? theme,
  List<Override>? overrides,
}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      theme: theme ?? ThemeData.dark(),
      home: Scaffold(body: child),
    ),
  );
}

/// Creates a Riverpod provider container for testing
ProviderContainer createTestContainer({
  List<Override>? overrides,
}) {
  return ProviderContainer(
    overrides: overrides ?? [],
  );
}

// ==================== Test Data Generators ====================

/// Generates test user data
Map<String, dynamic> generateTestUserData({
  String? id,
  String? email,
  String? displayName,
  String? role,
}) {
  return {
    'id': id ?? 'test-user-id',
    'email': email ?? 'test@example.com',
    'displayName': displayName ?? 'Test User',
    'role': role ?? 'visitor',
    'phoneNumber': '+1234567890',
    'isVerified': true,
    'isActive': true,
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  };
}

/// Generates test event data
Map<String, dynamic> generateTestEventData({
  String? id,
  String? title,
  String? organizerId,
}) {
  final now = DateTime.now();
  return {
    'id': id ?? 'test-event-id',
    'title': title ?? 'Test Event',
    'description': 'Test event description',
    'organizerId': organizerId ?? 'test-organizer-id',
    'organizerName': 'Test Organizer',
    'location': 'Test Location',
    'category': 'Technology',
    'startDate': Timestamp.fromDate(now.add(const Duration(days: 7))),
    'endDate': Timestamp.fromDate(now.add(const Duration(days: 10))),
    'status': 'published',
    'boothCount': 50,
    'interestedCount': 100,
    'images': ['https://example.com/image.jpg'],
    'tags': ['tech', 'innovation'],
    'createdAt': Timestamp.now(),
  };
}

/// Generates test booth data
Map<String, dynamic> generateTestBoothData({
  String? id,
  String? eventId,
  String? type,
}) {
  return {
    'id': id ?? 'test-booth-id',
    'eventId': eventId ?? 'test-event-id',
    'boothNumber': 'A-101',
    'type': type ?? 'standard',
    'size': '3x3',
    'price': 500.0,
    'status': 'available',
    'position': {'x': 0, 'y': 0},
    'amenities': ['electricity', 'wifi'],
    'createdAt': Timestamp.now(),
  };
}

/// Generates test booking data
Map<String, dynamic> generateTestBookingData({
  String? id,
  String? eventId,
  String? boothId,
  String? exhibitorId,
}) {
  return {
    'id': id ?? 'test-booking-id',
    'eventId': eventId ?? 'test-event-id',
    'boothId': boothId ?? 'test-booth-id',
    'exhibitorId': exhibitorId ?? 'test-exhibitor-id',
    'exhibitorName': 'Test Exhibitor',
    'status': 'confirmed',
    'totalAmount': 500.0,
    'paymentStatus': 'paid',
    'createdAt': Timestamp.now(),
  };
}

/// Generates test supplier data
Map<String, dynamic> generateTestSupplierData({
  String? id,
  String? businessName,
}) {
  return {
    'id': id ?? 'test-supplier-id',
    'userId': 'test-user-id',
    'businessName': businessName ?? 'Test Supplier',
    'description': 'Test supplier description',
    'categories': ['catering', 'decoration'],
    'rating': 4.5,
    'reviewsCount': 25,
    'ordersCount': 100,
    'isVerified': true,
    'isActive': true,
    'createdAt': Timestamp.now(),
  };
}

/// Generates test notification data
Map<String, dynamic> generateTestNotificationData({
  String? id,
  String? userId,
  String? type,
}) {
  return {
    'id': id ?? 'test-notification-id',
    'userId': userId ?? 'test-user-id',
    'title': 'Test Notification',
    'body': 'This is a test notification',
    'type': type ?? 'systemAnnouncement',
    'isRead': false,
    'createdAt': Timestamp.now(),
  };
}

// ==================== Matchers ====================

/// Matcher for checking if a widget is visible
Matcher isVisible() => isA<Visibility>().having(
      (v) => v.visible,
      'visible',
      true,
    );

/// Matcher for checking loading state
Matcher hasLoadingIndicator() => findsOneWidget;

// ==================== Setup Functions ====================

/// Sets up common mocks before tests
void setupTestMocks() {
  registerFallbackValue(FakeAuthCredential());
  registerFallbackValue(FakePhoneAuthCredential());
}

/// Sets up Firestore mock with basic behavior
MockFirebaseFirestore setupMockFirestore() {
  final mockFirestore = MockFirebaseFirestore();
  final mockCollection = MockCollectionReference();

  when(() => mockFirestore.collection(any())).thenReturn(mockCollection);

  return mockFirestore;
}

/// Sets up Firebase Auth mock with basic behavior
MockFirebaseAuth setupMockFirebaseAuth({
  firebase_auth.User? currentUser,
}) {
  final mockAuth = MockFirebaseAuth();

  when(() => mockAuth.currentUser).thenReturn(currentUser);
  when(() => mockAuth.authStateChanges()).thenAnswer(
    (_) => Stream.value(currentUser),
  );

  return mockAuth;
}
