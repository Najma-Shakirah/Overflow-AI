// lib/viewmodels/profile_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'profile_repository.dart';
import 'profile_model.dart';

enum ProfileState { initial, loading, loaded, error }

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileViewModel({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  ProfileState _state = ProfileState.initial;
  ProfileModel? _profile;
  String? _errorMessage;

  // Getters
  ProfileState get state => _state;
  ProfileModel? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ProfileState.loading;

  // Load user profile
  Future<void> loadProfile() async {
    _state = ProfileState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.getCurrentUserProfile();
      
      if (_profile != null) {
        _state = ProfileState.loaded;
      } else {
        _state = ProfileState.error;
        _errorMessage = 'Failed to load profile';
      }
    } catch (e) {
      _state = ProfileState.error;
      _errorMessage = 'Error loading profile: $e';
    }
    
    notifyListeners();
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? photoUrl,
  }) async {
    _state = ProfileState.loading;
    notifyListeners();

    final success = await _repository.updateProfile(
      name: name,
      photoUrl: photoUrl,
    );

    if (success) {
      // Reload profile to get updated data
      await loadProfile();
      return true;
    } else {
      _state = ProfileState.error;
      _errorMessage = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _repository.signOut();
    _profile = null;
    _state = ProfileState.initial;
    notifyListeners();
  }
}