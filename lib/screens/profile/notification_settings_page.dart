import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../screens/authentication/auth_viewmodel.dart';
import '../../services/notification_service.dart';

// Reusable constants
const _thresholdOptions = {
  'all': 'All alerts',
  'warning': 'Warning or above',
  'critical': 'Critical only',
};

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends State<NotificationSettingsPage> {
  bool _pushEnabled = true;
  bool _smsEnabled = true;
  String _threshold = 'all';
  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().user;
    if (user != null) {
      _pushEnabled = user.pushAlertsEnabled;
      _smsEnabled = user.smsAlertsEnabled;
      _threshold = user.alertThreshold;
    }
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final auth = context.read<AuthViewModel>();
    final current = auth.user;
    if (current == null) return;

    final updated = current.copyWith(
      smsAlertsEnabled: _smsEnabled,
      pushAlertsEnabled: _pushEnabled,
      alertThreshold: _threshold,
    );

    final success = await auth.saveUserProfile(updated);
    if (success) {
      // manage push topic subscription
      final notif = NotificationService();
      if (_pushEnabled) {
        await FirebaseMessaging.instance.subscribeToTopic('flood_alerts');
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic('flood_alerts');
      }
      setState(() {
        _message = 'Settings saved';
      });
    } else {
      setState(() {
        _message = auth.errorMessage ?? 'Failed to save';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: const Color(0xFF3A83B7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Push Notifications'),
              value: _pushEnabled,
              onChanged: (v) => setState(() => _pushEnabled = v),
            ),
            SwitchListTile(
              title: const Text('SMS Alerts'),
              value: _smsEnabled,
              onChanged: (v) => setState(() => _smsEnabled = v),
            ),
            const SizedBox(height: 16),
            const Text('Alert Threshold',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _threshold,
              items: _thresholdOptions.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _threshold = v);
              },
            ),
            const SizedBox(height: 20),
            if (_message != null) ...[
              Text(_message!,
                  style: TextStyle(
                      color: _message!.contains('failed')
                          ? Colors.red
                          : Colors.green)),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
