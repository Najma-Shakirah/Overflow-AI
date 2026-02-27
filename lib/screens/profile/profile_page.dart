// lib/views/profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../navbar/navbar.dart';
import '../authentication/auth_viewmodel.dart';
import '../authentication/user_model.dart';

// ─── Malaysian states & districts (reused from register page) ───────────────
const Map<String, List<String>> _kStatesDistricts = {
  'Selangor': ['Petaling Jaya', 'Shah Alam', 'Subang Jaya', 'Klang', 'Ampang', 'Cheras', 'Sepang', 'Kuala Selangor', 'Hulu Langat', 'Rawang'],
  'Kuala Lumpur': ['Chow Kit', 'Titiwangsa', 'Brickfields', 'Bangsar', 'Cheras', 'Kepong', 'Wangsa Maju', 'Bukit Bintang', 'Seputeh', 'Segambut'],
  'Johor': ['Johor Bahru', 'Iskandar Puteri', 'Muar', 'Batu Pahat', 'Kluang', 'Kota Tinggi', 'Mersing', 'Pontian', 'Segamat', 'Kulai'],
  'Kedah': ['Alor Setar', 'Sungai Petani', 'Kulim', 'Langkawi', 'Baling', 'Kubang Pasu', 'Padang Terap', 'Yan', 'Pendang', 'Pokok Sena'],
  'Kelantan': ['Kota Bharu', 'Pasir Mas', 'Tanah Merah', 'Kuala Krai', 'Machang', 'Pasir Puteh', 'Bachok', 'Tumpat', 'Gua Musang', 'Jeli'],
  'Melaka': ['Melaka Tengah', 'Alor Gajah', 'Jasin'],
  'Negeri Sembilan': ['Seremban', 'Port Dickson', 'Nilai', 'Rembau', 'Tampin', 'Kuala Pilah'],
  'Pahang': ['Kuantan', 'Temerloh', 'Bentong', 'Cameron Highlands', 'Raub', 'Jerantut', 'Pekan', 'Rompin', 'Bera', 'Lipis'],
  'Perak': ['Ipoh', 'Taiping', 'Teluk Intan', 'Manjung', 'Kinta', 'Kuala Kangsar', 'Hilir Perak', 'Batang Padang', 'Larut Matang', 'Hulu Perak'],
  'Perlis': ['Kangar', 'Padang Besar', 'Arau'],
  'Pulau Pinang': ['Georgetown', 'Butterworth', 'Bayan Lepas', 'Bukit Mertajam', 'Kepala Batas', 'Nibong Tebal', 'Seberang Perai Tengah'],
  'Sabah': ['Kota Kinabalu', 'Sandakan', 'Tawau', 'Lahad Datu', 'Keningau', 'Semporna', 'Kudat', 'Beaufort', 'Ranau', 'Kota Belud'],
  'Sarawak': ['Kuching', 'Miri', 'Sibu', 'Bintulu', 'Sri Aman', 'Kapit', 'Limbang', 'Sarikei', 'Mukah', 'Betong'],
  'Terengganu': ['Kuala Terengganu', 'Kemaman', 'Dungun', 'Besut', 'Hulu Terengganu', 'Marang', 'Setiu', 'Kuala Nerus'],
  'Putrajaya': ['Putrajaya'],
  'Labuan': ['Labuan'],
};

// ─── Profile Page ────────────────────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? get _firebaseUser => FirebaseAuth.instance.currentUser;
  UserModel? _userModel;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserModel();
  }

  Future<void> _loadUserModel() async {
    final uid = _firebaseUser?.uid;
    if (uid == null) {
      setState(() => _loadingProfile = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _userModel = UserModel.fromFirestore(doc.data()!, uid);
          _loadingProfile = false;
        });
      } else if (mounted) {
        setState(() => _loadingProfile = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  String get _displayName {
    if (_userModel?.fullName != null && _userModel!.fullName!.isNotEmpty) {
      return _userModel!.fullName!;
    }
    if (_firebaseUser?.displayName != null && _firebaseUser!.displayName!.isNotEmpty) {
      return _firebaseUser!.displayName!;
    }
    return _firebaseUser?.email?.split('@').first ?? 'User';
  }

  String get _email => _userModel?.email ?? _firebaseUser?.email ?? 'No email';

  void _openEditSheet(BuildContext context) async {
    if (_userModel == null) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EditProfileSheet(
        userModel: _userModel!,
        onSaved: (updated) {
          setState(() => _userModel = updated);
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await context.read<AuthViewModel>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00C6FF), Color(0xFF0072FF), Color(0xFF667EEA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Text(
                                _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?',
                                style: const TextStyle(
                                    fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF0072FF)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(_displayName,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 6),
                          Text(_email,
                              style: const TextStyle(fontSize: 14, color: Colors.white70)),
                          if (_userModel?.state != null || _userModel?.district != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              [_userModel?.district, _userModel?.state]
                                  .where((s) => s != null && s.isNotEmpty)
                                  .join(', '),
                              style: const TextStyle(fontSize: 13, color: Colors.white60),
                            ),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _userModel != null ? () => _openEditSheet(context) : null,
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0072FF),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Info Summary Cards ───────────────────────────────────
                  if (_userModel != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(title: 'Account Details'),
                          _InfoCard(children: [
                            _InfoRow(icon: Icons.badge_outlined, label: 'Full Name', value: _userModel!.fullName),
                            _InfoRow(icon: Icons.email_outlined, label: 'Email', value: _userModel!.email),
                            _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: _userModel!.phoneNumber),
                          ]),
                          const SizedBox(height: 16),
                          _SectionHeader(title: 'Location'),
                          _InfoCard(children: [
                            _InfoRow(icon: Icons.map_outlined, label: 'State', value: _userModel!.state),
                            _InfoRow(icon: Icons.location_city_outlined, label: 'District', value: _userModel!.district),
                            _InfoRow(icon: Icons.home_outlined, label: 'Home Address', value: _userModel!.homeAddress),
                          ]),
                          const SizedBox(height: 16),
                          _SectionHeader(title: 'Emergency Contact'),
                          _InfoCard(children: [
                            _InfoRow(icon: Icons.person_outline, label: 'Contact Name', value: _userModel!.emergencyContactName),
                            _InfoRow(icon: Icons.phone_outlined, label: 'Contact Phone', value: _userModel!.emergencyContactPhone),
                          ]),
                          const SizedBox(height: 16),
                          _SectionHeader(title: 'Alert Preferences'),
                          _InfoCard(children: [
                            _InfoRow(
                              icon: Icons.tune_outlined,
                              label: 'Alert Threshold',
                              value: _userModel!.alertThreshold == 'all'
                                  ? 'All Alerts'
                                  : _userModel!.alertThreshold == 'warning'
                                      ? 'Warning & Critical'
                                      : 'Critical Only',
                            ),
                            _InfoRow(
                              icon: Icons.sms_outlined,
                              label: 'SMS Alerts',
                              value: _userModel!.smsAlertsEnabled ? 'Enabled' : 'Disabled',
                              valueColor: _userModel!.smsAlertsEnabled ? Colors.green : Colors.grey,
                            ),
                            _InfoRow(
                              icon: Icons.notifications_outlined,
                              label: 'Push Alerts',
                              value: _userModel!.pushAlertsEnabled ? 'Enabled' : 'Disabled',
                              valueColor: _userModel!.pushAlertsEnabled ? Colors.green : Colors.grey,
                            ),
                          ]),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],

                  // ── Stats ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatsCard(
                            icon: Icons.notifications_active,
                            label: 'Alerts Received',
                            value: '24',
                            color: Colors.orange,
                            onTap: () => Navigator.pushNamed(context, '/alerts'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatsCard(
                            icon: Icons.location_on,
                            label: 'Areas Monitored',
                            value: '3',
                            color: Colors.blue,
                            onTap: () => Navigator.pushNamed(context, '/monitor'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Logout ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Logout',
                            style: TextStyle(
                                color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.red, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      floatingActionButton: const MonitorFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}

// ─── Edit Profile Sheet ──────────────────────────────────────────────────────
class _EditProfileSheet extends StatefulWidget {
  final UserModel userModel;
  final void Function(UserModel updated) onSaved;

  const _EditProfileSheet({required this.userModel, required this.onSaved});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  // Controllers
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _homeAddressCtrl;
  late final TextEditingController _emergencyNameCtrl;
  late final TextEditingController _emergencyPhoneCtrl;

  // Auth change controllers
  late final TextEditingController _emailCtrl;
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  // Location
  String? _selectedState;
  String? _selectedDistrict;

  // Preferences
  late String _alertThreshold;
  late bool _smsAlerts;
  late bool _pushAlerts;

  // UI state
  bool _isLoading = false;
  bool _showPasswordSection = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _error;
  String? _success;

  // Tab
  int _tab = 0;
  final List<String> _tabs = ['Account', 'Location', 'Emergency', 'Alerts'];

  @override
  void initState() {
    super.initState();
    final u = widget.userModel;
    _fullNameCtrl = TextEditingController(text: u.fullName ?? '');
    _phoneCtrl = TextEditingController(text: u.phoneNumber ?? '');
    _homeAddressCtrl = TextEditingController(text: u.homeAddress ?? '');
    _emergencyNameCtrl = TextEditingController(text: u.emergencyContactName ?? '');
    _emergencyPhoneCtrl = TextEditingController(text: u.emergencyContactPhone ?? '');
    _emailCtrl = TextEditingController(text: u.email ?? '');
    _selectedState = u.state;
    _selectedDistrict = u.district;
    _alertThreshold = u.alertThreshold;
    _smsAlerts = u.smsAlertsEnabled;
    _pushAlerts = u.pushAlertsEnabled;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _homeAddressCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _emailCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() { _error = null; _success = null; });

    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser == null) return;

    final newEmail = _emailCtrl.text.trim();
    final newPassword = _newPasswordCtrl.text.trim();
    final emailChanged = newEmail != (fbUser.email ?? '');
    final passwordChanging = _showPasswordSection && newPassword.isNotEmpty;

    // Validation
    if (_fullNameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Full name cannot be empty.');
      return;
    }
    if (passwordChanging && newPassword != _confirmPasswordCtrl.text.trim()) {
      setState(() => _error = 'New passwords do not match.');
      return;
    }
    if (passwordChanging && newPassword.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters.');
      return;
    }
    if ((emailChanged || passwordChanging) && _currentPasswordCtrl.text.isEmpty) {
      setState(() => _error = 'Enter your current password to change email or password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Re-authenticate if needed
      if (emailChanged || passwordChanging) {
        final cred = EmailAuthProvider.credential(
          email: fbUser.email!,
          password: _currentPasswordCtrl.text.trim(),
        );
        await fbUser.reauthenticateWithCredential(cred);
      }

      // Firebase Auth updates
      if (_fullNameCtrl.text.trim() != fbUser.displayName) {
        await fbUser.updateDisplayName(_fullNameCtrl.text.trim());
      }
      if (emailChanged) {
        await fbUser.verifyBeforeUpdateEmail(newEmail);
      }
      if (passwordChanging) {
        await fbUser.updatePassword(newPassword);
      }

      // Build updated UserModel
      final updated = widget.userModel.copyWith(
        fullName: _fullNameCtrl.text.trim(),
        email: emailChanged ? null : newEmail, // keep old until verified
        phoneNumber: _phoneCtrl.text.trim(),
        state: _selectedState,
        district: _selectedDistrict,
        homeAddress: _homeAddressCtrl.text.trim(),
        emergencyContactName: _emergencyNameCtrl.text.trim(),
        emergencyContactPhone: _emergencyPhoneCtrl.text.trim(),
        alertThreshold: _alertThreshold,
        smsAlertsEnabled: _smsAlerts,
        pushAlertsEnabled: _pushAlerts,
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(fbUser.uid)
          .set(updated.toFirestore(), SetOptions(merge: true));

      widget.onSaved(updated);

      if (mounted) {
        setState(() {
          _success = emailChanged
              ? 'Profile saved! Check your new email for a verification link.'
              : 'Profile updated successfully.';
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() { _error = e.message ?? 'Update failed.'; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to save: $e'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                    color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // Title row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('Edit Profile',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final active = _tab == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() { _tab = i; _error = null; _success = null; }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: i < _tabs.length - 1 ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFF0072FF) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _tabs[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Tab content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_tab == 0) _buildAccountTab(),
                    if (_tab == 1) _buildLocationTab(),
                    if (_tab == 2) _buildEmergencyTab(),
                    if (_tab == 3) _buildAlertsTab(),

                    // Error / Success banners
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      _Banner(message: _error!, isError: true),
                    ],
                    if (_success != null) ...[
                      const SizedBox(height: 12),
                      _Banner(message: _success!, isError: false),
                    ],

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0072FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Save Changes',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 0: Account ──────────────────────────────────────────────────────────
  Widget _buildAccountTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sheetLabel('Full Name'),
        _sheetField(controller: _fullNameCtrl, hint: 'Your full name', icon: Icons.badge_outlined),
        const SizedBox(height: 14),
        _sheetLabel('Phone Number'),
        _sheetField(controller: _phoneCtrl, hint: '+60 12 345 6789', icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 14),
        _sheetLabel('Email Address'),
        _sheetField(controller: _emailCtrl, hint: 'your@email.com', icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 14),

        // Change Password toggle
        GestureDetector(
          onTap: () => setState(() => _showPasswordSection = !_showPasswordSection),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: Color(0xFF0072FF), size: 20),
              const SizedBox(width: 8),
              const Text('Change Password',
                  style: TextStyle(color: Color(0xFF0072FF), fontWeight: FontWeight.w600)),
              const Spacer(),
              Icon(_showPasswordSection ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF0072FF)),
            ],
          ),
        ),

        if (_showPasswordSection) ...[
          const SizedBox(height: 14),
          _sheetLabel('New Password'),
          _sheetField(
            controller: _newPasswordCtrl,
            hint: 'Leave blank to keep current',
            icon: Icons.lock_reset_outlined,
            obscure: _obscureNew,
            suffix: IconButton(
              icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20, color: Colors.grey),
              onPressed: () => setState(() => _obscureNew = !_obscureNew),
            ),
          ),
          const SizedBox(height: 14),
          _sheetLabel('Confirm New Password'),
          _sheetField(
            controller: _confirmPasswordCtrl,
            hint: 'Re-enter new password',
            icon: Icons.lock_reset_outlined,
            obscure: _obscureConfirm,
            suffix: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20, color: Colors.grey),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ],

        // Current password — shown when email or password is changing
        const SizedBox(height: 14),
        _sheetLabel('Current Password (required to change email or password)'),
        _sheetField(
          controller: _currentPasswordCtrl,
          hint: 'Required to save sensitive changes',
          icon: Icons.lock_outline,
          obscure: _obscureCurrent,
          suffix: IconButton(
            icon: Icon(_obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20, color: Colors.grey),
            onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Tab 1: Location ─────────────────────────────────────────────────────────
  Widget _buildLocationTab() {
    final districts = _selectedState != null ? _kStatesDistricts[_selectedState]! : <String>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sheetLabel('State'),
        _sheetDropdown<String>(
          value: _selectedState,
          hint: 'Select state',
          icon: Icons.map_outlined,
          items: _kStatesDistricts.keys.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (val) => setState(() { _selectedState = val; _selectedDistrict = null; }),
        ),
        const SizedBox(height: 14),
        _sheetLabel('District / City'),
        _sheetDropdown<String>(
          value: _selectedDistrict,
          hint: _selectedState == null ? 'Select state first' : 'Select district',
          icon: Icons.location_city_outlined,
          items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
          onChanged: _selectedState == null ? null : (val) => setState(() => _selectedDistrict = val),
        ),
        const SizedBox(height: 14),
        _sheetLabel('Home Address (optional)'),
        _sheetField(
          controller: _homeAddressCtrl,
          hint: 'e.g. No 12, Jalan Damai...',
          icon: Icons.home_outlined,
          maxLines: 2,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Tab 2: Emergency ────────────────────────────────────────────────────────
  Widget _buildEmergencyTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sheetLabel('Emergency Contact Name'),
        _sheetField(controller: _emergencyNameCtrl, hint: 'e.g. Siti Rahimah', icon: Icons.person_outline),
        const SizedBox(height: 14),
        _sheetLabel('Emergency Contact Phone'),
        _sheetField(
          controller: _emergencyPhoneCtrl,
          hint: '+60 12 345 6789',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Tab 3: Alerts ───────────────────────────────────────────────────────────
  Widget _buildAlertsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sheetLabel('Alert Threshold'),
        const SizedBox(height: 8),
        ...{
          'all': 'All Alerts',
          'warning': 'Warning & Critical',
          'critical': 'Critical Only',
        }.entries.map((e) {
          return RadioListTile<String>(
            value: e.key,
            groupValue: _alertThreshold,
            onChanged: (v) => setState(() => _alertThreshold = v!),
            title: Text(e.value),
            activeColor: const Color(0xFF0072FF),
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }),
        const Divider(height: 24),
        _sheetLabel('Notification Channels'),
        SwitchListTile(
          value: _smsAlerts,
          onChanged: (v) => setState(() => _smsAlerts = v),
          title: const Text('SMS Alerts', style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: const Text('Receive alerts via SMS'),
          activeColor: const Color(0xFF0072FF),
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.sms_outlined, color: Color(0xFF0072FF)),
        ),
        SwitchListTile(
          value: _pushAlerts,
          onChanged: (v) => setState(() => _pushAlerts = v),
          title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: const Text('Receive in-app notifications'),
          activeColor: const Color(0xFF0072FF),
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.notifications_outlined, color: Color(0xFF0072FF)),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Shared field helpers ─────────────────────────────────────────────────────
  Widget _sheetLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A5568))),
      );

  Widget _sheetField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF0072FF), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0072FF), width: 2)),
      ),
    );
  }

  Widget _sheetDropdown<T>({
    required T? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF0072FF), size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0072FF), width: 2)),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

// ─── Shared small widgets ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: children
            .asMap()
            .entries
            .map((e) => Column(children: [
                  e.value,
                  if (e.key < children.length - 1) Divider(height: 1, color: Colors.grey[100]),
                ]))
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;

  const _InfoRow({required this.icon, required this.label, this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0072FF)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const Spacer(),
          Text(
            value?.isNotEmpty == true ? value! : '—',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? (value?.isNotEmpty == true ? const Color(0xFF2D3748) : Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String message;
  final bool isError;
  const _Banner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red : Colors.green;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[200]!),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: color[700], size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: color[700], fontSize: 13))),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatsCard({required this.icon, required this.label, required this.value, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
    return onTap != null ? InkWell(onTap: onTap, child: card) : card;
  }
}