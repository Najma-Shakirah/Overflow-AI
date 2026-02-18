// lib/repositories/profile_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_model.dart';

class ProfileRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ProfileRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Get current user profile
  Future<ProfileModel?> getCurrentUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Get additional profile data from Firestore (if you have it)
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        return ProfileModel(
          uid: user.uid,
          name: data['name'] ?? user.displayName ?? 'User',
          email: user.email ?? '',
          photoUrl: data['photoUrl'] ?? user.photoURL,
          alertsReceived: data['alertsReceived'] ?? 0,
          areasMonitored: data['areasMonitored'] ?? 0,
        );
      }

      // If no Firestore data, return basic profile from Firebase Auth
      return ProfileModel.fromUserModel(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName,
        photoUrl: user.photoURL,
      );
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Update Firebase Auth profile
      if (name != null || photoUrl != null) {
        await user.updateDisplayName(name);
        await user.updatePhotoURL(photoUrl);
      }

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'name': name ?? user.displayName,
        'photoUrl': photoUrl ?? user.photoURL,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}