import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../navbar/navbar.dart';

// Sample alerts shown when Firestore is empty (for development/demo)
final List<Map<String, dynamic>> _sampleAlerts = [
  {
    'title': 'Severe Flooding Detected',
    'location': 'Kuala Lumpur, Lembah Klang',
    'severity': 'CRITICAL',
    'message':
        'Water levels have exceeded danger threshold at 8.2m. Immediate evacuation advised for low-lying areas. Emergency services are on standby.',
    'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 10))),
  },
  {
    'title': 'Flash Flood Warning',
    'location': 'Shah Alam, Selangor',
    'severity': 'HIGH',
    'message':
        'Heavy rainfall has caused rapid water rise in Seksyen 7 and Seksyen 13. Residents near riverbanks should move to higher ground immediately.',
    'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 45))),
  },
  {
    'title': 'Flood Watch Issued',
    'location': 'Petaling Jaya, Selangor',
    'severity': 'WARNING',
    'message':
        'Continuous rain forecast for the next 6 hours. Water levels at Sungai Klang are rising. Monitor local updates and be prepared to evacuate.',
    'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
  },
  {
    'title': 'Road Closure — Flood Risk',
    'location': 'Subang Jaya, Selangor',
    'severity': 'WARNING',
    'message':
        'Jalan SS15 and surrounding roads temporarily closed due to waterlogging. Use alternative routes via Federal Highway.',
    'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 3))),
  },
  {
    'title': 'Water Level Advisory',
    'location': 'Ampang, Kuala Lumpur',
    'severity': 'INFO',
    'message':
        'Water levels at Sungai Ampang currently at 3.1m — below danger threshold. Situation is being monitored. No action required at this time.',
    'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
  },
  {
    'title': 'Flood Alert Lifted',
    'location': 'Cheras, Kuala Lumpur',
    'severity': 'INFO',
    'message':
        'Previous flood warning for Taman Connaught has been lifted. Water levels have returned to normal. Roads are now open.',
    'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 8))),
  },
];

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3A83B7), Color.fromARGB(255, 29, 255, 142)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flood Alerts',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Stay informed about flood warnings',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: selectedFilter == 'All',
                      color: Colors.blue,
                      onTap: () => setState(() => selectedFilter = 'All'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Critical',
                      isSelected: selectedFilter == 'Critical',
                      color: Colors.red,
                      onTap: () => setState(() => selectedFilter = 'Critical'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Warning',
                      isSelected: selectedFilter == 'Warning',
                      color: Colors.orange,
                      onTap: () => setState(() => selectedFilter = 'Warning'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Info',
                      isSelected: selectedFilter == 'Info',
                      color: Colors.green,
                      onTap: () => setState(() => selectedFilter = 'Info'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Alerts List — Firestore with sample data fallback
            StreamBuilder<QuerySnapshot>(
              stream: _getAlertsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Use Firestore data if available, otherwise show sample alerts
                final bool useFirestore =
                    snapshot.hasData && snapshot.data!.docs.isNotEmpty;

                final List<Map<String, dynamic>> alerts = useFirestore
                    ? snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data;
                      }).toList()
                    : _getFilteredSampleAlerts();

                if (alerts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No alerts for this filter',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Show banner if using sample data
                      if (!useFirestore)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 16, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Showing sample alerts — real alerts will appear here automatically.',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.blue[700]),
                                ),
                              ),
                            ],
                          ),
                        ),

                      ...alerts.map((data) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _AlertCard(
                            title: data['title'] ?? 'Flood Alert',
                            location: data['location'] ?? 'Unknown',
                            time: _getTimeAgo(data['timestamp']),
                            severity: data['severity'] ?? 'Info',
                            severityColor:
                                _getSeverityColor(data['severity']),
                            description: data['message'] ?? '',
                            icon: _getSeverityIcon(data['severity']),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: const MonitorFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 1,
      ),
    );
  }

  Stream<QuerySnapshot> _getAlertsStream() {
    Query query = FirebaseFirestore.instance
        .collection('flood_alerts')
        .orderBy('timestamp', descending: true)
        .limit(20);

    if (selectedFilter != 'All') {
      query = query.where('severity', isEqualTo: selectedFilter.toUpperCase());
    }

    return query.snapshots();
  }

  Color _getSeverityColor(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return Colors.red;
      case 'WARNING':
      case 'MEDIUM':
        return Colors.orange;
      case 'INFO':
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return Icons.emergency;
      case 'WARNING':
      case 'MEDIUM':
        return Icons.warning_amber_rounded;
      case 'INFO':
      case 'LOW':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  String _getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      return 'Just now';
    }

    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final String location;
  final String time;
  final String severity;
  final Color severityColor;
  final String description;
  final IconData icon;

  const _AlertCard({
    required this.title,
    required this.location,
    required this.time,
    required this.severity,
    required this.severityColor,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: severityColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: severityColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: severityColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              location,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    severity.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showAlertDetails(context),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAlertDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(location, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            Text('Time: $time',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}