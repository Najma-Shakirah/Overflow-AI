// lib/models/user_model.dart
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final bool isAnonymous;

  // Step 1 — Account
  final String? fullName;
  final String? phoneNumber;

  // Step 2 — Location
  final String? state;
  final String? district;
  final String? homeAddress;

  // Step 3 — Emergency & Preferences
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String alertThreshold;       // 'all', 'warning', 'critical'
  final bool smsAlertsEnabled;
  final bool pushAlertsEnabled;

  // Metadata
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    this.email,
    required this.isAnonymous,
    this.fullName,
    this.phoneNumber,
    this.state,
    this.district,
    this.homeAddress,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.alertThreshold = 'all',
    this.smsAlertsEnabled = true,
    this.pushAlertsEnabled = true,
    this.createdAt,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      isAnonymous: user.isAnonymous,
      createdAt: DateTime.now(),
    );
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'],
      isAnonymous: data['isAnonymous'] ?? false,
      fullName: data['fullName'],
      phoneNumber: data['phoneNumber'],
      state: data['state'],
      district: data['district'],
      homeAddress: data['homeAddress'],
      emergencyContactName: data['emergencyContactName'],
      emergencyContactPhone: data['emergencyContactPhone'],
      alertThreshold: data['alertThreshold'] ?? 'all',
      smsAlertsEnabled: data['smsAlertsEnabled'] ?? true,
      pushAlertsEnabled: data['pushAlertsEnabled'] ?? true,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'isAnonymous': isAnonymous,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'state': state,
      'district': district,
      'homeAddress': homeAddress,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'alertThreshold': alertThreshold,
      'smsAlertsEnabled': smsAlertsEnabled,
      'pushAlertsEnabled': pushAlertsEnabled,
      'createdAt': createdAt?.toIso8601String() ??
          DateTime.now().toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? state,
    String? district,
    String? homeAddress,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? alertThreshold,
    bool? smsAlertsEnabled,
    bool? pushAlertsEnabled,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      isAnonymous: isAnonymous,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      state: state ?? this.state,
      district: district ?? this.district,
      homeAddress: homeAddress ?? this.homeAddress,
      emergencyContactName:
          emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      smsAlertsEnabled: smsAlertsEnabled ?? this.smsAlertsEnabled,
      pushAlertsEnabled: pushAlertsEnabled ?? this.pushAlertsEnabled,
      createdAt: createdAt,
    );
  }
}