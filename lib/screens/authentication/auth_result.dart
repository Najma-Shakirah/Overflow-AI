// lib/models/auth_result.dart
import 'user_model.dart';

class AuthResult {
  final bool success;
  final String? error;
  final UserModel? user;

  AuthResult({
    required this.success,
    this.error,
    this.user,
  });

  factory AuthResult.success(UserModel user) {
    return AuthResult(success: true, user: user);
  }

  factory AuthResult.failure(String error) {
    return AuthResult(success: false, error: error);
  }
}