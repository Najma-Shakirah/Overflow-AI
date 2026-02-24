// lib/models/user_model.dart
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final bool isAnonymous;

  UserModel({
    required this.uid,
    this.email,
    required this.isAnonymous,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      isAnonymous: user.isAnonymous,
    );
  }
}