import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../authentication/auth_viewmodel.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _isProcessing = false;
  String? _message;

  Future<bool> _reauthenticate(String currentPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      setState(() => _message = e.message);
      return false;
    }
  }

  void _showChangePasswordDialog() {
    final _currentCtrl = TextEditingController();
    final _newCtrl = TextEditingController();
    final _confirmCtrl = TextEditingController();
    bool _obscureCurr = true;
    bool _obscureNew = true;
    bool _obscureConf = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentCtrl,
                obscureText: _obscureCurr,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurr
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscureCurr = !_obscureCurr),
                  ),
                ),
              ),
              TextField(
                controller: _newCtrl,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
              ),
              TextField(
                controller: _confirmCtrl,
                obscureText: _obscureConf,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConf
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscureConf = !_obscureConf),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () async {
                  final curr = _currentCtrl.text.trim();
                  final newP = _newCtrl.text.trim();
                  final conf = _confirmCtrl.text.trim();
                  if (curr.isEmpty || newP.isEmpty || conf.isEmpty) {
                    setState(() {
                      _message = 'Please fill all fields';
                    });
                    return;
                  }
                  if (newP != conf) {
                    setState(() {
                      _message = 'New passwords do not match';
                    });
                    return;
                  }
                  if (newP.length < 6) {
                    setState(() {
                      _message = 'Password must be at least 6 characters';
                    });
                    return;
                  }

                  Navigator.pop(ctx); // dismiss dialog
                  setState(() {
                    _isProcessing = true;
                    _message = null;
                  });

                  final ok = await _reauthenticate(curr);
                  if (!ok) {
                    setState(() => _isProcessing = false);
                    return;
                  }

                  try {
                    await FirebaseAuth.instance.currentUser!
                        .updatePassword(newP);
                    setState(() {
                      _message = 'Password changed successfully';
                    });
                  } on FirebaseAuthException catch (e) {
                    setState(() => _message = e.message);
                  }

                  setState(() {
                    _isProcessing = false;
                  });
                },
                child: const Text('Save'))
          ],
        );
      }),
    );
  }

  void _showDeleteAccountDialog() {
    final _passwordCtrl = TextEditingController();
    bool _obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'This action is irreversible. Enter your password to confirm.'),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final pw = _passwordCtrl.text.trim();
                  if (pw.isEmpty) return;
                  Navigator.pop(ctx);
                  setState(() {
                    _isProcessing = true;
                    _message = null;
                  });

                  final ok = await _reauthenticate(pw);
                  if (!ok) {
                    setState(() => _isProcessing = false);
                    return;
                  }

                  try {
                    await FirebaseAuth.instance.currentUser!.delete();
                    // sign out and navigate
                    await context.read<AuthViewModel>().signOut();
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/login', (_) => false);
                    }
                  } catch (e) {
                    setState(() => _message = 'Failed to delete account');
                    setState(() => _isProcessing = false);
                  }
                },
                child: const Text('Delete'))
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: const Color(0xFF3A83B7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Password'),
              onTap: _showChangePasswordDialog,
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Account',
                  style: TextStyle(color: Colors.red)),
              onTap: _showDeleteAccountDialog,
            ),
            if (_isProcessing) const CircularProgressIndicator(),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!,
                  style: TextStyle(
                      color: _message!.contains('failed')
                          ? Colors.red
                          : Colors.green)),
            ],
          ],
        ),
      ),
    );
  }
}
