// lib/viewmodels/auth_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_repository.dart';
import 'user_model.dart';

export 'user_model.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  UserModel? _user;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Returns the user's display name for UI greetings.
  /// Priority: Firestore fullName → 'Guest' (anonymous) → 'there' (fallback)
  String get displayName {
    if (_user == null) return 'there';
    if (_user!.isAnonymous) return 'Guest';
    return _user!.fullName ?? 'there';
  }

  void initialize() {
    _repository.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
        _state = AuthState.unauthenticated;
        notifyListeners();
        return;
      }

      // Anonymous users have no Firestore profile
      if (firebaseUser.isAnonymous) {
        _user = firebaseUser;
        _state = AuthState.authenticated;
        notifyListeners();
        return;
      }

      // Registered user — hydrate with Firestore data so fullName is available
      try {
        final doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (doc.exists) {
          _user = UserModel.fromFirestore(doc.data()!, firebaseUser.uid);
        } else {
          _user = firebaseUser; // fallback: Firestore doc not yet written
        }
      } catch (_) {
        _user = firebaseUser; // network error — graceful degradation
      }

      _state = AuthState.authenticated;
      notifyListeners();
    });
  }

  void _setLoading() {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();
    final result = await _repository.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.success && result.user != null) {
      // Hydrate from Firestore so fullName is immediately available
      try {
        final doc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();
        _user = doc.exists
            ? UserModel.fromFirestore(doc.data()!, result.user!.uid)
            : result.user;
      } catch (_) {
        _user = result.user;
      }
      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _state = AuthState.error;
      _errorMessage = result.error;
      notifyListeners();
      return false;
    }
  }

  // Accepts the full profileData from the 3-step registration form
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required UserModel profileData,
  }) async {
    _setLoading();

    // 1. Create the base Auth account
    final result = await _repository.registerWithEmail(
      email: email,
      password: password,
    );

    if (result.success && result.user != null) {
      // 2. Append the generated UID to the form data
      final fullProfile = profileData.copyWith(uid: result.user!.uid);

      // 3. Save the full profile to Firestore
      return await saveUserProfile(fullProfile);
    } else {
      _state = AuthState.error;
      _errorMessage = result.error;
      notifyListeners();
      return false;
    }
  }

  // Saves full user profile to Firestore
  Future<bool> saveUserProfile(UserModel profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .set(profile.toFirestore(), SetOptions(merge: true));

      _user = profile;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('saveUserProfile error: $e');
      _errorMessage =
          'Failed to save profile to database. Please check permissions.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInAsGuest() async {
    _setLoading();
    final result = await _repository.signInAnonymously();

    if (result.success && result.user != null) {
      _user = result.user;
      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _state = AuthState.error;
      _errorMessage = result.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    _state = AuthState.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
}