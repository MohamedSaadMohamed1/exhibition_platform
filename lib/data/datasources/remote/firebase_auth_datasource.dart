import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/error/exceptions.dart';

/// Firebase Auth Data Source Interface
abstract class FirebaseAuthDataSource {
  /// Get current Firebase user
  User? get currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges;

  /// Verify phone number and send OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
    int? forceResendingToken,
  });

  /// Sign in with phone auth credential
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential);

  /// Create phone auth credential from verification ID and SMS code
  PhoneAuthCredential createCredential({
    required String verificationId,
    required String smsCode,
  });

  /// Sign out current user
  Future<void> signOut();

  /// Delete current user account
  Future<void> deleteAccount();

  /// Reload current user data
  Future<void> reloadUser();
}

/// Firebase Auth Data Source Implementation
class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _auth;

  FirebaseAuthDataSourceImpl(this._auth);

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        forceResendingToken: forceResendingToken,
        timeout: const Duration(seconds: 60),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.message ?? 'Failed to verify phone number',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw AuthException(
        message: 'Failed to verify phone number: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<UserCredential> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    try {
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.message ?? 'Sign in failed',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw AuthException(
        message: 'Sign in failed: $e',
        originalException: e,
      );
    }
  }

  @override
  PhoneAuthCredential createCredential({
    required String verificationId,
    required String smsCode,
  }) {
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException(
        message: 'Sign out failed: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.message ?? 'Failed to delete account',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw AuthException(
        message: 'Failed to delete account: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw AuthException(
        message: 'Failed to reload user: $e',
        originalException: e,
      );
    }
  }
}
