import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../screens/authentication/auth_viewmodel.dart';
import '../../services/notification_service.dart';

/// Reuse same dataset used during registration
const Map<String, List<String>> kMalaysiaStatesDistricts = {
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

class LocationPreferencesPage extends StatefulWidget {
  const LocationPreferencesPage({super.key});

  @override
  State<LocationPreferencesPage> createState() =>
      _LocationPreferencesPageState();
}

class _LocationPreferencesPageState extends State<LocationPreferencesPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedState;
  String? _selectedDistrict;
  final _addressCtrl = TextEditingController();

  bool _isSaving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().user;
    if (user != null) {
      _selectedState = user.state;
      _selectedDistrict = user.district;
      _addressCtrl.text = user.homeAddress ?? '';
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _message = null;
    });

    final auth = context.read<AuthViewModel>();
    final current = auth.user;
    if (current == null) return;

    final oldDistrict = current.district;
    final updated = current.copyWith(
      state: _selectedState,
      district: _selectedDistrict,
      homeAddress: _addressCtrl.text.trim(),
    );

    final success = await auth.saveUserProfile(updated);
    if (success) {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(current.uid);
      await userDoc.set(
        {
          'areasMonitored': _selectedDistrict != null ? 1 : 0,
        },
        SetOptions(merge: true),
      );

      final notif = NotificationService();
      if (oldDistrict != null && oldDistrict.isNotEmpty) {
        await notif.unsubscribeFromLocation(oldDistrict);
      }
      if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) {
        await notif.subscribeToLocation(_selectedDistrict!);
      }

      setState(() {
        _message = 'Location preferences updated';
      });
    } else {
      setState(() {
        _message = auth.errorMessage ?? 'Failed to save';
      });
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final districts = _selectedState != null
        ? kMalaysiaStatesDistricts[_selectedState] ?? []
        : <String>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Preferences'),
        backgroundColor: const Color(0xFF3A83B7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedState,
                decoration: const InputDecoration(labelText: 'State *'),
                items: kMalaysiaStatesDistricts.keys
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() {
                  _selectedState = val;
                  _selectedDistrict = null;
                }),
                validator: (v) => v == null ? 'Please select your state' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: const InputDecoration(labelText: 'District *'),
                items: districts
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: _selectedState == null
                    ? null
                    : (val) => setState(() => _selectedDistrict = val),
                validator: (v) => v == null ? 'Please select your district' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Home Address (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              if (_message != null) ...[
                Text(
                  _message!,
                  style: TextStyle(
                      color: _message!.contains('Failed')
                          ? Colors.red
                          : Colors.green),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
