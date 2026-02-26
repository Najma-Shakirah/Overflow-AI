import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Alert {
  final String id;
  final String location;
  final String severity;
  final String message;
  final DateTime timestamp;

  Alert({
    required this.id,
    required this.location,
    required this.severity,
    required this.message,
    required this.timestamp,
  });

  factory Alert.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Alert(
      id: doc.id,
      location: data['location'] ?? '',
      severity: data['severity'] ?? 'UNKNOWN',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class AlertsPageViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Alert> _alerts = [];
  final bool _isLoading = false;
  String? _error;

  List<Alert> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<Alert>> get alertsStream => _firestore
      .collection('flood_alerts')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Alert.fromDoc).toList());
}