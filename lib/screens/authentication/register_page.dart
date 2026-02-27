// lib/screens/authentication/register_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'auth_viewmodel.dart';
import '../../widgets/glass_container.dart';

// ─── Malaysian states & districts ───────────────────────────────────────────
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

// ─── Main register page (hosts the PageView) ────────────────────────────────
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  String _email = '';
  String _password = '';
  String _fullName = '';
  String _phoneNumber = '';
  String? _state;
  String? _district;
  String _homeAddress = '';

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = step);
  }

  void _onStep1Complete({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) {
    _email = email;
    _password = password;
    _fullName = fullName;
    _phoneNumber = phoneNumber;
    _goToStep(1);
  }

  void _onStep2Complete({
    required String? state,
    required String? district,
    required String homeAddress,
  }) {
    this._state = state;
    this._district = district;
    _homeAddress = homeAddress;
    _goToStep(2);
  }

  Future<void> _onStep3Complete({
    required String emergencyName,
    required String emergencyPhone,
    required String alertThreshold,
    required bool smsAlerts,
    required bool pushAlerts,
  }) async {
    final viewModel = context.read<AuthViewModel>();

    final profileData = UserModel(
      uid: '',
      email: _email,
      isAnonymous: false,
      fullName: _fullName,
      phoneNumber: _phoneNumber,
      state: _state,
      district: _district,
      homeAddress: _homeAddress.isEmpty ? null : _homeAddress,
      emergencyContactName: emergencyName.isEmpty ? null : emergencyName,
      emergencyContactPhone: emergencyPhone.isEmpty ? null : emergencyPhone,
      alertThreshold: alertThreshold,
      smsAlertsEnabled: smsAlerts,
      pushAlertsEnabled: pushAlerts,
    );

    final success = await viewModel.registerWithEmail(
      email: _email,
      password: _password,
      profileData: profileData,
    );

    if (success && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background matching splash screen
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00C6FF),
                  Color(0xFF0072FF),
                  Color(0xFF667EEA),
                ],
              ),
            ),
          ),

          // Decorative bubbles
          _GlowBubble(size: 200, top: -50, right: -50),
          _GlowBubble(size: 160, bottom: 100, left: -60),

          SafeArea(
            child: Column(
              children: [
                // Progress header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: GlassContainer(
                    borderRadius: 16,
                    blur: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (_currentStep > 0)
                              GestureDetector(
                                onTap: () => _goToStep(_currentStep - 1),
                                child: const Icon(Icons.arrow_back_ios,
                                    size: 18, color: Colors.white),
                              )
                            else
                              const SizedBox(width: 18),
                            const Spacer(),
                            Text(
                              'Step ${_currentStep + 1} of 3',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Progress bar
                        Row(
                          children: List.generate(3, (i) {
                            return Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                                height: 5,
                                decoration: BoxDecoration(
                                  color: i <= _currentStep
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Step pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _Step1Account(onComplete: _onStep1Complete),
                      _Step2Location(onComplete: _onStep2Complete),
                      _Step3Emergency(
                        onComplete: _onStep3Complete,
                        isLoading: context.watch<AuthViewModel>().isLoading,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

class _GlowBubble extends StatelessWidget {
  final double size;
  final double? top, bottom, left, right;
  const _GlowBubble({required this.size, this.top, this.bottom, this.left, this.right});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.0),
          ]),
        ),
      ),
    );
  }
}

Widget _buildField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  bool obscure = false,
  Widget? suffixIcon,
  String? Function(String?)? validator,
  int maxLines = 1,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscure,
    maxLines: maxLines,
    validator: validator,
    style: const TextStyle(color: Color(0xFF1A1A2E)),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF0072FF)),
      prefixIcon: Icon(icon, color: const Color(0xFF0072FF), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0072FF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    ),
  );
}

Widget _buildNextButton({required String label, required VoidCallback? onTap, bool isLoading = false}) {
  return SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0072FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(color: Color(0xFF0072FF), strokeWidth: 2),
            )
          : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ),
  );
}

// ─── STEP 1: Account Details ─────────────────────────────────────────────────
class _Step1Account extends StatefulWidget {
  final Function({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) onComplete;

  const _Step1Account({required this.onComplete});

  @override
  State<_Step1Account> createState() => _Step1AccountState();
}

class _Step1AccountState extends State<_Step1Account> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onComplete(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Form(
        key: _formKey,
        child: GlassContainer(
          borderRadius: 24,
          blur: 12,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.person_outline, color: Colors.white, size: 34),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text('Create Your Account',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text('Basic details to get you started',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14)),
              ),
              const SizedBox(height: 24),

              _buildField(
                controller: _nameController, label: 'Full Name', icon: Icons.badge_outlined,
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter your full name' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _emailController, label: 'Email Address', icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter your email';
                  if (!v.contains('@')) return 'Please enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _phoneController, label: 'Phone Number', icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter your phone number';
                  if (v.length < 9) return 'Please enter a valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _passwordController, label: 'Password', icon: Icons.lock_outline,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF0072FF), size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter a password';
                  if (v.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _confirmController, label: 'Confirm Password', icon: Icons.lock_outline,
                obscure: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF0072FF), size: 20),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please confirm your password';
                  if (v != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              _buildNextButton(label: 'Continue', onTap: _submit),
              const SizedBox(height: 14),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style: TextStyle(color: Colors.white.withOpacity(0.8))),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── STEP 2: Location ────────────────────────────────────────────────────────
class _Step2Location extends StatefulWidget {
  final Function({required String? state, required String? district, required String homeAddress}) onComplete;
  const _Step2Location({required this.onComplete});

  @override
  State<_Step2Location> createState() => _Step2LocationState();
}

class _Step2LocationState extends State<_Step2Location> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  String? _selectedState;
  String? _selectedDistrict;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onComplete(
        state: _selectedState,
        district: _selectedDistrict,
        homeAddress: _addressController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final districts =
        _selectedState != null ? kMalaysiaStatesDistricts[_selectedState]! : <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Form(
        key: _formKey,
        child: GlassContainer(
          borderRadius: 24,
          blur: 12,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.location_on_outlined, color: Colors.white, size: 34),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text('Your Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text('So we can send you relevant flood alerts',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14)),
              ),
              const SizedBox(height: 24),

              _buildGlassDropdown<String>(
                value: _selectedState,
                label: 'State *',
                icon: Icons.map_outlined,
                items: kMalaysiaStatesDistricts.keys
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() {
                  _selectedState = val;
                  _selectedDistrict = null;
                }),
                validator: (v) => v == null ? 'Please select your state' : null,
              ),
              const SizedBox(height: 12),

              _buildGlassDropdown<String>(
                value: _selectedDistrict,
                label: 'District / City *',
                icon: Icons.location_city_outlined,
                items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: _selectedState == null
                    ? null
                    : (val) => setState(() => _selectedDistrict = val),
                validator: (v) => v == null ? 'Please select your district' : null,
              ),
              const SizedBox(height: 12),

              _buildField(
                controller: _addressController,
                label: 'Home Address (optional)',
                icon: Icons.home_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              _buildNextButton(label: 'Continue', onTap: _submit),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildGlassDropdown<T>({
  required T? value,
  required String label,
  required IconData icon,
  required List<DropdownMenuItem<T>> items,
  required void Function(T?)? onChanged,
  String? Function(T?)? validator,
}) {
  return DropdownButtonFormField<T>(
    value: value,
    dropdownColor: Colors.white,
    style: const TextStyle(color: Color(0xFF1A1A2E)),
    iconEnabledColor: const Color(0xFF0072FF),
    iconDisabledColor: Colors.grey,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF0072FF)),
      prefixIcon: Icon(icon, color: const Color(0xFF0072FF), size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0072FF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    ),
    items: items,
    onChanged: onChanged,
    validator: validator,
  );
}

// ─── STEP 3: Emergency & Preferences ────────────────────────────────────────
class _Step3Emergency extends StatefulWidget {
  final bool isLoading;
  final Future<void> Function({
    required String emergencyName,
    required String emergencyPhone,
    required String alertThreshold,
    required bool smsAlerts,
    required bool pushAlerts,
  }) onComplete;

  const _Step3Emergency({required this.onComplete, required this.isLoading});

  @override
  State<_Step3Emergency> createState() => _Step3EmergencyState();
}

class _Step3EmergencyState extends State<_Step3Emergency> {
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  String _alertThreshold = 'all';
  bool _smsAlerts = true;
  bool _pushAlerts = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassContainer(
        borderRadius: 24,
        blur: 12,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: const Icon(Icons.shield_outlined, color: Colors.white, size: 34),
              ),
            ),
            const SizedBox(height: 14),
            const Center(
              child: Text('Emergency & Alerts',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
            ),
            const SizedBox(height: 24),

            Text('Emergency Contact',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white.withOpacity(0.9))),
            const SizedBox(height: 12),
            _buildField(
                controller: _emergencyNameController,
                label: 'Contact Name',
                icon: Icons.person_outline),
            const SizedBox(height: 12),
            _buildField(
                controller: _emergencyPhoneController,
                label: 'Contact Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 24),

            // Error message
            Consumer<AuthViewModel>(builder: (ctx, vm, _) {
              if (vm.errorMessage == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(vm.errorMessage!,
                              style: const TextStyle(color: Colors.white))),
                    ],
                  ),
                ),
              );
            }),

            _buildNextButton(
              label: 'Complete Registration',
              isLoading: widget.isLoading,
              onTap: () => widget.onComplete(
                emergencyName: _emergencyNameController.text.trim(),
                emergencyPhone: _emergencyPhoneController.text.trim(),
                alertThreshold: _alertThreshold,
                smsAlerts: _smsAlerts,
                pushAlerts: _pushAlerts,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: widget.isLoading
                    ? null
                    : () => widget.onComplete(
                          emergencyName: '',
                          emergencyPhone: '',
                          alertThreshold: _alertThreshold,
                          smsAlerts: _smsAlerts,
                          pushAlerts: _pushAlerts,
                        ),
                child: Text('Skip for now',
                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}