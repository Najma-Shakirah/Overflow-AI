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

  void initialize() {
    _repository.authStateChanges.listen((user) {
      _user = user;
      _state = user != null ? AuthState.authenticated : AuthState.unauthenticated;
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
      password: password
    );
    
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

  // 🔥 THE FIX: Now accepts the full profileData from your 3-step form
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required UserModel profileData, 
  }) async {
    _setLoading();
    
    // 1. Create the base Auth account
    final result = await _repository.registerWithEmail(
      email: email, 
      password: password
    );
    
    if (result.success && result.user != null) {
      // 2. Account created! Now append the generated UID to the form data
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

  // Steps 2 & 3 — saves full user profile to Firestore
  Future<bool> saveUserProfile(UserModel profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .set(profile.toFirestore(), SetOptions(merge: true));

      _user = profile;
      _state = AuthState.authenticated; // Update state to authenticated
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('saveUserProfile error: $e');
      _errorMessage = 'Failed to save profile to database. Please check permissions.';
      _state = AuthState.error; // Revert to error state if DB write fails
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