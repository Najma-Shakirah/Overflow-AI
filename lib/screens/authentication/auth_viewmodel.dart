// lib/viewmodels/auth_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'auth_repository.dart';
import 'user_model.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  UserModel? _user;

  // Getters
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // Initialize and listen to auth state changes
  void initialize() {
    _repository.authStateChanges.listen((user) {
      _user = user;
      if (user != null) {
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
      notifyListeners();
    });
  }

  // Sign in with email
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();

    final result = await _repository.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.success) {
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

  // Register with email
  Future<bool> registerWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();

    final result = await _repository.registerWithEmail(
      email: email,
      password: password,
    );

    if (result.success) {
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

  // Sign in anonymously
  Future<bool> signInAsGuest() async {
    _setLoading();

    final result = await _repository.signInAnonymously();

    if (result.success) {
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

  // Sign out
  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    _state = AuthState.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _user != null 
          ? AuthState.authenticated 
          : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  void _setLoading() {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
  }
}