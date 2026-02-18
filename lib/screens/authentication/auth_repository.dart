// lib/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'user_model.dart';
import 'auth_result.dart';

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;
  // Stream of auth state changes
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }

  // Get current user
  UserModel? get currentUser {
    final user = _auth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (credential.user != null) {
        return AuthResult.success(
          UserModel.fromFirebaseUser(credential.user!),
        );
      }
      return AuthResult.failure('Sign in failed');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  // Register with email and password
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (credential.user != null) {
        return AuthResult.success(
          UserModel.fromFirebaseUser(credential.user!),
        );
      }
      return AuthResult.failure('Registration failed');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  // Sign in anonymously
  Future<AuthResult> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      
      if (credential.user != null) {
        return AuthResult.success(
          UserModel.fromFirebaseUser(credential.user!),
        );
      }
      return AuthResult.failure('Anonymous sign in failed');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}