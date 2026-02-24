// lib/models/profile_model.dart
class ProfileModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final int alertsReceived;
  final int areasMonitored;

  ProfileModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.alertsReceived = 0,
    this.areasMonitored = 0,
  });

  // Create from user model and additional data
  factory ProfileModel.fromUserModel({
    required String uid,
    required String email,
    String? name,
    String? photoUrl,
    int alertsReceived = 0,
    int areasMonitored = 0,
  }) {
    return ProfileModel(
      uid: uid,
      name: name ?? 'User',
      email: email,
      photoUrl: photoUrl,
      alertsReceived: alertsReceived,
      areasMonitored: areasMonitored,
    );
  }

  ProfileModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    int? alertsReceived,
    int? areasMonitored,
  }) {
    return ProfileModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      alertsReceived: alertsReceived ?? this.alertsReceived,
      areasMonitored: areasMonitored ?? this.areasMonitored,
    );
  }
}